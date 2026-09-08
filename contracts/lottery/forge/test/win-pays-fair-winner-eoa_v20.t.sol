// ANSWER: FALSE

// EXPLANATION: In `win()`, the contract correctly computes `winner = compute_winner(player0, player1, secret0, secret1)`, but it transfers the entire pot to `msg.sender` instead of `winner`:
// ```solidity
// winner = compute_winner(player0, player1, secret0, secret1);
// (bool success,) = msg.sender.call{value: address(this).balance}("");
// ```
// There is no requirement that `msg.sender == winner`. Therefore, any EOA can successfully call `win()` and receive the pot, even when the honest protocol determines `player0` or `player1` as the winner.

// COUNTEREXAMPLE:
// 1. `player0` calls `join0` with commitment to secret `"aa"` (length 2) and deposits `1 ether`.
// 2. `player1` calls `join1` with commitment to secret `"bb"` (length 2) and deposits `1 ether`.
// 3. `player0` reveals `"aa"`.
// 4. `player1` reveals `"bb"`.

// Now `status == Win`, the pot is `2 ether`, and the honest protocol computes:
// * `len("aa") + len("bb") = 2 + 2 = 4` (even),
// * so `expected_winner = player0`.
// 5. A third-party EOA (neither `player0` nor `player1`) calls `win()`.
// The transaction does not revert. The contract sets `winner = player0`, but transfers the entire `2 ether` pot to the attacker (`msg.sender`). `player0`'s ETH balance does not increase by the pot, violating the property.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v20.sol";

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

    h0 = lottery.hashing(s0);
    h1 = lottery.hashing(s1);
  }

  function test_win_pays_fair_winner_eoa() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    vm.prank(p1);
    lottery.reveal1(s1);

    assertTrue(lottery.status() == Lottery.Status.Win);
    assertEq(lottery.compute_winner(payable(p0), payable(p1), s0, s1), payable(p0));

    vm.prank(attacker);
    lottery.win();

    assertEq(lottery.winner(), p0);
    assertEq(address(lottery).balance, 0);
    assertEq(attacker.balance, 2 * bet);
    assertEq(p0.balance, 1 ether);
    assertEq(p1.balance, 1 ether);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
