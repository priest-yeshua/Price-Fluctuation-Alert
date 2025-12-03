// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PriceFluctuationAlert.sol";

contract DeployTrap is Script {
    function run() external {
        vm.startBroadcast();

        // --- Replace these with actual oracle and pair addresses ---
        address oracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH/USD Chainlink
        address pair   = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc; // ETH/USDC UniswapV2

        PriceFluctuationAlert trap = new PriceFluctuationAlert(oracle, pair);

        console.log("TRAP deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
