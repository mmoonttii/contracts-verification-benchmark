// Assuming `player0` and `player1` are EOAs: for every non-reverting transaction, from any state where a winner is not
// yet determined, if the sender of the transaction is `owner` and such transaction changes the state variables of the
// contract then the same transaction, made by any non-owner address, under completely identical environments and
// storage, except from `msg.sender` must not revert and produce the same state modifications  

/// @custom:run certoraRun versions/Lottery_v1.sol:Lottery versions/lib/EOA.sol --verify Lottery:certora/owner-impartiality.spec --optimistic_hashing --link Lottery:player0=EOA --link Lottery:player1=EOA
rule owner_impartiality(method f)
filtered {
    f -> !f.isView && !f.isPure
} {
    address ownerAddr = currentContract.owner;
    require ownerAddr != currentContract;
    require ownerAddr != 0;
    
    address p0 = currentContract.player0;
    require p0 != currentContract;
    require p0 != ownerAddr;

    address p1 = currentContract.player1;
    require p1 != currentContract;
    require p1 != ownerAddr;

    require p0 != p1;


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
    bytes32 h0_before = currentContract.hash0;
    bytes32 h1_before = currentContract.hash1;
    uint ej_before    = currentContract.end_join;
    uint er_before    = currentContract.end_reveal;
    address w_before  = currentContract.winner;
    string s0_before  = secret0(eOwner);
    string s1_before  = secret1(eOwner);

    // owner attempts the call from the initial snapshot
    f(eOwner, args) at initStorage;

    bool ownerChangedState =
        h0_before != currentContract.hash0      ||
        h1_before != currentContract.hash1      ||
        ej_before != currentContract.end_join   ||
        er_before != currentContract.end_reveal ||
        w_before  != currentContract.winner     ||
        s0_before != secret0(eOwner)            ||
        s1_before != secret1(eOwner);

    // replay the exact same call, from the same snapshot, but as a non-owner
    f@withrevert(eOther, args) at initStorage;

    bool otherCouldRunFun = !lastReverted;

    bool otherChangedState =
        h0_before != currentContract.hash0      ||
        h1_before != currentContract.hash1      ||
        ej_before != currentContract.end_join   ||
        er_before != currentContract.end_reveal ||
        w_before  != currentContract.winner     ||
        s0_before != secret0(eOther)            ||
        s1_before != secret1(eOther);

    assert ownerChangedState => (otherCouldRunFun && otherChangedState);
}