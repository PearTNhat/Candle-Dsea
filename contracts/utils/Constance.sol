// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Constance {
    // Intervals hashed
    bytes32 public constant INTERVAL_1S = keccak256("1s");
    bytes32 public constant INTERVAL_1M = keccak256("1m");
    bytes32 public constant INTERVAL_3M = keccak256("3m");
    bytes32 public constant INTERVAL_5M = keccak256("5m");
    bytes32 public constant INTERVAL_15M = keccak256("15m");
    bytes32 public constant INTERVAL_30M = keccak256("30m");
    bytes32 public constant INTERVAL_1H = keccak256("1h");
    bytes32 public constant INTERVAL_2H = keccak256("2h");
    bytes32 public constant INTERVAL_4H = keccak256("4h");
    bytes32 public constant INTERVAL_6H = keccak256("6h");
    bytes32 public constant INTERVAL_8H = keccak256("8h");
    bytes32 public constant INTERVAL_12H = keccak256("12h");
    bytes32 public constant INTERVAL_1D = keccak256("1d");
    bytes32 public constant INTERVAL_3D = keccak256("3d");
    bytes32 public constant INTERVAL_1W = keccak256("1w");
    bytes32 public constant INTERVAL_1MO = keccak256("1M");

    // Thêm các interval khác nếu cần

    // Time steps (milliseconds)
    uint64 public constant STEP_1S   = 4 * 60 * 60 * 1000;              // 4h //14,4k
    uint64 public constant STEP_1M   = 10 * 24 * 60 * 60 * 1000;         // 10d // 14,4 
    uint64 public constant STEP_3M   = 25 * 24 * 60 * 60 * 1000;         // 25d  //12k
    uint64 public constant STEP_5M   = 35 * 24 * 60 * 60 * 1000;         // 35d  // 10k
    uint64 public constant STEP_15M  = 90 * 24 * 60 * 60 * 1000;        // 90d   //8640
    uint64 public constant STEP_30M  = 200 * 24 * 60 * 60 * 1000;        // 200d //9600
    uint64 public constant STEP_1H   = 365 * 24 * 60 * 60 * 1000;        // 1y 8760
    uint64 public constant STEP_2H   = 2 * 365 *  24 * 60 * 60 * 1000;      // 14d
    uint64 public constant STEP_4H   = 4 * 365 * 60 * 60 * 1000;        // 4y
    uint64 public constant STEP_6H   = 6 * 365 * 60 * 60 * 1000;        // 6y
    uint64 public constant STEP_8H   = 8 * 365 * 60 * 60 * 1000;        // 8y
    uint64 public constant STEP_12H  = 12 * 365 *60 * 60 * 1000;        // 12y
    uint64 public constant STEP_1D   = 24 * 365  * 60 * 60 * 1000;       // 24y
    uint64 public constant STEP_3D   = 72 * 365 * 60 * 60 * 1000;       // 72y
    uint64 public constant STEP_1W   = 10 * 365 * 24 * 60 * 60 * 1000;  // 50y
    uint64 public constant STEP_1MO  = 200 * 365 * 24 * 60 * 60 * 1000; // 100y
    // Thêm các bước khác nếu cần
}
