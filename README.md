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

## Contract Verification

To verify the deployed contract on Lineascan:

```bash
npm run verify <CONTRACT_ADDRESS>
```

Example:
```bash
npm run verify 0x501e742cf30ece300e3e8cb45a975c15057d5b46
```

## Contract

The main contract is located at `contracts/SumsubPortalV3.sol`.

## Deployment Information

### Linea Mainnet
- **Portal Address**: `0x501e742CF30eCE300E3e8CB45a975c15057D5B46`
- **Deployment Hash**: `0xe59a01413558dc41e47303b753faea3150fca04b0d54cac0397a0e99203e9622`
- **Deployed At**: 2025-07-02T07:55:45.099Z
- **Deployer**: `0x887F94C1283697c607b321860bd95263AC0E2467`
- **Signer Address**: `0x887F94C1283697c607b321860bd95263AC0E2467`
- **Gas Used**: 2,006,150
- **Registration Status**: ✅ Registered in Verax Portal Registry
- **Registration Hash**: `0x83c41a63aa843d7bf09325856c3213a16f90cac32214e4d20309e8d51dcfb745`

## Contract Verification Status

✅ **Contract is verified on Lineascan**

View verified contract: https://lineascan.build/address/0x501e742cf30ece300e3e8cb45a975c15057d5b46

## License

MIT License
