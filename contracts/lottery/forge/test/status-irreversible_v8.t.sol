// ANSWER: FALSE
// EXPLANATION: The property fails because some successful transactions leave `status` unchanged. In particular, `win()` is callable by any EOA when `status == Status.Win`, and it does change the status; however, `compute_winner()` and `hashing()` are public `pure` functions that can be called successfully without modifying state or `status`.
// COUNTEREXAMPLE: In any reachable state, an EOA calls `hashing("")`. The call succeeds and returns `keccak256(abi.encodePacked(""))`, but `status` is unchanged. Thus the status after the non-reverting transaction is equal to, not strictly greater than, the status before it.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v8.sol";

contract LotteryTest is Test {
  function setUp() public {

  }
  function test_status_irreversible() public {
    
  }
}
