rule reveal0_reverts_after_deadline {
    env e;
    string s;
    
    require e.block.number > currentContract.end_reveal0;
    reveal0@withrevert(e, s);
    assert lastReverted;
}