# NovaBridge - Decentralized Call Option Smart Contract

## Overview
OptiBridge is a decentralized smart contract facilitating call option transactions between two parties, ensuring **secure, trustless, and automated execution** using the **Vyper** programming language on Ethereum.

## How It Works
- **Party A** deposits a call option into the contract.
- **OptiBridge** (the intermediary) sells the call option to **Party B**.
- If **Party B exercises the option before the expiration date**, the contract transfers the agreed payment to **Party B**.
- If the option is **not exercised by the expiration date**, ownership of the option reverts to **Party A**.

## Features
- **Automated Execution**: Enforces transaction terms via smart contracts.
- **Trustless Transactions**: Eliminates the need for intermediaries.
- **Immutable & Secure**: Uses Ethereum’s blockchain for transparency.
- **Efficient Settlement**: Ensures timely execution of trades.

## Contract Functions
### 1. `__init__(_partyA, _optionPrice, _strikePrice, _endDate)`
Initializes the contract, setting up the call option details.

### 2. `sellOption(_partyB)`
Transfers ownership of the call option to **Party B** after receiving payment.

### 3. `exerciseOption()`
Allows **Party B** to exercise the call option before the expiration date, triggering payments.

### 4. `returnOption()`
Returns the option to **Party A** if it is not exercised before the expiration date.

## Deployment Instructions
1. Deploy the contract on Ethereum with Party A’s details.
2. Use `sellOption()` to transfer the option to a buyer (Party B).
3. Track the **expiration date** to determine if `exerciseOption()` or `returnOption()` should be executed.

## Use Cases
- **Decentralized Finance (DeFi) Options Trading**
- **Automated Derivatives Execution**
- **Blockchain-Based Financial Contracts**

## Future Enhancements
- Support for **multi-asset options**
- Integration with **Layer 2 solutions** for lower gas fees
- Automated **liquidity pools** for option settlements

