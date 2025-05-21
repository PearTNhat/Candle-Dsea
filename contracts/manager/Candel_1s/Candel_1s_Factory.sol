// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Candel_1s_Manager.sol";

contract Candle_1s_Factory {
    mapping(string => address) public candleContracts;

    function getOrCreateCandleContract(string memory week) public returns (address) {
        if (candleContracts[week] == address(0)) {
            Candle_1s_Manager newContract = new Candle_1s_Manager();
            candleContracts[week] = address(newContract);
        }
        return candleContracts[week];
    }
    function addCandle(CandleRecord memory record,address _address) public {
        Candle_1s_Manager(_address).recordCandle(record);
    }
    function getLengthCandle(address _address) public view returns (uint){
        return Candle_1s_Manager(_address).getLength();
    }
    function getAllCandle(address _address) public view returns (CandleResponse[] memory){
        return Candle_1s_Manager(_address).getAllCandle();
    }

}