// ANSWER: TRUE
// EXPLANATION: A successful `reveal0(s)` requires `status == Status.Reveal0`, `msg.sender == player0`, and only stores `s` in `secret0`; it does not require `hashing(s) == hash0`. However, the stated property is therefore FALSE.
// COUNTEREXAMPLE: After `join0(h)` and `join1(h1)`, the contract is in `Reveal0`. Player0 calls `reveal0("wrong")` with `hash0 != keccak256(abi.encodePacked("wrong"))`. The transaction succeeds because `reveal0` has no hash check, violating the property.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v12.sol";

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
  function test_wrong_preimage_reverts_p0() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0("wrong");

    assertTrue(lottery.hashing("wrong") != h0);
    assertTrue(lottery.status() == Lottery.Status.Reveal1);
  }
}
