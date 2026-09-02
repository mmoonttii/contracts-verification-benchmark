// ANSWER: FALSE
// EXPLANATION: In `Reveal1`, the only balance-affecting function is `redeem0_noreveal1()`, which requires `block.number > end_reveal1` and transfers only `address(this).balance / 2` to `player0`. `win()` can empty the balance, but it requires `status == Win`, which cannot be reached without a successful `reveal1()` by `player1`. Thus, before `end_reveal1`, there are reachable `Reveal1` states with positive balance in which no user transaction can empty the balance.
// COUNTEREXAMPLE: Let `A` call `join0(h0)` with 0.01 ETH and `B` call `join1(h1)` with 0.01 ETH, with `h1 != h0`. Before `end_reveal0`, let `A` successfully call `reveal0(s0)` where `hashing(s0) == h0`. The contract is then in `Reveal1` with balance 0.02 ETH. Before `end_reveal1`, `B` cannot call `reveal1()` unless revealing the correct secret, and `redeem0_noreveal1()` reverts because its deadline has not passed. `reveal0()` also reverts because the status is `Reveal1`. Therefore no user can perform a non-reverting transaction that empties the positive balance.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v4.sol";

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
  
  function test_deadlock_freedom_reveal1() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    assertTrue(lottery.status() == Lottery.Status.Reveal1);
    assertEq(address(lottery).balance, 2 * bet);
    assertTrue(block.number <= lottery.end_reveal1());

    vm.prank(p1);
    vm.expectRevert();
    lottery.reveal1("wrong");

    vm.prank(p0);
    vm.expectRevert();
    lottery.redeem0_noreveal1();

    vm.expectRevert();
    lottery.win();

    assertTrue(lottery.status() == Lottery.Status.Reveal1);
    assertEq(address(lottery).balance, 2*bet);
  }
}
