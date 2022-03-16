// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../../erc/erc20/ERC20.sol";
import "../../common/Common.sol";

contract GameCoin is ERC20, Common {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {}

    function isValid() public pure returns (bool) {
        return true;
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }

    function mint(address _to, uint256 _value)
        public
        override
        nz(_to)
        gtz(_value)
    {
        // 仅主合约可以操作
        super.mint(_to, _value);
    }

    function burn(address _from, uint256 _value)
        public
        override
        nz(_from)
        gtz(_value)
    {
        // 仅主合约可以操作
        super.burn(_from, _value);
    }
}
