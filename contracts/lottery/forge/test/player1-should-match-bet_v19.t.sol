// ANSWER: FALSE
// EXPLANATION: `join1` only requires `msg.value >= MINIMUM_BET`; it never requires `msg.value == bet_amount` (the amount stored by `join0`). Therefore a `join1` transaction can succeed with a different bet.
// COUNTEREXAMPLE: `player0` calls `join0(h0)` with `msg.value = 0.01 ether`, so `bet_amount = 0.01 ether`. A different EOA then calls `join1(h1)` with `msg.value = 0.02 ether`, where `h1 != h0`. All `join1` requirements pass, so the transaction does not revert even though `msg.value != bet_amount`.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v19.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint p0_bet = 0.01 ether;
  uint p1_bet = 2*p0_bet;

  string s0 = "a";
  string s1 = "b";

  bytes32 h0;
  bytes32 h1;

  function setUp() public {
    lottery = new Lottery();
    vm.deal(p0, 1 ether);
    vm.deal(p1, 1 ether);

    h0 = lottery.hashing(s0);
    h1 = lottery.hashing(s1);
  }
  function test_player1_should_match_bet() public {
    vm.prank(p0);
    lottery.join0{value: p0_bet}(h0);

    assertEq(lottery.bet_amount(), p0_bet);

    vm.prank(p1);
    lottery.join1{value: p1_bet}(h1);

    assertTrue(lottery.status() == Lottery.Status.Reveal0);
    assertEq(address(lottery).balance, p1_bet + p0_bet);
    assertTrue(p1_bet != lottery.bet_amount());
  }
}
