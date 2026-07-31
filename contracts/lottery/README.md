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
- **no-incentives-to-abort**: After a non-reverting `reveal0(secret)` transaction, if the honest protocol would result in player 1 losing and no `reveal1(s)` transaction is successful before the deadline, the contract guarantees that player 0 can call `redeem0_noreveal1()` and the bets of both players are transferred to player0
- **no-incentives-to-abort-eoa**: After a non-reverting `reveal0(secret)` transaction, where player0 is an EOA, if the honest protocol would result in player 1 losing and no `reveal1(s)` transaction is successful before the deadline, the contract guarantees that player 0 can call `redeem0_noreveal1()` and the bets of both players are transferred to player0

## Versions
- **v1**: conformant to specification

## Verification data

- [Ground truth](ground-truth.csv)
- [Solcmc/z3](solcmc-z3.csv)
- [Solcmc/Eldarica](solcmc-eld.csv)
- [Certora](certora.csv)

## Experiments
