// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Pausable is Ownable {

    event Pause();

    event UnPause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit UnPause();
    }

}
