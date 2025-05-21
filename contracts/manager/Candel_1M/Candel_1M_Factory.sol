// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Candel_1M_Manager.sol";

contract Candel_1M_Factory {
    mapping(string => address) public candleContracts;
    address[] public candles_1M;

    function getOrCreateCandleContract(string memory week) public returns (address) {
        if (candleContracts[week] == address(0)) {
            Candle_1M_Manager newContract = new Candle_1M_Manager();
            candleContracts[week] = address(newContract);
            candles_1M.push(address(newContract));
        }
        return candleContracts[week];
    }
    function addCandle(CandleRecord memory record,address _address) public {
        Candle_1M_Manager(_address).recordCandle(record);
    }
    function getLengthCandle(address _address) public view returns (uint){
        return Candle_1M_Manager(_address).getLength();
    }

    function getAllAddress () public view returns (address[] memory){
        return candles_1M;
    }

}