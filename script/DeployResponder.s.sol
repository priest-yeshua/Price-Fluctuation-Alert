// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PriceAlertResponder.sol";

contract DeployResponder is Script {
    function run() external {
        vm.startBroadcast();

        PriceAlertResponder responder = new PriceAlertResponder();

        console.log("RESPONDER deployed at:", address(responder));

        vm.stopBroadcast();
    }
}
