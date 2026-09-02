// ANSWER: FALSE
// EXPLANATION: After a non-reverting `reveal0`, the contract enters `Status.Reveal1`. If `reveal1` is not performed before `end_reveal1`, `redeem0_noreveal1()` is callable after the deadline, but it sends the entire pot to `player1`, not `player0`. Thus `player0` has no function that lets them redeem the pot in this state.
// COUNTEREXAMPLE: Let EOAs A and B be `player0` and `player1`. A calls `join0(h0)` with 0.01 ETH, B calls `join1(h1)` with 0.01 ETH, and A calls `reveal0(s0)` where `hashing(s0) == h0`. This transaction succeeds and sets `status = Reveal1`. B never calls `reveal1`. After `block.number > end_reveal1`, A cannot call `redeem0_noreveal1()` because that function transfers `address(this).balance` to `player1` (B), then ends the lottery. Hence A cannot redeem the pot.

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
    vm.deal(p0, 2 ether);
    vm.deal(p1, 2 ether);

    h0 = lottery.hashing(s0);
    h1 = lottery.hashing(s1);
  }
  function test_no_incentives_to_abort_eoa() public {
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

    assertEq(address(lottery).balance, 0);
    assertEq(p0.balance, p0BalanceBefore);
    assertEq(p1.balance, p1BalanceBefore + 2*bet);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
