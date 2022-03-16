// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library AddressUtils {

    /// 判断地址是不是合约(不是0x0也不是账户地址)
    function isContract(address _addr) internal view returns (bool result) {
        bytes32 codeHash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codeHash := extcodehash(_addr)
        }
        result = (codeHash != 0x0 && codeHash != accountHash);
    }

}
