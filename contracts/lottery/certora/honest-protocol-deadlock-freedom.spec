// SPDX-License-Identifier: GPL-3.0-only

// For each intermediate protocol state `s`, there exists a path to completion of the honest protocol from `s` to `End`
// that empties the contract's balance to zero

rule honest_protocol_deadlock_freedom_join1 {
    require nativeBalances[currentContract] > 0;
    require currentContract.player0 != currentContract;
    require currentContract.player1 != currentContract;
    require currentContract.player0 != currentContract.player1;

    env e1;
    require status(e1) == Lottery.Status.Join1;
    
    env e2; 
    env e3; 
    env e4; 
    
    bytes32 h1;
    string s0;
    string s1;

    join1(e1, h1);
    reveal0(e2, s0);
    reveal1(e3, s1);
    win(e4);

    require status(e4) == Lottery.Status.End;
    satisfy nativeBalances[currentContract] == 0;
}

rule honest_protocol_deadlock_freedom_reveal0{
    require nativeBalances[currentContract] > 0;
    require currentContract.player0 != currentContract;
    require currentContract.player1 != currentContract;
    require currentContract.player0 != currentContract.player1;

    env e2;
    require status(e2) == Lottery.Status.Reveal0;
    
    env e3; 
    env e4; 
    
    string s0;
    string s1;

    reveal0(e2, s0);
    reveal1(e3, s1);
    win(e4);

    require status(e4) == Lottery.Status.End;
    satisfy nativeBalances[currentContract] == 0;
}

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