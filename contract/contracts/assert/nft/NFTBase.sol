// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../../erc/erc721/IERC721.sol";
import "../../erc/erc165/SupportsInterface.sol";
import "../../erc/erc721/IERC721TokenReceiver.sol";
import "../../common/Common.sol";

contract NFTBase is IERC721, Common, SupportsInterface {

    using AddressUtils for address;

    // region Constant

    string constant NOT_VALID_NFT = "003002";
    string constant NOT_OWNER_OR_OPERATOR = "003003";
    string constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
    string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
    string constant NFT_ALREADY_EXISTS = "003006";
    string constant NOT_OWNER = "003007";
    string constant IS_OWNER = "003008";
    string constant TOKEN_NO_OWNER = "003009";

    /// 如果一个智能合约可以接收NFT则返回该魔数
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    // endregion

    // region Variable

    mapping(address => uint256) private ownerToNFTCount;

    mapping(uint256 => address) internal tokenIdToOwner;

    mapping(uint256 => address) internal tokenIdToApproval;

    /// <tokenOwner,<operator,bool>>
    /// tokenOwner 给 operator 的操作权限
    mapping(address => mapping(address => bool)) internal ownerToOperators;

    // endregion

    // region Modifier

    modifier checkNFTValid(uint256 _tokenId){
        require(tokenIdToOwner[_tokenId] != address(0), NOT_VALID_NFT);
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = tokenIdToOwner[_tokenId];
        require(
            tokenOwner == msg.sender ||
            tokenIdToApproval[_tokenId] == msg.sender ||
            ownerToOperators[tokenOwner][msg.sender],
            NOT_OWNER_APPROVED_OR_OPERATOR
        );
        _;
    }

    modifier canOperate(uint256 _tokenId){
        address tokenOwner = tokenIdToOwner[_tokenId];
        require(
            tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
            NOT_OWNER_OR_OPERATOR
        );
        _;
    }

    // endregion

    // region Function

    bytes4 internal constant SI = 0x01ffc9a9;

    constructor(){
        supportedInterfaces[SI] = true;
    }

    // region Info

    function balanceOf(address _owner) external override view nz(_owner) returns (uint256) {
        return _getNFTCount(_owner);
    }

    function ownerOf(uint256 _tokenId) external view override returns (address _owner) {
        _owner = tokenIdToOwner[_tokenId];
        require(_owner != address(0), NOT_VALID_NFT);
    }

    // endregion

    // region Transfer

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external override {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /// 仅限账户之间的资产转移
    function transferFrom(address _from, address _to, uint256 _tokenId) external override
    nz(_from) nz(_to) canTransfer(_tokenId) checkNFTValid(_tokenId)
    {
        address tokenOwner = tokenIdToOwner[_tokenId];
        require(tokenOwner == _from, NOT_OWNER);
        _transfer(_to, _tokenId);
    }

    // endregion

    // region Approval

    function approve(address _approved, uint256 _tokenId) external override
    nz(_approved) canOperate(_tokenId) checkNFTValid(_tokenId) {
        address tokenOwner = tokenIdToOwner[_tokenId];
        require(_approved != tokenOwner, IS_OWNER);

        tokenIdToApproval[_tokenId] = _approved;
        emit Approval(tokenOwner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) external view override checkNFTValid(_tokenId) returns (address) {
        return tokenIdToApproval[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external override
    nz(_operator) {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
        return ownerToOperators[_owner][_operator];
    }

    // endregion

    // endregion

    // region Base

    /// 内部转移NFT
    function _transfer(address _to, uint256 _tokenId) internal  {
        address from = tokenIdToOwner[_tokenId];
        require(from != address(0), TOKEN_NO_OWNER);

        _clearApproval(_tokenId);
        _removeNFT(from, _tokenId);
        _addNFT(_to, _tokenId);

        emit Transfer(from, _to, _tokenId);
    }

    function _mint(address _to, uint256 _tokenId) nz(_to) virtual internal  {
        require(tokenIdToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

        _addNFT(_to, _tokenId);

        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(uint256 _tokenId) internal virtual checkNFTValid(_tokenId)  {
        address tokenOwner = tokenIdToOwner[_tokenId];
        _clearApproval(_tokenId);
        _removeNFT(tokenOwner, _tokenId);

        emit Transfer(tokenOwner, address(0), _tokenId);
    }

    function _removeNFT(address _from, uint256 _tokenId) internal virtual  {
        require(tokenIdToOwner[_tokenId] == _from, NOT_OWNER);
        ownerToNFTCount[_from] -= 1;
        delete tokenIdToOwner[_tokenId];
    }

    function _addNFT(address _to, uint256 _tokenId) internal virtual  {
        require(tokenIdToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
        tokenIdToOwner[_tokenId] = _to;
        ownerToNFTCount[_to] += 1;
    }

    function _getNFTCount(address _owner) internal view virtual returns (uint256)  {
        return ownerToNFTCount[_owner];
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private 
    nz(_from) nz(_to) canTransfer(_tokenId) checkNFTValid(_tokenId) {
        address tokenOwner = tokenIdToOwner[_tokenId];
        require(tokenOwner == _from, NOT_OWNER);
        _transfer(_to, _tokenId);

        // 如果是向合约转账,则需要等待合约接受的
        if (_to.isContract()) {
            bytes4 res = IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(res == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
        }
    }

    function _clearApproval(uint256 _tokenId) private  {
        delete tokenIdToApproval[_tokenId];
    }

    // endregion

}
