rule reveal1_reverts_after_deadline {
    env e;
    string s;
    require e.block.number > currentContract.end_reveal1;
    reveal1@withrevert(e, s);
    assert lastReverted;
}