// ANSWER: FALSE

// EXPLANATION: In `win()`, the contract correctly computes `winner = compute_winner(player0, player1, secret0, secret1)`, but it transfers only half of the pot to the winner:
// ```solidity
// (bool success,) = winner.call{value: address(this).balance / 2}("");
// ```
// The winner's ETH balance therefore increases by `pot / 2` instead of `pot`, and the contract keeps the other half forever, since `status` is set to `End` and no other function is callable in that state.

// COUNTEREXAMPLE:
// 1. `player0` calls `join0` with commitment to secret `"aa"` (length 2) and deposits `1 ether`.
// 2. `player1` calls `join1` with commitment to secret `"bb"` (length 2) and deposits `1 ether`.
// 3. `player0` reveals `"aa"`.
// 4. `player1` reveals `"bb"`.

// Now `status == Win`, the pot is `2 ether`, and the honest protocol computes:
// * `len("aa") + len("bb") = 2 + 2 = 4` (even),
// * so `expected_winner = player0`.
// 5. An EOA calls `win()`.
// The transaction does not revert and sets `winner = player0`, but transfers only `1 ether` to `player0` while `1 ether` remains locked in the contract. `player0`'s ETH balance increases by half the pot instead of the whole pot, violating the property.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v5.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 1 ether;

  string s0 = "aa";
  string s1 = "bb";

  bytes32 h0;
  bytes32 h1;

  function setUp() public {
    lottery = new Lottery();
    vm.deal(p0, 2 * bet);
    vm.deal(p1, 2 * bet);

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

    vm.prank(p0);
    lottery.win();

    assertEq(lottery.winner(), p0);
    assertEq(address(lottery).balance, bet);
    assertEq(p0.balance, 2 * bet);
    assertEq(p1.balance, bet);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
