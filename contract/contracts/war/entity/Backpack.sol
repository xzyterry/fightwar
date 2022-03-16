// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";
import "./Gun.sol";
import "../../assert/coin/GameCoin.sol";

    struct BackpackView {
        // 枪
        GunView gun;
        // 金币
        uint256 coin;

    }

/// 背包
contract Backpack is Entity {
    // 枪
    Gun public gun;

    constructor(){
        gun = new Gun();
    }

    function print() public view returns (BackpackView memory v) {
        v.gun = gun.print();
        return v;
    }
}
