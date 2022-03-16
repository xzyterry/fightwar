// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../common/Pausable.sol";
import "./ICompoundWeapon.sol";
import "./CompoundWeapon.sol";
import "../assert/nft/EnumerableNFT.sol";
import "../assert/coin/GameCoin.sol";

struct Weapon {
    // 武器序列号,即 tokenId
    uint256 seq;
    // 等级
    uint8 level;
    // 伤害
    uint256 damage;
}

contract WeaponCore is EnumerableNFT, Pausable {
    // 合成事件
    event Compound(address indexed owner, uint256 indexed seq, uint256 coin);

    mapping(uint256 => Weapon) weapons;

    ICompoundWeapon compoundWeapon;

    GameCoin gameCoin;

    constructor(address _compoundWeaponAddress, address _coinAddress) {
        ICompoundWeapon candidate = CompoundWeapon(_compoundWeaponAddress);
        require(candidate.isValid());
        compoundWeapon = candidate;

        GameCoin candidateGameCoin = GameCoin(_coinAddress);
        require(candidateGameCoin.isValid());
        gameCoin = candidateGameCoin;
    }

    function compound(address _player, uint256 coin) external {
        // 金币,合成材料 扣除
        gameCoin.burn(_player, coin);
        // // 生成武器
        (uint256 _seq, uint8 _level, uint256 _damage) = compoundWeapon.generate(
            _player,
            coin
        );
        _mint(_player, _seq);
        weapons[_seq] = Weapon({seq: _seq, level: _level, damage: _damage});
    }

    function getWeapon(uint256 seq)
        external
        view
        returns (Weapon memory weapon)
    {
        weapon = weapons[seq];
    }

    function getWeapons(address _player)
        external
        view
        returns (uint256[] memory tokenIds)
    {
        tokenIds = ownerToIds[_player];
    }

    function getWeaponCount(address _player)
        external
        view
        returns (uint256 cnt)
    {
        cnt = _getNFTCount(_player);
    }
}
