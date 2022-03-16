// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC721Metadata.sol";

contract ERC721Metadata is IERC721Metadata {

    string private myName;

    string private mySymbol;
    
    mapping(uint256 => string) tokenIdToURIs;

    constructor(string memory _name, string memory  _symbol) {
        myName = _name;
        mySymbol = _symbol;
    }

    function name() external view override returns (string memory _name) {
        _name = myName;
    }

    function symbol() external view override returns (string memory _symbol) {
        _symbol = mySymbol;
    }

    function tokenURI(uint256 _tokenId) external view override returns (string memory uri) {
        uri = tokenIdToURIs[_tokenId];
    }

}
