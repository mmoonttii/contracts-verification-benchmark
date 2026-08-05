// SPDX-License-Identifier: GPL-3.0-only

// For the intermediate protocol state `Join1`, there exists a path to completion of the honest protocol from `Join1` to `End`
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
