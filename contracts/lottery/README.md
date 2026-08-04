# Lottery

## Specification
Consider a lottery where two players bet an equal amount of crypto-currency, and the winner - who is chosen fairly between the two players - redeems the whole pot.

Since smart contract are deterministic and external sources of randomness (e.g., random number oracles) might be biased, to achieve fairness we follow a *commit-reveal-punish* protocol, where both players first commit to the hash of the secret, then reveal their secret (which must be a preimage of the committed hash), and finally the winner is computed as a fair function of the secrets.

Implementing this protocol properly is quite error-prone, since the protocol must punish players who behave dishonestly, e.g. by refusing to perform some required action.
In this case, the protocol must still ensure that, on average, an honest player has at least the same payoff that they would have by interacting with another honest player. 

The protocol followed by (honest) players is the following:
1. `player1` joins the lottery by paying the bet and committing to a secret;
2. `player2` joins the lottery by paying the bet and committing to another secret (the bet is the same for each player)
3. if `player2` has not joined, `player1` can redeem their bet after a given deadline (`end_commit`).
4. `player1` reveals the first secret;
5. if `player1` has not revealed, `player2` can redeem both players' bets after a given deadline (`end_reveal`); 
6. once `player1` has revealed, `player2` reveals the secret;
7. if `player2` has not revealed, `player1` can redeem both players' bets after a given deadline (`end_reveal` plus a fixed constant);
8. once both secrets have been revealed, the winner, who is fairly determined as a function of the two revealed secrets, can redeem the whole pot.

## Properties
- **honest-player-profitability**: For each of the intermediate states `Join1`, `Reveal0`, `Reveal1`, there exists a corresponding non-reverting transaction, made after the state's respective deadline, that strictly increases the eligible honest player's ETH balance by exactly the amount they are owed, leaves the contract's ETH balance at zero, and advances status to `End`
- **honest-player-profitability-eoa**: Assuming player0 and player1 behave as EOAs: for each of the intermediate states `Join1`, `Reveal0`, `Reveal1`, there exists a corresponding non-reverting transaction, made after the state's respective deadline, that strictly increases the eligible honest player's ETH balance by exactly the amount they are owed, leaves the contract's ETH balance at zero, and advances status to `End`
- **honest-protocol-deadlock-freedom**: For each intermediate protocol state `s`, there exists a path to completion of the honest protocol from `s` to `End` that empties the contract's balance to zero
- **no-incentives-to-abort**: After a non-reverting `reveal0(secret)` transaction, if the honest protocol would result in player 1 losing and no `reveal1(s)` transaction is successful before the deadline, the contract guarantees that player 0 can call `redeem0_noreveal1()` and the bets of both players are transferred to player0
- **no-incentives-to-abort-eoa**: After a non-reverting `reveal0(secret)` transaction, where player0 is an EOA, if the honest protocol would result in player 1 losing and no `reveal1(s)` transaction is successful before the deadline, the contract guarantees that player 0 can call `redeem0_noreveal1()` and the bets of both players are transferred to player0
- **one-step-deadlock-freedom**: For each state with a positive balance of the contract, there exist a non-reverting transaction that when executed leaves the contract ETH balance at zero
- **owner-impartiality**: For every non-reverting transaction, from any state where a winner is not yet determined, if the sender of the transaction is `owner` and such transaction changes the state variables of the contract then the same transaction, made by any non-owner address, under completely identical environments and storage, except from `msg.sender` must not revert and produce the same state modifications
- **owner-impartiality-eoa**: Assuming `player0` and `player1` are EOAs: for every non-reverting transaction, from any state where a winner is not yet determined, if the sender of the transaction is `owner` and such transaction changes the state variables of the contract then the same transaction, made by any non-owner address, under completely identical environments and storage, except from `msg.sender` must not revert and produce the same state modifications
- **redeem0-noreveal1-fairness**: If the contract is in `Reveal1` status and evaluating the fair function on `secret0` and `player1`'s secret that is not yet revealed, would result in `player0` being the winner; then a successful `redeem0_noreveal1()` transaction strictly increases `player0`'s ETH balance, leaves player1's ETH balance unchanged, and strictly decreases the contract's ETH balance.
- **redeem0-noreveal1-fairness-eoa**: Assuming `player0` and `player1` behave as EOAs: if the contract is in `Reveal1` status and evaluating the fair function on `secret0` and `player1`'s secret that is not yet revealed, would result in `player0` being the winner; then a successful `redeem0_noreveal1()` transaction strictly increases `player0`'s ETH balance, leaves player1's ETH balance unchanged, and strictly decreases the contract's ETH balance.
- **sequentiality-of-protocol**: For each state-transition function f in the protocol, a transaction call to f will revert if the contract is a earlier state than the one it is meant to transition out of with the function f
- **state-irreversible**: For every non-reverting transaction of the contract's state-transition functions, the contract's `status` after the transaction is strictly greater than its `status` before the call
- **win-transaction-env-independent**: The outcome of a non-reverting `win()` transaction is independent from environment-dependent state
- **winner-computation-env-independent**: The results of evaluating the fair win function are independent from environment-dependent state
- **wrong-preimage-reverts**: If a `reveal*(s)` transaction does not revert, then `s` is a preimage of the committed hash

## Versions
- **v1**: conformant to specification

## Verification data

- [Ground truth](ground-truth.csv)
- [Solcmc/z3](solcmc-z3.csv)
- [Solcmc/Eldarica](solcmc-eld.csv)
- [Certora](certora.csv)

## Experiments
