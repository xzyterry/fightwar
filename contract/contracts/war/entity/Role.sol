// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";
import "./Body.sol";
import "./LevelInfo.sol";
import "./Backpack.sol";

    struct RoleView {
        // 昵称
        string nickname;
        // 生命值
        uint8 hp;
        // 形体
        BodyView body;
    }

contract Role is Entity {
    uint8 constant INIT_HP = 100;
    // 昵称
    string public nickname;
    // 生命值
    uint8 public hp;
    // 形体
    Body public body;
    // 等级
    LevelInfo public levelInfo;
    // 背包
    Backpack public backpack;

    constructor(string memory _nickname) Entity(){
        nickname = _nickname;
        hp = INIT_HP;
        levelInfo = new LevelInfo();
        body = new Body();
        backpack = new Backpack();
    }

    function print() public view returns (RoleView memory v) {
        v.nickname = nickname;
        v.hp = hp;
        v.body = body.print();
        return v;
    }

}