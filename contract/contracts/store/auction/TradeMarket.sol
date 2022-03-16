// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../../common/Pausable.sol";
import "../../assert/nft/NFTBase.sol";
import "../../common/Common.sol";

/// 交易市场
contract TradeMarket is Pausable, Common {
    // region Constants

    /// 售卖中
    uint8 public constant IN_THE_SALE = 1;

    /// 已售卖
    uint8 public constant SOLD_OUT = 2;

    // endregion

    // region Event

    event CommodityCreated(
        uint256 indexed tokenId,
        address indexed owner,
        uint256 indexed price
    );

    event CommoditySoldOut(
        uint256 indexed tokenId,
        address indexed oldOwner,
        address indexed newOwner
    );

    event CommodityCancelled(uint256 indexed tokenId);

    // endregion

    // region Struct

    struct Commodity {
        uint256 tokenId;
        // 卖家
        address seller;
        // 售价
        uint256 price;
        // 收益(=售价-抽成)
        uint256 income;
        // 创建时间
        uint256 createTime;
        // 交易时间
        uint256 tradeTime;
        // 交易状态 1:售卖中 2:已售卖
        uint8 status;
    }

    // endregion

    /// nft合约地址
    NFTBase nftContract;

    // 抽成比例 抽成= price*(cut/10000)
    uint256 cut;

    mapping(uint256 => Commodity) tokenIdToCommodity;

    uint256[] saleTokenIds;

    mapping(uint256 => uint256) tokenIdToIndex;

    bytes4 internal constant SI = 0x01ffc9a9;

    constructor(address _nftAddress, uint256 _cut) {
        require(_cut <= 10000);
        cut = _cut;

        NFTBase candidate = NFTBase(_nftAddress);
        require(candidate.supportsInterface(SI));
        nftContract = candidate;
    }

    /// 托管操作权
    function _escrow(address _owner, uint256 _tokenId) internal {
        nftContract.transferFrom(_owner, address(this), _tokenId);
    }

    /// 校验所有权
    function _owns(address _claimant, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return (nftContract.ownerOf(_tokenId) == _claimant);
    }

    /// 创建商品
    function createCommodity(uint256 _tokenId, uint256 _price)
        external
        whenNotPaused
    {
        address seller = msg.sender;
        require(seller != address(0));
        require(_owns(seller, _tokenId));
        _escrow(seller, _tokenId);
        Commodity memory commodity = Commodity({
            tokenId: _tokenId,
            seller: seller,
            price: _price,
            income: 0,
            createTime: block.timestamp,
            tradeTime: 0,
            status: IN_THE_SALE
        });
        _addCommodity(commodity);
    }

    function _addCommodity(Commodity memory _commodity) internal {
        // 先判断该商品未上架过
        uint256 tokenId = _commodity.tokenId;
        require(tokenIdToCommodity[tokenId].status < 1);
        tokenIdToCommodity[tokenId] = _commodity;

        saleTokenIds.push(tokenId);
        tokenIdToIndex[tokenId] = saleTokenIds.length - 1;

        emit CommodityCreated(tokenId, _commodity.seller, _commodity.price);
    }

    function pageCommodities(uint256 page, uint256 limit)
        public
        view
        returns (uint256[] memory tokenIds)
    {
        require(page > 0);
        require(limit > 0 && limit < 100);
        tokenIds = new uint256[](limit);
        uint256 start = limit * (page - 1);
        for (uint256 i = 0; i < saleTokenIds.length; i++) {
            tokenIds[i] = saleTokenIds[start + i];
        }
    }

    /// 查询商品
    function getCommodity(uint256 _tokenId)
        external
        view
        returns (Commodity memory commodity)
    {
        return tokenIdToCommodity[_tokenId];
    }

    function _isOnSale(Commodity storage commodity)
        internal
        view
        returns (bool)
    {
        return commodity.status == IN_THE_SALE;
    }

    /// 下架商品(卖家发起下架)
    function cancelSale(uint256 _tokenId) external {
        Commodity storage commodity = tokenIdToCommodity[_tokenId];
        require(_isOnSale(commodity));

        address seller = commodity.seller;
        require(seller == msg.sender);
        _cancelSale(_tokenId, seller);
    }

    function _cancelSale(uint256 _tokenId, address _seller) internal {
        _removeCommodity(_tokenId);

        _transfer(_seller, _tokenId);

        emit CommodityCancelled(_tokenId);
    }

    function _transfer(address _receiver, uint256 _tokenId) internal {
        nftContract.transferFrom(address(this), _receiver, _tokenId);
    }

    /// 下架商品(合约owner主动发起的下架)
    function cancelSaleWhenPaused(uint256 _tokenId)
        external
        whenPaused
        onlyOwner
    {
        Commodity storage commodity = tokenIdToCommodity[_tokenId];
        require(_isOnSale(commodity));

        _cancelSale(_tokenId, commodity.seller);
    }

    function _removeCommodity(uint256 _tokenId) internal {
        delete tokenIdToCommodity[_tokenId];

        uint256 lastIndex = saleTokenIds.length - 1;
        uint256 lastOne = saleTokenIds[lastIndex];
        saleTokenIds[tokenIdToIndex[_tokenId]] = lastOne;
        delete saleTokenIds[lastIndex];
    }

    /// 购买商品
    function purchase(uint256 _tokenId) external whenNotPaused {
        /// 结算
        _settle(_tokenId);

        /// 转移NFT
        _transfer(msg.sender, _tokenId);
    }

    /// 结算
    function _settle(uint256 _tokenId) internal {
        Commodity storage commodity = tokenIdToCommodity[_tokenId];
        require(_isOnSale(commodity));

        uint256 price = commodity.price;
        require(price <= msg.value);

        // 防止重入攻击
        _removeCommodity(_tokenId);

        address seller = commodity.seller;
        if (price > 0) {
            uint256 sellerIncome = price - _computeCut(price);
            if (sellerIncome > 0) {
                payable(seller).transfer(sellerIncome);
            }
        }

        emit CommoditySoldOut(_tokenId, seller, msg.sender);
    }

    // 计算抽成
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return (_price * cut) / 10000;
    }
}
