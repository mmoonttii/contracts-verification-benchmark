// SPDX-License-Identifier: GPL-3.0-only

// For the Win state with a positive balance of the contract, there exist a non-reverting transaction that when executed
// leaves the contract ETH balance at zero

rule one_step_deadlock_freedom_win(env e) {
    require nativeBalances[currentContract] > 0;
    require status(e) == Lottery.Status.Win;

    env e2;
    win(e2);

    satisfy nativeBalances[currentContract] == 0;
}
