// SPDX-License-Identifier: GPL-3.0-only

// For the intermediate protocol state `Reveal1`, there exists a path to completion of the honest protocol from `Reveal1` to `End`
// that empties the contract's balance to zero

rule honest_protocol_deadlock_freedom_reveal1 {
    require nativeBalances[currentContract] > 0;
    require currentContract.player0 != currentContract;
    require currentContract.player1 != currentContract;
    require currentContract.player0 != currentContract.player1;

    env e3;
    require status(e3) == Lottery.Status.Reveal1;
    
    env e4; 

    string s1;

    reveal1(e3, s1);
    win(e4);

    require status(e4) == Lottery.Status.End;
    satisfy nativeBalances[currentContract] == 0;
}
