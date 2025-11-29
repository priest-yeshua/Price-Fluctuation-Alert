// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract PriceFluctuationAlert is ITrap {

    address public constant TOKEN = 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;
    // Example threshold: 10% change (0.10 * 1e18 = 1e17)
    uint256 public constant PRICE_CHANGE_THRESHOLD = 1e17;

    struct CollectOutput {
        uint256 currentPrice;
    }

    constructor() {}

   
    function collect() external view override returns (bytes memory) {
        uint256 price = IERC20(TOKEN).balanceOf(address(this));
        return abi.encode(CollectOutput(price));
    }

    
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length < 2) return (false, "");

        CollectOutput memory current = abi.decode(data[0], (CollectOutput));
        CollectOutput memory past = abi.decode(data[data.length - 1], (CollectOutput));

        if (past.currentPrice == 0) return (false, "");

        uint256 priceChange = (
            (current.currentPrice > past.currentPrice)
                ? ((current.currentPrice - past.currentPrice) * 1e18 / past.currentPrice)
                : ((past.currentPrice - current.currentPrice) * 1e18 / past.currentPrice)
        );

        if (priceChange > PRICE_CHANGE_THRESHOLD) {
            return (true, "");
        }

        return (false, "");
    }
}
