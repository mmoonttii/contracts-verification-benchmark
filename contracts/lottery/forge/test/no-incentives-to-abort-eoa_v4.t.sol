// ANSWER: FALSE
// EXPLANATION: After a successful `reveal0`, the contract enters `Status.Reveal1`. If `reveal1` is not performed before `end_reveal1`, the only redemption function is `redeem0_noreveal1`, which sends only `address(this).balance / 2` to `player0`, not the whole pot. Thus `player0` cannot redeem the entire pot.
// COUNTEREXAMPLE: Let `player0` and `player1` each join with `bet_amount = 1 ether`, and let `reveal0` succeed. The contract then holds 2 ETH and has status `Reveal1`. Suppose no `reveal1` is performed and a transaction occurs after `end_reveal1`. `player0` calls `redeem0_noreveal1()`. The function transfers `address(this).balance / 2 = 1 ether` to `player0` and sets status to `End`, leaving 1 ETH in the contract. Therefore, the stated property is violated.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v4.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address p0 = makeAddr("p0");
  address p1 = makeAddr("p1");
  uint bet = 1 ether;

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
    assertEq(address(lottery).balance, 2*bet);

    uint256 p0_balance_before = p0.balance;

    vm.roll(lottery.end_reveal1() + 1);
    vm.prank(p0);
    lottery.redeem0_noreveal1();

    assertEq(p0.balance, p0_balance_before + bet);
    assertEq(address(lottery).balance, bet);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
