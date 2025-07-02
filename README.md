# Sumsub Linea Portal

Official Sumsub Portal smart contract for identity verification attestations on Linea blockchain using Verax Registry. The contract is designed to work with the Verax Attestation Registry.

## Overview

SumsubPortalV3 is a portal contract that enables Sumsub to create attestations for proof of humanity verification. The contract inherits from Verax's `AbstractPortalV2` and implements Sumsub-specific attestation logic with EIP712 signature verification.

## Dependencies

- **@openzeppelin/contracts**: ^5.3.0
- **@verax-attestation-registry/verax-contracts**: ^10.0.0

## Installation

```bash
npm install
```

## Compilation

```bash
npx hardhat compile
```

## Contract

The main contract is located at `contracts/SumsubPortalV3.sol`.

## License

MIT License
