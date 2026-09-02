// ANSWER: FALSE
// EXPLANATION: In this version `reveal0` has no upper deadline: its requirements are only `status == Status.Reveal0`, `msg.sender == player0` and `hashing(s) == hash0`. The check `block.number <= end_reveal0` present in the other versions is missing, so `player0` can still reveal after `end_reveal0` has passed.
// COUNTEREXAMPLE: After both players join, the contract is in `Status.Reveal0`. At any block with `block.number > end_reveal0`, `player0` calls `reveal0(s0)` with the correct preimage. All the remaining requirements hold, so the transaction succeeds and moves the contract to `Status.Reveal1`, violating the property.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v23.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 1 ether;

  string s0 = "a";
  string s1 = "b";

  bytes32 h0;
  bytes32 h1;

  function setUp() public {
    lottery = new Lottery();
    vm.deal(p0, 2 * bet);
    vm.deal(p1, 2 * bet);

    h0 = lottery.hashing(s0);
    h1 = lottery.hashing(s1);
  }
  function test_reveal0_reverts_after_deadline() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    assertTrue(lottery.status() == Lottery.Status.Reveal0);

    vm.roll(lottery.end_reveal0() + 1);
    assertTrue(block.number > lottery.end_reveal0());

    vm.prank(p0);
    lottery.reveal0(s0);

    assertEq(lottery.secret0(), s0);
    assertTrue(lottery.status() == Lottery.Status.Reveal1);
  }
}
