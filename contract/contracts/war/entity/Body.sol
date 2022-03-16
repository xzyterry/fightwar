// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";

    struct BodyView {
        uint8 height;
        uint8 hairType;
    }

// 形体
contract Body is Entity {
    uint8 constant INIT_HEIGHT = 10;
    uint8 constant INIT_HAIR_TYPE = 1;

    uint8 public height;
    uint8 public hairType;

    constructor(){
        height = INIT_HEIGHT;
        hairType = INIT_HAIR_TYPE;
    }

    function print() public view returns (BodyView memory v) {
        v.height = height;
        v.hairType = hairType;
        return v;
    }
}
