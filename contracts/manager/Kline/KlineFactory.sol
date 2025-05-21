// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseKline.sol";
import "../../utils/StringUtils.sol";
import "../../interface/IKlineManager.sol";

contract KlineFactory is StringUtils {
    mapping(string => mapping(uint256 => address)) public klineContracts;
    event KlineContractCreated(uint key, address contractAddress);
    // lưu trong 1 h

    // sử lý lại interval có chỉ đc giới hạn từng đó thôi
    function _getDayIndex(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 1 hours;
    }
    function getKlineContract(string memory interval)
        public
        view
        returns (address)   
    {
        uint key = _getDayIndex(block.timestamp);
        // require(klineContracts[key] != address(0), "Address not found");
        // if (klineContracts[key] == address(0)) {
        //     BaseKline newContract = new BaseKline();
        //     klineContracts[key] = address(newContract);
        //     emit KlineContractCreated(key,address(newContract));
        // }
        return klineContracts[interval][key];
    }

    function addCandle(KlineRecord memory record, string memory _interval ) public {
        uint key = _getDayIndex(block.timestamp);
        // tạo lưu theo 1h
        if (klineContracts[_interval][key] == address(0)) {
            BaseKline newContract = new BaseKline(_interval);
            klineContracts[_interval][key] = address(newContract);
            emit KlineContractCreated(key,address(newContract));
        }
        IKlineManager(klineContracts[_interval][key]).recordKline(record);
    }

    function getLengthKline(string memory _interval, uint timestime) public view returns (uint256) {
        uint key = _getDayIndex(timestime);
        address _address = klineContracts[_interval][key];
        require(_address != address(0), "Address is not found");
        return IKlineManager(_address).getLength();
    }

    function getAllKline(string memory interval,uint timestime)
        public
        view
        returns (KlineResponse[] memory)
    {
        uint key = _getDayIndex(timestime);
        address _address = klineContracts[interval][key];
        require(_address != address(0), "Address is not found");
        return IKlineManager(_address).getAllKline();
    }
}
