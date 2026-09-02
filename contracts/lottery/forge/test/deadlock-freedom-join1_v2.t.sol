// ANSWER: FALSE
// EXPLANATION: In status `Join1`, the only function that can withdraw the contract’s balance before `status` changes is `redeem0_nojoin1()`. It transfers only `address(this).balance / 2` to `player0`, then sets `status = Status.End`; therefore, for any positive balance, a positive remainder remains (and with a 1-wei balance, it transfers 0). Thus no user transaction can empty the contract balance while remaining in the `Join1` state.
// COUNTEREXAMPLE: Deploy the contract, then have an EOA call `join0(...)` with `msg.value = 0.01 ether`. The contract is now in `Status.Join1` with balance `0.01 ether`. After `block.number > end_join`, the EOA `player0` calls `redeem0_nojoin1()`. The call succeeds and transfers `address(this).balance / 2 = 0.005 ether`, leaving `0.005 ether` in the contract. Hence the balance is not emptied.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v2.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  uint bet = 0.01 ether;

  string s0 = "a";
  bytes32 h0;
  
  function setUp() public {
    lottery = new Lottery();
    vm.deal(p0, 1 ether);
    h0 = lottery.hashing(s0);
  }

  function test_deadlock_freedom_join1() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    assertTrue(lottery.status() == Lottery.Status.Join1);
    assertEq(address(lottery).balance, bet);

    uint256 p0BalanceBefore = p0.balance;

    vm.roll(lottery.end_join() + 1);
    vm.prank(p0);
    lottery.redeem0_nojoin1();

    assertEq(p0.balance, p0BalanceBefore + bet/2);
    assertEq(address(lottery).balance, bet/2);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
