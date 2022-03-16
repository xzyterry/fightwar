// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Entity.sol";
import "./Role.sol";
import "./Part.sol";

/// 游戏数据
contract GameData is Entity {
    Role public role;
    Part public part;

    constructor() Entity() {
    }

    function setRole(Role _role) public {
        require(_role.active());
        role = _role;
    }

    function setPart(Part _part) public {
        require(_part.active());
        part = _part;
    }
}
