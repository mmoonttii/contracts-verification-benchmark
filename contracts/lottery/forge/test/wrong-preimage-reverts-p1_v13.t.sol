// ANSWER: TRUE
// EXPLANATION: `reveal1(s)` can succeed only when `status == Reveal1`, which is reached after `reveal0` has verified `hashing(s0) == hash0`. However, `reveal1` itself does not check `hashing(s) == hash1`; therefore the property is FALSE.
// COUNTEREXAMPLE: Player 0 commits `hash0 = hashing("a")`, player 1 joins with `hash1 = hashing("b")`, and player 0 successfully calls `reveal0("a")`. The contract enters `Reveal1`. Player 1 can then call `reveal1("c")`, where `hashing("c") != hash1`; the call succeeds because `reveal1` has no hash check.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v13.sol";

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
  function test_wrong_preimage_reverts_p1() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    assertTrue(lottery.status() == Lottery.Status.Reveal1);
    assertTrue(lottery.hashing("c") != h1);

    vm.prank(p1);
    lottery.reveal1("c");

    assertEq(lottery.secret1(), "c");
    assertTrue(lottery.status() == Lottery.Status.Win);
  }
}
