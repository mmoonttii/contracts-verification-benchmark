// SPDX-License-Identifier: GPL-3.0-only

// After a non-reverting `reveal0(secret)` transaction,
// if the honest protocol would result in player 1 losing and no `reveal1(s)` transaction is successful before the deadline,
// the contract guarantees that player 0 can call `redeem0_noreveal1()` and the bets of both players are transferred to player0 

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery --verify Lottery:certora/no-incentives-to-abort.spec --optimistic_hashing
rule no_incentives_to_abort {
    env e_join0;
    env e_join1;
    env e_reveal0;
    env e_redeem;

    address p0 = e_join0.msg.sender;
    address p1 = e_join1.msg.sender;

    require p0 != p1;

    string secret0;
    string secret1;

    bytes32 hash0 = hashing(e_join0, secret0);
    bytes32 hash1 = hashing(e_join1, secret1);

    join0(e_join0, hash0);
    join1(e_join1, hash1);

    require computeWinner(e_reveal0, p0, p1, secret0, secret1) == p0, "Constraint to a situation where p0 is winning";

    require e_reveal0.msg.sender == p0;

    reveal0(e_reveal0, secret0);

    require e_redeem.block.number > currentContract.end_reveal;

    mathint pre_p0_bal = nativeBalances[p0];
    mathint pre_p1_bal = nativeBalances[p1];
    mathint pre_contract_bal = nativeBalances[currentContract];

    redeem0_noreveal1(e_redeem);

    mathint post_p0_bal = nativeBalances[p0];
    mathint post_p1_bal = nativeBalances[p1];
    mathint post_contract_bal = nativeBalances[currentContract];

    assert post_p0_bal == pre_p0_bal + pre_contract_bal;
    assert post_contract_bal == 0;
    assert post_p1_bal == post_p0_bal;
}