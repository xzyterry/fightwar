// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";

    struct LevelInfoView {
        // 等级
        uint8 level;
        // 经验值
        uint8 exp;
    }

/// 等级信息
contract LevelInfo is Entity {
    uint8 constant INIT_LEVEL = 1;
    uint8 constant INIT_EXP = 0;
    // 等级
    uint8 public level;
    // 经验值
    uint8 public exp;

    constructor(){
        level = INIT_LEVEL;
        exp = INIT_EXP;
    }

    // 增加经验值,如果超出等级经验值,则升级
    function incExp(uint8 acqExp) external {}

    function print() public view returns (LevelInfoView memory v) {
        v.level = level;
        v.exp = exp;
        return v;
    }
}