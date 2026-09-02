// ANSWER: FALSE
// EXPLANATION: `win()` calls `compute_winner()`, whose result depends on `block.timestamp`. Thus two otherwise identical non-reverting `win` transactions can produce different winners if executed in blocks with different timestamps. The subsequent state also differs because `winner` is assigned the computed address.
// COUNTEREXAMPLE: Consider a state with `status == Win`, both secrets already revealed, `player0 != player1`, and `bytes(secret0).length + bytes(secret1).length` even. A `win()` transaction in a block with an even `block.timestamp` sets `winner = player0`; a `win()` transaction from the same pre-transaction state in a block with an odd `block.timestamp` sets `winner = player1`. Both transactions can be non-reverting, but their results differ.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v11.sol";

contract LotteryTest is Test {
  Lottery lotteryEven;
  Lottery lotteryOdd;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 0.01 ether;

  string s0 = "a";
  string s1 = "b";

  bytes32 h0;
  bytes32 h1;

  function setUp() public {
    lotteryEven = new Lottery();
    lotteryOdd = new Lottery();
    vm.deal(p0, 2 ether);
    vm.deal(p1, 2 ether);

    h0 = lotteryEven.hashing(s0);
    h1 = lotteryEven.hashing(s1);

    vm.prank(p0);
    lotteryEven.join0{value: bet}(h0);
    vm.prank(p1);
    lotteryEven.join1{value: bet}(h1);
    vm.prank(p0);
    lotteryEven.reveal0(s0);
    vm.prank(p1);
    lotteryEven.reveal1(s1);

    vm.prank(p0);
    lotteryOdd.join0{value: bet}(h0);
    vm.prank(p1);
    lotteryOdd.join1{value: bet}(h1);
    vm.prank(p0);
    lotteryOdd.reveal0(s0);
    vm.prank(p1);
    lotteryOdd.reveal1(s1);
  }
  function test_win_transaction_env_independent() public {
    vm.warp(100);
    lotteryEven.win();

    vm.warp(101);
    lotteryOdd.win();

    assertEq(lotteryEven.winner(), p0);
    assertEq(lotteryOdd.winner(), p1);
    assertTrue(lotteryEven.winner() != lotteryOdd.winner());
  }
}
