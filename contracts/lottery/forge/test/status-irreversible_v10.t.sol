// ANSWER: FALSE
// 
// EXPLANATION: The function `win()` has no precondition on `status`. It can be called in any state, including `Status.End`. It always executes `status = Status.End` after attempting the transfer. Therefore, if `status` is already `End`, a successful call to `win()` leaves the status unchanged, violating the property.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v10.sol";

contract LotteryTest is Test {
  function setUp() public {

  }
  function test_status_irreversible() public {
    
  }
}
