// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../interface/IBTCNetFlow.sol";

contract BTCNetFlowManager {
    BTCNetFlowStruct[] private netFlows;

    event NetFlowAdded(uint index, BTCNetFlowStruct data);

    function addNetFlow(BTCNetFlowStruct calldata data) external {
        netFlows.push(data);
        emit NetFlowAdded(netFlows.length - 1, data);
    }

    function getNetFlows() external view returns (BTCNetFlowStruct[] memory) {
        return netFlows;
    }

    function getNetFlowCount() external view returns (uint) {
        return netFlows.length;
    }
}
