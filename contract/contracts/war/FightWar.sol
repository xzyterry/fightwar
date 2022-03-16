// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./entity/Part.sol";
import "./entity/GameData.sol";
import "./entity/Role.sol";
import "../common/Ownable.sol";
import "../common/Common.sol";

// 主线: 玩家闯关升级,获得金币,购买升级装备,买卖装备

// todo 将关卡部署到 关卡合约中 便于扩展
contract FightWar is Ownable, Common {
    mapping(uint256 => Part) partMap;
    mapping(address => GameData) gameDataMap;
    GameCoin gameCoin;

    constructor() {
        partMap[1] = new Part(1, 10, 100000);
    }

    function setCoinAddress(address _coinAddr)
        external
        onlyOwner
        nz(_coinAddr)
    {
        gameCoin = GameCoin(_coinAddr);
    }

    function getGun(address _player) public view returns (GunView memory) {
        GameData gameData = gameDataMap[_player];
        Role role = gameData.role();
        Backpack backpack = role.backpack();
        Gun gun = backpack.gun();
        return gun.print();
    }

    function getCoin(address _player) public view returns (uint256 balance) {
        balance = gameCoin.balanceOf(_player);
    }

    function getBackpack(address _player)
        public
        view
        returns (BackpackView memory)
    {
        GameData gameData = gameDataMap[_player];
        Role role = gameData.role();
        Backpack backpack = role.backpack();
        return backpack.print();
    }

    function getLevelInfo(address _player)
        public
        view
        returns (LevelInfoView memory)
    {
        GameData gameData = gameDataMap[_player];
        Role role = gameData.role();
        LevelInfo levelInfo = role.levelInfo();
        return levelInfo.print();
    }

    function getRole(address _player) public view returns (RoleView memory) {
        GameData gameData = gameDataMap[_player];
        Role role = gameData.role();
        return role.print();
    }

    function getPart(address _player) public view returns (PartView memory) {
        GameData gameData = gameDataMap[_player];
        Part part = gameData.part();
        return part.print();
    }

    /// 创建角色
    function createRole(address _player, string memory nickname) external {
        Role role = new Role(nickname);
        GameData gameData = new GameData();
        gameData.setRole(role);
        gameDataMap[_player] = gameData;
    }

    // 1.玩家选择关卡
    function choosePart(address _player, uint256 partNo) external {
        Part part = partMap[partNo];
        require(part.active(), "part not existed.");
        GameData gameData = gameDataMap[_player];
        require(gameData.active(), "need create role first.");
        gameData.setPart(new Part(part.no(), part.bossHp(), part.award()));
    }

    /// 2.进行对战
    function fight(address _player) external {
        GameData gameData = gameDataMap[_player];
        require(gameData.active(), "choose part first.");

        Part part = gameData.part();
        // 判断当前是否已通过关卡
        if (part.finished()) {
            return;
        }

        // 获取当前枪
        Role role = gameData.role();
        Backpack backpack = role.backpack();
        Gun gun = backpack.gun();

        // 射击
        uint8 damage = gun.shot();
        if (damage > 0) {
            uint256 bossHp = part.beAttacked(damage);
            // 3.打败boss获得金币
            if (bossHp <= 0) {
                uint256 award = part.acqAward();
                if (award > 0) {
                    gameCoin.mint(_player, award);
                }
            }
        }
    }
}
