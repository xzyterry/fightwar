// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/// ERC-721 NFT标准
///  https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
interface IERC721 {

    // region Event

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    // endregion

    // region Function

    // region Info

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    // endregion

    // region Transfer

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // endregion

    // region Approval

    function approve(address _approved, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    // endregion

    // endregion

}
