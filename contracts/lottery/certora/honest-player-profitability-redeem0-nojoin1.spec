// SPDX-License-Identifier: GPL-3.0-only

// For the intermediate state `Join1`, there exists a corresponding non-reverting
// transaction, made after the state's respective deadline, that strictly increases the eligible honest player's ETH
// balance by exactly the amount they are owed, leaves the contract's ETH balance at zero, and advances status to `End`

rule honest_player_profitability_redeem0_nojoin1(env e) {
    require e.msg.value == 0;

    address p0 = currentContract.player0;
    uint256 bet = currentContract.bet_amount;
    require p0 != currentContract;

    mathint p0_bal_pre       = nativeBalances[p0];
    mathint contract_bal_pre = nativeBalances[currentContract];

    require currentContract.status == Lottery.Status.Join1;
    require e.block.number > currentContract.end_join;
    require contract_bal_pre  == bet;

    redeem0_nojoin1(e);

    assert (
        nativeBalances[p0] == p0_bal_pre + bet &&
        nativeBalances[currentContract] == 0 &&
        currentContract.status == Lottery.Status.End
    );
}
