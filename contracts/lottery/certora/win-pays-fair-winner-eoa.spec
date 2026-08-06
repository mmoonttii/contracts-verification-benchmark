// SPDX-License-Identifier: GPL-3.0-only

// Assuming `player0` and `player1` are EOAs: if the honest protocol would result in `expected_winner` to be the winner
// of the lottery, a non-reverting `win` transaction must increase `expected_winner` ETH balance by the pot

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery versions/lib/EOA.sol --verify Lottery:certora/win-pays-fair-winner-eoa.spec --link Lottery:player0=EOA --link Lottery:player1=EOA --optimistic_hashing
rule win_pays_fair_winner_eoa {
    env e;
    require currentContract.status == Lottery.Status.Win;

    address p0 = currentContract.player0;
    address p1 = currentContract.player1;
    require p0 != p1;
    require p0 != currentContract;
    require p1 != currentContract;

    address expected_winner = computeWinner(e, p0, p1, secret0(e), secret1(e));
    mathint pre_bal_w   = nativeBalances[expected_winner];
    mathint pre_pot = nativeBalances[currentContract];

    win(e);

    assert nativeBalances[expected_winner] == pre_bal_w + pre_pot;
    assert nativeBalances[currentContract] == 0;
}
