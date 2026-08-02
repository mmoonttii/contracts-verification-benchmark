// SPDX-License-Identifier: GPL-3.0-only

// For every non-reverting transaction of the contract's state-transition functions, the contract's `status` after the
// transaction is strictly greater than its `status` before the call

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery --verify Lottery:certora/state-irreversible.spec --optimistic_hashing --optimistic_loop
rule state_irreversible(method f)
filtered {
    f -> (
        f.selector == sig:join0(bytes32).selector ||
        f.selector == sig:join1(bytes32).selector ||
        f.selector == sig:redeem0_nojoin1().selector ||
        f.selector == sig:reveal0(string).selector ||
        f.selector == sig:redeem1_noreveal0().selector ||
        f.selector == sig:reveal1(string).selector ||
        f.selector == sig:redeem0_noreveal1().selector ||
        f.selector == sig:win().selector
    )
} {
    env e;
    calldataarg args;

    mathint pre_status = to_mathint(currentContract.status);

    f(e, args);

    mathint post_status = to_mathint(currentContract.status);

    assert post_status > pre_status;
}