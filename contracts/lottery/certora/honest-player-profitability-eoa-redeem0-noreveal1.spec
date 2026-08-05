// SPDX-License-Identifier: GPL-3.0-only

// Assuming player0 and player1 behave as EOAs: for the intermediate state `Reveal1`, there
// exists a corresponding non-reverting transaction, made after the state's respective deadline, that strictly increases
// the eligible honest player's ETH balance by exactly the amount they are owed, leaves the contract's ETH balance at
// zero, and advances status to `End`

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery versions/lib/EOA.sol --verify Lottery:certora/honest-player-profitability-eoa-redeem0-noreveal1.spec --link Lottery:player0=EOA --link Lottery:player1=EOA
rule honest_player_profitability_eoa_redeem0_noreveal1{
    env e;
    require e.msg.value == 0;

    address p0 = currentContract.player0;
    uint256 bet = currentContract.bet_amount;
    require p0 != currentContract;

    mathint p0_bal_pre       = nativeBalances[p0];
    mathint contract_bal_pre = nativeBalances[currentContract];

    require currentContract.status == Lottery.Status.Reveal1;
    require e.block.number > currentContract.end_reveal;
    require contract_bal_pre == 2 * bet;

    redeem0_noreveal1(e);

    assert (
        nativeBalances[p0] == p0_bal_pre + 2 * bet &&
        nativeBalances[currentContract] == 0 &&
        currentContract.status == Lottery.Status.End
    );
}
