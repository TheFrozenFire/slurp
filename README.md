# ZKAA Private Recipient Address

## Concept

The concept of ZKAA PRA is to generate standardized, efficient consumable recipient addresses for use in
ZKAA (Zero Knowledge Account Abstraction). Zero Knowledge Account Abstraction is a conception of
[Account Abstraction](https://notes.ethereum.org/@vbuterin/account_abstraction_roadmap) which relies upon Zero Knowledge
Proofs to dictate the validity of transactions initiated through a contract wallet acting as an Ethereum EOA.

In an example of such a wallet which pools the balances of multiple users into a single contract (e.g. a hidden merkle
ledger of user balances viz. [Tornado Nova](https://github.com/tornadocash-community/tornado-nova/)), there needs to be
some way for users of that wallet to receive funds without requiring senders to have knowledge of any proprietary
wallet-contract-level addressing scheme, and doesn't require any more gas than the 2300 gas limit of
`address.send`/`address.transfer`.

In other words, users of ZKAA contract wallets need to have recipient addresses which are completely 
backwards compatible with existing Ethereum addresses from a sender's perspective.

A simple way to achieve this is to rely upon how contract addresses are generated using `CREATE2`. Addresses created by
`CREATE2` are predictable and idempotent, taking the deployer address, a random salt, and the contract init code as
parameters to address generation.

Given known init code, a deployer contract whose address is stable, and the use of the salt parameter as a commitment,
a private recipient may generate a contract address which can be provided to a sender. The sender may send assets to
this uninitialized address, to be later collected by the recipient.
