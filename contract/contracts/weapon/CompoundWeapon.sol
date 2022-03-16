// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ICompoundWeapon.sol";
import "../assert/nft/NFTBase.sol";

contract CompoundWeapon is ICompoundWeapon {

    bytes4 internal constant SALT = 0x12dfcf29;

    uint256 counter;

    function isValid() public pure override returns (bool) {
        return true;
    }

    /// 这里后续可以搞复杂一点
    function generate(address owner, uint256 coin) public override returns (
        uint256 seq,
        uint8 level,
        uint256 damage
    ) {
        counter++;
        seq = uint256(keccak256(abi.encodePacked(owner, coin, block.timestamp, counter, SALT)));
        level = uint8(coin / 100);
        damage = level * 10;
    }

}
