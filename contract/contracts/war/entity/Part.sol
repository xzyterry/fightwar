// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";

    struct PartView {
        // 关卡号
        uint256 no;
        // boss hp
        uint256 bossHp;
        // 掉落金币
        uint256 award;
    }

/// 关卡
contract Part is Entity {
    // 关卡号
    uint256 public no;
    // boss hp
    uint256 public bossHp;
    // 掉落金币
    uint256 public award;

    constructor(uint256 _no, uint256 _bossHp, uint256 _award) Entity() {
        no = _no;
        bossHp = _bossHp;
        award = _award;
    }

    function finished() external view returns (bool){
        return bossHp <= 0;
    }

    /// boss被攻击
    function beAttacked(uint8 _damage) external returns (uint256) {
        require(_damage > 0);
        if (bossHp <= 0) {
            return bossHp;
        }

        if (bossHp < _damage) {
            bossHp = 0;
        } else {
            bossHp = bossHp - _damage;
        }

        return bossHp;
    }

    function acqAward() external returns (uint256 _award) {
        _award = award;
        award = 0;
    }

    function print() public view returns (PartView memory v) {
        v.no = no;
        v.bossHp = bossHp;
        v.award = award;
        return v;
    }
}