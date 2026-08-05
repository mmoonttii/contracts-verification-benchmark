// SPDX-License-Identifier: GPL-3.0-only

// If the contract is in `Reveal1` status and evaluating the fair function on `secret0` and `player1`'s secret that is
// not yet revealed, would result in `player0` being the winner; then a successful `redeem0_noreveal1()` transaction
// strictly increases `player0`'s ETH balance, leaves player1's ETH balance unchanged, and strictly decreases the
// contract's ETH balance.

rule redeem0_noreveal1_fairness {
    env e;
    require _status(e) == 3;
    require e.block.number > currentContract.end_reveal;

    address _p0;
    require _p0 == currentContract.player0;
    require _p0 != currentContract;

    address _p1;
    require _p1 == currentContract.player1;
    require _p1 != currentContract;

    require _p0 != _p1;

    string _s0;
    require _s0 == secret0(e);

    string _s1;
    require hashing(e, _s1) == currentContract.hash1;

    require computeWinner(e, _p0, _p1, _s0, _s1) == _p0;

    mathint p0_pre_bal = nativeBalances[_p0];
    mathint p1_pre_bal = nativeBalances[_p1];
    mathint contract_pre_bal = nativeBalances[currentContract];

    redeem0_noreveal1(e);

    mathint p0_post_bal = nativeBalances[_p0];
    mathint p1_post_bal = nativeBalances[_p1];
    mathint contract_post_bal = nativeBalances[currentContract];

    assert p0_post_bal > p0_pre_bal;
    assert p1_post_bal == p1_pre_bal;
    assert contract_post_bal < contract_pre_bal;
}