// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Entity {
    // 当实体被创建时,设置激活状态,便于空对象的判定
    bool public active;

    constructor(){
        active = true;
    }
}
