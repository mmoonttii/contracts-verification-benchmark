// SPDX-License-Identifier: GPL-3.0-only

// A transaction call to `reveal1` will revert if the contract is in an earlier state than the one it is meant to
// transition out of

rule sequentiality_of_protocol_reveal1 {
    env e;
    calldataarg args;
    
    require _status(e) < 3;

    reveal1@withrevert(e, args);

    assert lastReverted;
}
