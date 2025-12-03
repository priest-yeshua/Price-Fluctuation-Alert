// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external returns (bool, bytes memory);
}
