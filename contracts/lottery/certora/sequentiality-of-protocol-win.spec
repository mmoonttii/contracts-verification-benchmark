// SPDX-License-Identifier: GPL-3.0-only

// A transaction call to `win` will revert if the contract is in an earlier state than the one it is meant to
// transition out of

rule sequentiality_of_protocol_win {
    env e;
    calldataarg args;
    
    require _status(e) < 4;

    win@withrevert(e, args);

    assert lastReverted;
}
