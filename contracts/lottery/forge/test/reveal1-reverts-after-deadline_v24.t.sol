// ANSWER: FALSE
// EXPLANATION: In this version `reveal1` has no upper deadline: its requirements are only `status == Status.Reveal1`, `msg.sender == player1` and `hashing(s) == hash1`. The check `block.number <= end_reveal1` present in the other versions is missing, so `player1` can still reveal after `end_reveal1` has passed.
// COUNTEREXAMPLE: After both players join and `player0` reveals, the contract is in `Status.Reveal1`. At any block with `block.number > end_reveal1`, `player1` calls `reveal1(s1)` with the correct preimage. All the remaining requirements hold, so the transaction succeeds and moves the contract to `Status.Win`, violating the property.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v24.sol";

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
  function test_reveal1_reverts_after_deadline() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    assertTrue(lottery.status() == Lottery.Status.Reveal1);

    vm.roll(lottery.end_reveal1() + 1);
    assertTrue(block.number > lottery.end_reveal1());

    vm.prank(p1);
    lottery.reveal1(s1);

    assertEq(lottery.secret1(), s1);
    assertTrue(lottery.status() == Lottery.Status.Win);
  }
}
