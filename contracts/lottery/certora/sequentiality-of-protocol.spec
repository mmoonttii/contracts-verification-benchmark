// SPDX-License-Identifier: GPL-3.0-only

// For each state-transition function `f` in the protocol, a transaction call to `f` will revert if the contract is a
// earlier state than the one it is meant to transition out of with the function `f`

rule sequentiality_of_protocol_join1 {
    env e;
    calldataarg args;

    require _status(e) < 1;

    join1@withrevert(e, args);

    assert lastReverted;
}

rule sequentiality_of_protocol_reveal0 {
    env e;
    calldataarg args;
    
    require _status(e) < 2;

    reveal0@withrevert(e, args);

    assert lastReverted;
}

rule sequentiality_of_protocol_reveal1 {
    env e;
    calldataarg args;
    
    require _status(e) < 3;

    reveal1@withrevert(e, args);

    assert lastReverted;
}

rule sequentiality_of_protocol_win {
    env e;
    calldataarg args;
    
    require _status(e) < 4;

    win@withrevert(e, args);

    assert lastReverted;
}