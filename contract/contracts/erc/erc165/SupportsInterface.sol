// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC165.sol";

contract SupportsInterface is IERC165 {

    mapping(bytes4 => bool) internal supportedInterfaces;

    constructor(){
        supportedInterfaces[0x01ffc9a7] = true;
    }

    function supportsInterface(bytes4 _interfaceID) external view override returns (bool){
        return supportedInterfaces[_interfaceID];
    }

}
