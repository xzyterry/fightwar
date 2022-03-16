// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/// ERC-721 元数据,可选
/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.

interface IERC721Metadata {

    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

}
