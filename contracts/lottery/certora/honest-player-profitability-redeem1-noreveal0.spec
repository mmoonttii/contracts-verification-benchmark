// SPDX-License-Identifier: GPL-3.0-only

// For the intermediate state `Reveal0`, there exists a corresponding non-reverting
// transaction, made after the state's respective deadline, that strictly increases the eligible honest player's ETH
// balance by exactly the amount they are owed, leaves the contract's ETH balance at zero, and advances status to `End`

rule honest_player_profitability_redeem1_noreveal0(env e) {
    require e.msg.value == 0;

    address p1 = currentContract.player1;
    uint256 bet = currentContract.bet_amount;
    require p1 != currentContract;

    mathint p1_bal_pre       = nativeBalances[p1];
    mathint contract_bal_pre = nativeBalances[currentContract];

    require currentContract.status == Lottery.Status.Reveal0;
    require e.block.number > currentContract.end_reveal;
    require contract_bal_pre == 2 * bet;

    redeem1_noreveal0(e);

    assert (
        nativeBalances[p1] == p1_bal_pre + 2 * bet &&
        nativeBalances[currentContract] == 0 &&
        currentContract.status == Lottery.Status.End
    );
}
