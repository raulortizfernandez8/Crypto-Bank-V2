# Crypto-Bank-V2
This project is a Solidity smart contract that simulates a basic bank to manage Ether (ETH) deposits and withdrawals, with administrative control and fee functions.

# Main Features
Ether Deposits and Withdrawals:
Users can deposit ETH into the contract and withdraw it whenever they want.

Automatic Fees:
Each deposit and withdrawal applies a fee (in basis points) that accrues to the bank.

Maximum Balance Control:
The administrator sets a maximum balance limit for each user.

Centralized Administration:
Only the owner (administrator) can:

Modify the fee applied.

Change the maximum allowed balance.

Pause and resume the contract (emergency mode).

Withdraw accrued fees.

Security:

Smart contract can be stopped and restarted by the admin in case of issues.

Withdraw Ether with CEI pattern so reentrancy is avoided.

Using events to trace deposits and withdrawals
