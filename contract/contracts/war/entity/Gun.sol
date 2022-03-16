// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";

struct GunView {
    // 等级
    uint8 level;
    // 星级
    uint8 star;
    // 子弹数
    uint8 bullet;
    // 换弹冷却时间
    uint256 cd;
    // 伤害
    uint8 damage;
    // ts
    uint256 ts;
    // lcbts
    uint256 lcbts;
}

// 枪
contract Gun is Entity {
    // 等级
    uint8 level;
    // 星级
    uint8 star;
    // 子弹数
    uint8 bullet;
    // 换弹冷却时间,s (lastChangeBulletTimestamp)
    uint256 lcbts;
    // 伤害
    uint8 damage;

    uint8 constant INIT_LEVEL = 1;
    uint8 constant INIT_STAR = 1;
    uint8 constant INIT_BULLET = 1;
    uint8 constant INIT_DAMAGE = 10;
    // 换弹冷却时间,单位: s
    uint32 constant INIT_CHANG_BULLET_CD = 2;

    constructor() Entity() {
        level = INIT_LEVEL;
        star = INIT_STAR;
        bullet = INIT_BULLET;
        damage = INIT_DAMAGE;
    }

    // 射击
    function shot() external returns (uint8) {
        uint256 ts = block.timestamp;
        if (lcbts == 0 && bullet == INIT_BULLET) {
            lcbts = ts;
        }

        if (bullet > 0) {
            bullet--;
            return damage;
        }

        if (ts - lcbts < INIT_CHANG_BULLET_CD) {
            return 0;
        }

        bullet = INIT_BULLET;
        lcbts = ts;
        bullet--;
        return damage;
    }

    function print() public view returns (GunView memory v) {
        v.level = level;
        v.star = star;
        v.bullet = bullet;
        v.damage = damage;
        v.lcbts = lcbts;
        uint256 ts = block.timestamp;
        v.ts = ts;

        uint256 cd = 0;
        if (lcbts > 0) {
            uint256 diff = ts - lcbts;
            if (diff < INIT_CHANG_BULLET_CD) {
                cd = INIT_CHANG_BULLET_CD - diff;
            }
        }
        v.cd = cd;
        return v;
    }
}
