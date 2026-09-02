// ANSWER: FALSE
// EXPLANATION: In `Reveal1`, `redeem0_noreveal1()` transfers the entire contract balance to `player1`, not `player0`: `player1.call{value: address(this).balance}("")`. Thus a successful call strictly increases `player1`'s balance while leaving `player0`'s balance unchanged. This contradicts the property.
// COUNTEREXAMPLE: Let `player0` join with secret `"a"` and `player1` join with secret `"bcd"`, with equal bets of at least `MINIMUM_BET`. Both hashes differ, and after `reveal0("a")` and `reveal1("bcd")`, the contract is in `Reveal1`. Since `bytes("a").length + bytes("bcd").length = 4` is even, `compute_winner` would select `player0`. After `block.number > end_reveal1`, `player0` (or any EOA) calls `redeem0_noreveal1()`. Assuming `player1` is an EOA, the transfer succeeds: the contract balance strictly decreases and `player1` receives the entire pot, while `player0`'s balance is unchanged.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v6.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 1 ether;

  string s0 = "a";
  string s1 = "bcd";

  bytes32 h0;
  bytes32 h1;

  function setUp() public {
    lottery = new Lottery();
    vm.deal(p0, 2 ether);
    vm.deal(p1, 2 ether);

    h0 = lottery.hashing(s0);
    h1 = lottery.hashing(s1);
  }
  function test_redeem0_noreveal1_fairness_eoa() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    assertTrue(lottery.status() == Lottery.Status.Reveal1);
    assertEq(lottery.compute_winner(payable(p0), payable(p1), s0, s1), payable(p0));

    uint256 p0BalanceBefore = p0.balance;
    uint256 p1BalanceBefore = p1.balance;

    vm.roll(lottery.end_reveal1() + 1);
    vm.prank(p0);
    lottery.redeem0_noreveal1();

    assertEq(address(lottery).balance, 0);
    assertEq(p0.balance, p0BalanceBefore);
    assertEq(p1.balance, p1BalanceBefore + 2 * bet);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
