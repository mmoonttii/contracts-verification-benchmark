// SPDX-License-Identifier: GPL-3.0-only

// A transaction call to `reveal0` will revert if the contract is in an earlier state than the one it is meant to
// transition out of

rule sequentiality_of_protocol_reveal0 {
    env e;
    calldataarg args;
    
    require _status(e) < 2;

    reveal0@withrevert(e, args);

    assert lastReverted;
}
