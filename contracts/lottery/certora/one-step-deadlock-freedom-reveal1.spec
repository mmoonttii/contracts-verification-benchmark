// SPDX-License-Identifier: GPL-3.0-only

// For the Reveal1 state with a positive balance of the contract, there exist a non-reverting transaction that when executed
// leaves the contract ETH balance at zero

rule one_step_deadlock_freedom_reveal1(env e) {
    require nativeBalances[currentContract] > 0;
    require status(e) == Lottery.Status.Reveal1;

    env e2;
    redeem0_noreveal1(e2);

    satisfy nativeBalances[currentContract] == 0;
}
