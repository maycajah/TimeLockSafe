# TimeLockSafe Contract

## Overview
The `TimeLockSafe` contract allows users to deposit STX tokens with a specified lock period, ensuring they can only withdraw them after the lock period has elapsed. This contract ensures security, prevents premature withdrawals, and provides balance-tracking functionality.

## Features
- **Deposit Tokens:** Users can deposit STX tokens and set a lock duration.
- **Time-Locked Withdrawals:** Funds can only be withdrawn after the lock period expires.
- **Balance Tracking:** Users can check their available balance.
- **Lock Period Inquiry:** Users can check when their funds will be available for withdrawal.

## Constants
The contract defines several constants for error handling and validation:

| Constant | Description |
|----------|-------------|
| `ERR_INVALID_DURATION` (u1001) | Lock duration must be greater than zero and within the maximum allowed period. |
| `ERR_INSUFFICIENT_BALANCE` (u1002) | User does not have enough balance for withdrawal. |
| `ERR_EARLY_WITHDRAWAL` (u1003) | Withdrawal attempted before the lock period expires. |
| `ERR_UNAUTHORIZED` (u1004) | Unauthorized action detected. |
| `ERR_OVERFLOW` (u1005) | Overflow detected in lock period calculation. |
| `ERR_INVALID_AMOUNT` (u1006) | Deposit amount must be greater than zero. |

Additionally, the maximum lock duration is set to **52,560 blocks** (approximately one year).

## Data Structures
- **Balances:** Stores the token balance of each user.
- **Lock Periods:** Stores the block height until which funds are locked.

## Functions

### `deposit (amount uint, duration uint) -> (response string)`
Deposits the specified amount of STX tokens and sets a lock duration.
- Validates the amount and duration.
- Transfers STX to the contract.
- Updates the user’s balance and lock period.
- Returns a success message.

### `withdraw (amount uint) -> (response uint)`
Withdraws a specified amount of STX tokens if the lock period has expired.
- Ensures sufficient balance.
- Checks if the lock period has ended.
- Transfers STX to the user.
- Updates the balance and removes the lock period if the balance becomes zero.
- Returns the withdrawn amount.

### `get-balance (user principal) -> (response uint)`
Retrieves the STX balance of a given user.

### `get-unlock-height (user principal) -> (response uint)`
Retrieves the block height at which the user’s funds will be unlocked.

## Usage Example
1. **Deposit Funds**
   ```clarity
   (contract-call? .timelocksafe deposit u10000 u1000)
   ```
2. **Check Balance**
   ```clarity
   (contract-call? .timelocksafe get-balance tx-sender)
   ```
3. **Check Unlock Period**
   ```clarity
   (contract-call? .timelocksafe get-unlock-height tx-sender)
   ```
4. **Withdraw Funds** *(after lock period expires)*
   ```clarity
   (contract-call? .timelocksafe withdraw u10000)
   ```

## Security Considerations
- **Overflow Protection:** Ensures calculations do not exceed limits.
- **Strict Withdrawals:** Funds can only be withdrawn after the lock period.
- **Contract Ownership:** All transactions occur via the contract to prevent unauthorized access.

## License
This contract is open-source and available for use under the MIT License.

