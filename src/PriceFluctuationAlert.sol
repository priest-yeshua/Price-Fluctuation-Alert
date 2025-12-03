// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IAggregatorV2V3 {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32);
}

contract PriceFluctuationAlert is ITrap {

    address public immutable ORACLE;
    address public immutable PAIR;

    uint256 public constant PRICE_CHANGE_THRESHOLD = 1e17;
    uint256 public constant ONE = 1e18;

    struct Sample {
        uint256 price18;
        uint256 blockNumber;
    }

    constructor(address oracle_, address pair_) {
        ORACLE = oracle_;
        PAIR = pair_;
    }

    function collect() external view override returns (bytes memory) {
        (uint256 price18, ) = _safeReadOracle(ORACLE);
        if (price18 == 0) {
            price18 = _readPairPriceToWad(PAIR);
        }
        return abi.encode(Sample(price18, block.number));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");
        if (data[0].length == 0 || data[1].length == 0) return (false, "");

        Sample memory cur = abi.decode(data[0], (Sample));
        Sample memory prev = abi.decode(data[1], (Sample));

        if (cur.price18 == 0 || prev.price18 == 0) return (false, "");

        uint256 hi = cur.price18 > prev.price18 ? cur.price18 : prev.price18;
        uint256 lo = cur.price18 > prev.price18 ? prev.price18 : cur.price18;

        uint256 changeWad = ((hi - lo) * ONE) / prev.price18;

        if (changeWad > PRICE_CHANGE_THRESHOLD) {
            return (true, abi.encode(changeWad));
        }

        return (false, "");
    }

    function _safeReadOracle(address oracle) internal view returns (uint256 price18, uint256 updatedAt) {
        if (oracle == address(0)) return (0,0);
        uint256 size;
        assembly { size := extcodesize(oracle) }
        if (size == 0) return (0,0);

        price18 = 0;
        updatedAt = 0;

        try IAggregatorV2V3(oracle).latestRoundData() returns (uint80, int256 ans, uint256, uint256 upd, uint80) {
            if (ans > 0) {
                uint8 dec = 18;
                try IAggregatorV2V3(oracle).decimals() returns (uint8 d) { dec = d; } catch {}
                price18 = _to1e18(uint256(ans), dec);
                updatedAt = upd;
            }
        } catch {}
    }

    function _readPairPriceToWad(address pair) internal view returns (uint256 price18) {
        if (pair == address(0)) return 0;
        uint256 size;
        assembly { size := extcodesize(pair) }
        if (size == 0) return 0;

        try IUniswapV2Pair(pair).getReserves() returns (uint112 r0, uint112 r1, uint32) {
            if (r0 == 0 || r1 == 0) return 0;
            price18 = (uint256(r1) * ONE) / uint256(r0);
        } catch {
            price18 = 0;
        }
    }

    function _to1e18(uint256 v, uint8 dec) internal pure returns (uint256) {
        if (dec == 18) return v;
        if (dec < 18) return v * 10 ** (18 - dec);
        return v / 10 ** (dec - 18);
    }
}
