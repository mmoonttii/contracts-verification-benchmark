// ANSWER: FALSE
// EXPLANATION: In status `Reveal1` after `end_reveal1`, `redeem0_noreveal1()` is the only deadline-based recovery function, but it sends only `address(this).balance / 2` to `player0`, then sets `status = End`. `win()` can send the entire pot, but it sends it to `winner`, which may be `player1` depending on the revealed secret lengths. Therefore the property does not always hold.
// COUNTEREXAMPLE: `player0` deposits 1 ETH with `join0`, `player1` deposits 1 ETH with `join1`, and both reveal valid secrets with lengths whose sum is odd (e.g. `secret0 = "a"`, `secret1 = ""`). After `end_reveal1`, status is `Reveal1` and the pot is 2 ETH. Calling `redeem0_noreveal1()` sends only 1 ETH to `player0` and leaves 1 ETH in the contract. Calling `win()` instead makes `compute_winner()` select `player1` because the combined length is odd, so the 2 ETH goes to `player1`, not `player0`. Thus no such transaction achieves all three stated conditions.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v4.sol";

contract LotteryTest is Test {
  Lottery lottery1;
  Lottery lottery2;

  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 1 ether;

  string s0 = "a";
  string s1 = "";

  bytes32 h0Even;
  bytes32 h1Even;
  bytes32 h0Odd;
  bytes32 h1Odd;

  function setUp() public {
    vm.deal(p0, 2 ether);
    vm.deal(p1, 2 ether);
    lottery1 = new Lottery();
    lottery2 = new Lottery(); 
  }

  function test_honest_player_profitability_eoa_redeem0_noreveal1() public {
    h0Even = lottery1.hashing(s0);
    h1Even = lottery1.hashing(s1);
    h0Odd = lottery2.hashing(s0);
    h1Odd = lottery2.hashing(s1);

    vm.startPrank(p0);
    lottery1.join0{value: bet}(h0Even);
    lottery2.join0{value: bet}(h0Odd);

    vm.startPrank(p1);
    lottery1.join1{value: bet}(h1Even);
    lottery2.join1{value: bet}(h1Odd);

    vm.stopPrank();

    uint snapshotId = vm.snapshotState();

    vm.prank(p0);
    lottery1.reveal0(s0);

    assertTrue(lottery1.status() == Lottery.Status.Reveal1);
    assertEq(address(lottery1).balance, 2*bet);

    uint256 p0BalanceBefore = p0.balance;
    vm.roll(lottery1.end_reveal1() + 1);

    vm.prank(p0);
    lottery1.redeem0_noreveal1();

    // Lottery 1 transfers half the balance
    assertEq(p0.balance, p0BalanceBefore + 1 ether);
    assertEq(address(lottery1).balance, 1 ether);
    assertTrue(lottery1.status() == Lottery.Status.End);
    
    vm.revertToState(snapshotId);

    vm.prank(p0);
    lottery2.reveal0(s0);

    vm.prank(p1);
    lottery2.reveal1(s1);

    assertTrue(lottery2.status() == Lottery.Status.Win);
    assertEq(lottery2.compute_winner(payable(p0), payable(p1), s0, s1), p1);

    uint256 p1BalanceBefore = p1.balance;
    vm.prank(p0);
    lottery2.win();

    // Lottery 2 transfers full balance
    assertEq(p1.balance, p1BalanceBefore + 2*bet);
    assertEq(address(lottery2).balance, 0);
    assertTrue(lottery2.status() == Lottery.Status.End);
  }
}
