// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../utils/AddressUtils.sol";

contract Common {

    string constant NUMBER_LESS_THAN_ZERO = "001001";
    string constant ZERO_ADDRESS = "003001";

    address constant ZA = address(0);

    modifier nz(address addr) {
        require(addr != address(0), ZERO_ADDRESS);
        _;
    }

    modifier gtz(uint256 value) {
        require(value > 0, NUMBER_LESS_THAN_ZERO);
        _;
    }

}
