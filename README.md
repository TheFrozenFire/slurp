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

## Contract Logic

In this scheme, a PRA would be a gas-optimized smart contract which need not persist longer than its creation, whose
purpose is to transfer the sum of its assets to any address specified by a caller which can prove knowledge of the
preimage of the commitment specified as the contract creation salt.

Assuming a standardized form of this contract, most of the bytecode supplied in the contract initialization would be
linking to an existing on-chain library describing the base contract logic, and providing any parameters for the proof
verification which aren't available natively to the contract and can't be trustlessly supplied by the caller. Any
such parameters would be immutable because they are a part of the bytecode committed to in the contract address -
barring some logic in the contract which somehow sources them from elsewhere.


