// ANSWER: FALSE
// EXPLANATION: In `Reveal1`, `redeem0_noreveal1` sends the entire contract balance to `msg.sender`, not necessarily to `player0`. The function has no requirement that `msg.sender == player0`. Therefore, a non-reverting EOA other than `player0` can call it, receiving the whole balance while `player0`'s balance remains unchanged.
// COUNTEREXAMPLE: Let `player0 = A`, `player1 = B`, and suppose both players have revealed secrets such that `compute_winner(A, B, secret0, secret1) == A`. The contract is then in `Reveal1` with a positive ETH balance. Before the deadline, `B` (or any other EOA `C != A`) submits `redeem0_noreveal1` after `block.number > end_reveal1`. The call succeeds and transfers `address(this).balance` to `B` (or `C`), then sets `status = End`. Thus `player0`'s ETH balance does not strictly increase, while the contract balance strictly decreases.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v18.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  address attacker = makeAddr("attacker");
  uint bet = 1 ether;

  string s0 = "aa";
  string s1 = "bb";

  bytes32 h0;
  bytes32 h1;

  function setUp() public {
    lottery = new Lottery();
    vm.deal(p0, 2 ether);
    vm.deal(p1, 2 ether);
    vm.deal(attacker, 0);

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

    vm.roll(lottery.end_reveal1() + 1);
    vm.prank(attacker);
    lottery.redeem0_noreveal1();

    assertEq(address(lottery).balance, 0);
    assertEq(attacker.balance, 2 * bet);
    assertEq(p0.balance, 1 ether);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
