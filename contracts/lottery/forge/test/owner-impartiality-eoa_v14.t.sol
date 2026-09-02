// ANSWER: FALSE
// EXPLANATION: The property is violated by `forceWinner`, whose behavior depends on `msg.sender` through `require(msg.sender == owner)`. In `Join0`, neither `player0` nor `player1` is set, so the owner is a sender satisfying the premise. A successful `forceWinner(w)` changes `winner` and `status`, whereas the same transaction from another EOA reverts and makes no storage changes.
// COUNTEREXAMPLE: Let EOA `A` deploy the contract, so `owner = A`, and leave the contract in `Status.Join0` (`player0 = player1 = address(0)`). EOA `A` calls `forceWinner(B)`, where `B` is any EOA. The call succeeds and changes `winner` to `B` and `status` to `End`. Now make the identical call `forceWinner(B)` from a different EOA `C`; it reverts at `require(msg.sender == owner)`, so it produces no state modifications. Thus the required sender-independent behavior does not hold.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;
import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery_v14.sol";

contract LotteryTest is Test {
  Lottery lottery;
  address owner = makeAddr("owner");
  address other = makeAddr("other");
  address forcedWinner = makeAddr("forcedWinner");

  function setUp() public {
    vm.prank(owner);
    lottery = new Lottery();
  }
  function test_owner_impartiality_eoa() public {
    assertTrue(lottery.status() == Lottery.Status.Join0);
    assertTrue(lottery.status() == Lottery.Status.Join0);

    uint snapshotId = vm.snapshotState();
    
    vm.prank(owner);
    lottery.forceWinner(payable(forcedWinner));

    assertEq(lottery.winner(), forcedWinner);
    assertTrue(lottery.status() == Lottery.Status.End);

    vm.revertToState(snapshotId);

    vm.prank(other);
    vm.expectRevert();
    lottery.forceWinner(payable(forcedWinner));

    assertEq(lottery.winner(), address(0));
    assertTrue(lottery.status() == Lottery.Status.Join0);
  }
}
