// SPDX-License-Identifier: GPL-3.0-only

// For every non-reverting transaction, from any state where a winner is not yet determined, if the sender of the transaction is `owner` and such transaction changes the state variables of the contract then the same transaction, made by any non-owner address, under completely identical environments and storage, except from `msg.sender` must not revert and produce the same state modifications  

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery --verify Lottery:certora/owner-impartiality.spec --optimistic_hashing --optimistic_loop
rule owner_impartiality(method f)
filtered {
    f -> !f.isView && !f.isPure
} {
    address ownerAddr = currentContract.owner;
    require ownerAddr != currentContract;
    require ownerAddr != 0;

    address p0_pre = currentContract.player0;
    require p0_pre != currentContract;
    require p0_pre != ownerAddr;
    require p0_pre != 0;

    address p1_pre = currentContract.player1;
    require p1_pre != currentContract;
    require p1_pre != ownerAddr;
    require p1_pre != 0;

    require p0_pre != p1_pre;

    env eOwner;
    require eOwner.msg.sender == ownerAddr;

    env eOther;
    require eOther.msg.sender != ownerAddr;
    require eOther.msg.sender != currentContract;
    require eOther.msg.sender != 0;

    // the only difference between the two envs is the caller
    require eOther.block.number == eOwner.block.number;
    require eOther.block.timestamp == eOwner.block.timestamp;
    require eOther.msg.value == eOwner.msg.value;

    calldataarg args;
    
    require currentContract.winner == 0;
    // Save storage status, so that same call can be repeated
    storage initStorage = lastStorage;

    // contract state before
    uint status_pre = _status(eOwner);
    mathint bet_pre = currentContract.bet_amount;
    bytes32 h0_pre  = currentContract.hash0;
    bytes32 h1_pre  = currentContract.hash1;
    uint ej_pre     = currentContract.end_join;
    uint er_pre     = currentContract.end_reveal;
    uint rd_pre     = currentContract.redeem_deadline;
    address w_pre   = currentContract.winner;
    mathint bal_pre = nativeBalances[currentContract];
    string s0_pre;
    string s1_pre;
    require s0_pre == secret0(eOwner);
    require s1_pre == secret1(eOwner); 

    // owner attempts the call from the initial snapshot
    f(eOwner, args) at initStorage;

    bool ownerChangedState =
        status_pre != _status(eOwner)                 ||
        p0_pre     != currentContract.player0         || 
        p1_pre     != currentContract.player1         ||
        bet_pre    != currentContract.bet_amount      ||
        h0_pre     != currentContract.hash0           ||
        h1_pre     != currentContract.hash1           ||
        ej_pre     != currentContract.end_join        ||
        er_pre     != currentContract.end_reveal      ||
        rd_pre     != currentContract.redeem_deadline ||
        w_pre      != currentContract.winner          ||
        bal_pre    != nativeBalances[currentContract] ||
        s0_pre     != secret0(eOwner)                 ||
        s1_pre     != secret1(eOwner);

    // replay the exact same call, from the same snapshot, but as a non-owner
    f@withrevert(eOther, args) at initStorage;

    bool otherCouldRunFun = !lastReverted;

    bool otherChangedState =
        status_pre != _status(eOther)                 ||
        p0_pre     != currentContract.player0         || 
        p1_pre     != currentContract.player1         ||
        bet_pre    != currentContract.bet_amount      ||
        h0_pre     != currentContract.hash0           ||
        h1_pre     != currentContract.hash1           ||
        ej_pre     != currentContract.end_join        ||
        er_pre     != currentContract.end_reveal      ||
        rd_pre     != currentContract.redeem_deadline ||
        w_pre      != currentContract.winner          ||
        bal_pre    != nativeBalances[currentContract] ||
        s0_pre     != secret0(eOther)                 ||
        s1_pre     != secret1(eOther);

    assert ownerChangedState => (otherCouldRunFun && otherChangedState);
}