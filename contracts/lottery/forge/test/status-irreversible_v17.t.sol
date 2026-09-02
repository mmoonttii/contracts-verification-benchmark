// ANSWER: FALSE

// EXPLANATION: The property is violated because there are successful transactions that do not change `status`. In particular:
// * `reveal1()` succeeds but never updates `status`; it remains `Status.Reveal1`.
// * `compute_winner()`, `hashing()`, and `_status()` are public functions that can be called in transactions and do not modify `status` at all
// COUNTEREXAMPLE: Initial state immediately after deployment:
// * `status = Status.Join0` (enum value `0`).
// Transaction:
// 1. Any EOA calls `compute_winner(anyAddress0, anyAddress1, "", "")`.
// Result:
// * The transaction does not revert (the function is `public pure`).
// * `status` before the transaction is `0` (`Join0`).
// * `status` after the transaction is still `0` (`Join0`).
// Thus, the status after a non-reverting transaction is not strictly greater than before.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v17.sol";

contract LotteryTest is Test {
  function setUp() public {

  }
  function test_status_irreversible() public {
    
  }
}
