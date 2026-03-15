# Solana Crowdfunding Platform

A decentralized crowdfunding smart contract built on the Solana blockchain using the Anchor framework.

## Overview
This program allows users to:
1.  **Create Campaigns**: Set a funding goal and a deadline.
2.  **Contribute**: Support campaigns by sending SOL.
3.  **Withdraw**: Creators can claim funds if the goal is reached after the deadline.
4.  **Refund**: Donors can reclaim their SOL if the campaign fails to reach its goal.

## Technical Details
- **Brankas (Vault)**: Uses Program Derived Addresses (PDA) for secure fund management.
- **Framework**: Anchor v0.29.0
- **Safety**: Includes owner-only withdrawals and strict goal-validation logic.

## Instructions
- Build: `anchor build`
- Test: `anchor test`
- Deploy: `anchor deploy --provider.cluster devnet`
