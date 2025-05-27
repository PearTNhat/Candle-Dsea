// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
enum Interval {
    OneSecond,
    OneMinute,
    ThreeMinutes,
    FiveMinutes,
    FifteenMinutes,
    ThirtyMinutes,
    OneHour,
    TwoHours,
    FourHours,
    SixHours,
    EightHours,
    TwelveHours,
    OneDay,
    ThreeDays,
    OneWeek,
    OneMonth
}

struct BTCNetFlowStruct{
    uint64 timestamp;
    uint inflow;
    uint outflow;
    uint price;
    uint volume;
    uint marketCap;
    uint aum;            // Net Assets/AUM (thêm để khớp với biểu đồ)
}