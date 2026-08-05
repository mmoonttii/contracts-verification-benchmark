// SPDX-License-Identifier: GPL-3.0-only

// For the Join1 state with a positive balance of the contract, there exist a non-reverting transaction that when executed
// leaves the contract ETH balance at zero

rule one_step_deadlock_freedom_join1(env e) {
    require nativeBalances[currentContract] > 0;
    require status(e) == Lottery.Status.Join1;

    env e2;
    redeem0_nojoin1(e2);

    satisfy nativeBalances[currentContract] == 0;
}
