// SPDX-License-Identifier: GPL-3.0-only

// For the Reveal0 state with a positive balance of the contract, there exist a non-reverting transaction that when executed
// leaves the contract ETH balance at zero

rule one_step_deadlock_freedom_reveal0(env e) {
    require nativeBalances[currentContract] > 0;
    require status(e) == Lottery.Status.Reveal0;

    env e2;
    redeem1_noreveal0(e2);

    satisfy nativeBalances[currentContract] == 0;
}
