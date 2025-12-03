// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PriceAlertResponder {
    event AlertTriggered(uint256 changeWad);

    function respondCallback(uint256 changeWad) external {
        emit AlertTriggered(changeWad);
    }
}
