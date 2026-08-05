// SPDX-License-Identifier: GPL-3.0-only

// For the intermediate protocol state `Win`, there exists a path to completion of the honest protocol from `Win` to `End`
// that empties the contract's balance to zero

rule honest_protocol_deadlock_freedom_win {
    require nativeBalances[currentContract] > 0;
    require currentContract.player0 != currentContract;
    require currentContract.player1 != currentContract;
    require currentContract.player0 != currentContract.player1;

    env e4; 
    require status(e4) == Lottery.Status.Win;
    
    win(e4);

    require status(e4) == Lottery.Status.End;
    satisfy nativeBalances[currentContract] == 0;
}
