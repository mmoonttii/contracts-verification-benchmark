// ANSWER: FALSE
// EXPLANATION: In status `Join1`, the only post-deadline redemption function is `redeem0_nojoin1()`. It sends `address(this).balance / 2` to `player0`, not exactly `bet_amount`, and then sets `status = Status.End`. Since the contract normally holds exactly `bet_amount` at this point, `player0` receives only half the bet and the contract retains the other half. Thus the stated property is not always satisfied.
// COUNTEREXAMPLE: Let an EOA A call `join0(h)` with `msg.value = 0.01 ether` before `end_join`, making `player0 = A`, `bet_amount = 0.01 ether`, and `status = Join1`. After `block.number > end_join`, A calls `redeem0_nojoin1()`. The call succeeds, but `player0` receives `address(this).balance / 2 = 0.005 ether`, while the contract retains `0.005 ether`. Therefore the received amount is not exactly the bet and the contract balance is not zero.

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
  
  function test_honest_player_profitability_eoa_redeem0_nojoin1() public {
    vm.prank(p0);
    lottery.join0{value: bet}(h0);

    assertTrue(lottery.status() == Lottery.Status.Join1);
    assertEq(lottery.bet_amount(), bet);

    uint256 p0BalanceBefore = p0.balance;

    vm.roll(lottery.end_join() + 1);
    vm.prank(p0);
    lottery.redeem0_nojoin1();

    assertEq(p0.balance, p0BalanceBefore + bet/2);
    assertEq(address(lottery).balance, bet/2);
    assertTrue(lottery.status() == Lottery.Status.End);
  }
}
