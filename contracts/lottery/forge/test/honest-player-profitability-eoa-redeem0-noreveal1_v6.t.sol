// ANSWER: FALSE
// EXPLANATION: In status `Reveal1`, the only post-deadline redemption function is `redeem0_noreveal1()`. After `end_reveal1`, it transfers the entire pot to `player1`, not `player0`, via `player1.call{value: address(this).balance}("")`. It then sets `status = Status.End`. Since `player0 != player1` is enforced by `join1`, this cannot strictly increase `player0`'s balance by the pot.
// COUNTEREXAMPLE: Let EOAs A and B be `player0` and `player1`. After A calls `join0` with a valid hash and at least `MINIMUM_BET`, B calls `join1` with an equal bet and a different hash, and A reveals successfully, the contract reaches `Reveal1` with both bets in its balance. If no reveal by B occurs and a transaction is made at any block `> end_reveal1`, `redeem0_noreveal1()` succeeds and transfers the entire contract balance to B (`player1`), leaving the contract balance zero and status `End`, while A's balance does not increase by the pot.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v6.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 0.01 ether;

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

  function test_honest_player_profitability_eoa_redeem0_noreveal1() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    assertTrue(lottery.status() == Lottery.Status.Reveal1);

    uint256 p0BalanceBefore = p0.balance;
    uint256 p1BalanceBefore = p1.balance;

    vm.roll(lottery.end_reveal1() + 1);
    vm.prank(p0);
    lottery.redeem0_noreveal1();

    assertEq(p0.balance, p0BalanceBefore);
    assertEq(p1.balance, p1BalanceBefore + 2*bet);
    assertEq(address(lottery).balance, 0);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
