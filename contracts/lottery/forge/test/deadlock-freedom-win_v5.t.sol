// ANSWER: FALSE
// EXPLANATION: In status `Win`, the only balance-reducing function is `win()`. It transfers `address(this).balance / 2` to `winner`, then sets `status = Status.End`. Thus, for any positive balance greater than 1 wei, a positive balance remains after the transaction, and no function callable in `End` can drain it.
// COUNTEREXAMPLE: Let EOA A call `join0(hashing("a"))` with 0.01 ETH before `end_join`, and EOA B call `join1(hashing("b"))` with 0.01 ETH before `end_join`. A then calls `reveal0("a")`, and B calls `reveal1("b")` within the reveal deadlines. The contract is now in `Win` with balance 0.02 ETH. Any EOA can call `win()`, but it transfers only `0.02 ether / 2 = 0.01 ether` and leaves 0.01 ETH in the contract while changing status to `End`. No subsequent function can empty that remaining balance.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v5.sol";

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
  
  function test_deadlock_freedom_win() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    vm.prank(p1);
    lottery.join1{value: bet}(h1);

    vm.prank(p0);
    lottery.reveal0(s0);

    vm.prank(p1);
    lottery.reveal1(s1);

    assertTrue(lottery.status() == Lottery.Status.Win);
    assertEq(address(lottery).balance, 2*bet);

    uint256 p0BalanceBefore = p0.balance;
    vm.prank(p0);
    lottery.win();

    assertEq(p0.balance, p0BalanceBefore + bet);
    assertEq(address(lottery).balance, bet);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
