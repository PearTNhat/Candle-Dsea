// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../struct/BTCNetFlowStruct.sol";

interface IBTCNetFlow {
    function addNetFlow(BTCNetFlowStruct calldata data) external;
    function getNetFlows() external view returns (BTCNetFlowStruct[] memory);
    function getNetFlowCount() external view returns (uint);
}
