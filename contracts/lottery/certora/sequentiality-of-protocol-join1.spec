// SPDX-License-Identifier: GPL-3.0-only

// A transaction call to `join1` will revert if the contract is in an earlier state than the one it is meant to
// transition out of

rule sequentiality_of_protocol_join1 {
    env e;
    calldataarg args;

    require _status(e) < 1;

    join1@withrevert(e, args);

    assert lastReverted;
}
