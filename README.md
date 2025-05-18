# Exchange Office

## Solidity scan results

All the issues are either false positives or can't be fixed without raising other issues.

### SolidityScan Report: `OzushExchangeOffice.sol`

| # | Name                                  | Severity       | Confidence | Description                                                                                                                                                                                                                                                                                                           | Remediation |
|---|---------------------------------------|----------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| 1 | Incorrect Access Control              | **Critical**   | 1          | Access control plays an important role in the segregation of privileges in smart contracts. If misconfigured, it may lead to loss of funds or compromise of the contract. The contract imports an access control library, but a function is missing the appropriate modifier.                                      | Not Available |
| 2 | Missing Indexed Keywords in Events    | Informational  | 2          | Events without `indexed` keywords reduce off-chain filtering efficiency. Indexed parameters help in log filtering and improve event tracking.                                                                                                                                                                        | Not Available |
| 3 | In-line Assembly Detected             | Informational  | 2          | Inline assembly bypasses safety checks in Solidity. Misuse may introduce critical vulnerabilities. Should be used only when necessary and with caution.                                                                                                                   | Not Available |
| 4 | Storage Variable Caching in Memory    | Gas            | 0          | Multiple reads of the same storage variable in a function are inefficient. SLOAD is expensive. Suggest caching in memory. <br>**Lines**: 46:56, 93:102, 104:117                                                                                                               | Cache storage reads in memory |
| 5 | Cheaper Inequalities in `require()`   | Gas            | 1          | Using non-strict inequalities (>=, <=) is costlier than strict ones (>, <) inside `require` statements. <br>**Lines**: 52:52, 68:68, 96:96                                                                                                                                    | Use strict inequalities where possible |
| 6 | Avoid Zero-to-One Storage Writes      | Gas            | 2          | Writing from zero to non-zero in storage is costly (22,100 gas). OpenZeppelin’s ReentrancyGuard avoids this using non-zero defaults (1 and 2). <br>**Lines**: 35:35, 36:36, 109:109, 113:113                                                                                  | Use non-zero initial values to avoid costly writes |
| 7 | Cache `address(this)` When Reused     | Gas            | 0          | Repeated use of `address(this)` increases gas costs unnecessarily. <br>**Lines**: 52:52, 64:64, 96:96                                                                                                                                                                        | Cache `address(this)` to a local variable |

#### Scan Summary

  Lines Analyzed: 98

  Scan Score: 74.49

  Issue Distribution: { "critical": 2, "gas": 13, "high": 0, "informational": 2, "low": 0, "medium": 0 }

## Deployment Guide

### Prerequisites

- https://remix.ethereum.org

### Files

Ensure both `OzushExchangeOffice.sol` and `OzushToken.sol` are present in your project. If using Remix, import them from your local GitHub repository or paste them manually.

### Remix Setup

1. Open Remix (https://remix.ethereum.org)
2. Load both contract files into the workspace
3. Set Solidity compiler to version `0.8.29`
4. Compile both contracts

### Test deployment on Sepolia

#### Token

https://sepolia.etherscan.io/token/0x9b4940f11cc8149c5a8bb3d92e3f064d65c82c77

#### Exchange Office

https://sepolia.etherscan.io/address/0xb9A3A195742112176032e2bd4c1cA82C1b2E7e3f


### Deploy Contracts in VM on Remix

#### 1. Deploy OzushToken

- Environment: Remix VM (Cancun)
- Contract: `OzushToken`
- Deploy
- Save the deployed address

#### 2. Deploy OzushExchangeOffice

- Contract: `OzushExchangeOffice`
- Constructor arguments:
  - `initialOwner`: your wallet address
  - `_token`: address of deployed OzushToken
  - `_buyRate`: e.g., `1000000000000000000` (1 OZH == 1 ETH)
  - `_sellRate`: e.g., `900000000000000000`
- Deploy

### Post Deployment

- Preload the OzushExchangeOffice with ETH and OZH
- Use public functions for testing:
  - `buyTokens()`
  - `sellTokens(uint256)`
  - `withdrawETH()`
  - `withdrawTokens()`
  - `updateRates()`
  - `pause()` / `unpause()`
