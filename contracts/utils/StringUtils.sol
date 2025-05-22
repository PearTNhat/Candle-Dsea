// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StringUtils {
    /// @notice Tách phần chuỗi trước dấu '-' (nếu không có '-' trả về toàn bộ chuỗi)
    /// @param str Chuỗi đầu vào
    /// @return prefix Chuỗi con trước dấu '-'
    function getPrefix(string memory str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint len = strBytes.length;
        bytes memory result = new bytes(len);

        uint i = 0;
        for (; i < len; i++) {
            if (strBytes[i] == "-") {
                break;
            }
            result[i] = strBytes[i];
        }

        bytes memory prefix = new bytes(i);
        for (uint j = 0; j < i; j++) {
            prefix[j] = result[j];
        }

        return string(prefix);
    }

    /// @notice So sánh 2 chuỗi string có giống nhau không (dùng keccak256)
    /// @param a Chuỗi a
    /// @param b Chuỗi b
    /// @return true nếu 2 chuỗi bằng nhau
    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    
}
