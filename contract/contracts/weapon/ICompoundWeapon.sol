// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/// 武器铸造合约,不开源
interface ICompoundWeapon {

    function isValid() external pure returns (bool);

    function generate(address owner, uint256 coin) external returns (
        uint256 seq,
        uint8 level,
        uint256 damage
    );

}
