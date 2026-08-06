// SPDX-License-Identifier: GPL-3.0-only

// For the intermediate protocol state `Reveal0`, there exists a path to completion of the honest protocol from `Reveal0` to `End`
// that empties the contract's balance to zero

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery versions/lib/EOA.sol --verify Lottery:certora/honest-protocol-deadlock-freedom-reveal0.spec --optimistic_loop
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
