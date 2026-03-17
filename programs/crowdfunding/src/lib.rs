use anchor_lang::prelude::*;
use anchor_lang::solana_program::{
    clock::Clock,
    program::{invoke_signed},
    system_instruction,
};

declare_id!("CYunzofmkHK7gVcchq7JsvdtkMNkKy9W7pN3VkbzUBuY");

#[program]
pub mod crowdfunding {
    use super::*;

    /// Creates a new crowdfunding campaign.
    /// @param goal - Target amount in lamports.
    /// @param deadline - Unix timestamp for campaign end.
    pub fn create_campaign(ctx: Context<CreateCampaign>, goal: u64, deadline: i64) -> Result<()> {
        let campaign = &mut ctx.accounts.campaign;
        let clock = Clock::get()?;
        let current_time = clock.unix_timestamp;

        // Requirement: Validate deadline is in the future
        require!(deadline > current_time, ErrorCode::DeadlineInPast);

        campaign.creator = *ctx.accounts.creator.key;
        campaign.goal = goal;
        campaign.deadline = deadline;
        campaign.raised = 0;
        campaign.claimed = false;

        // Log requirement: "Campaign created: goal={goal}, deadline={deadline}"
        msg!("Campaign created: goal={}, deadline={}", goal, deadline);
        Ok(())
    }

    /// Allows a donor to contribute SOL to a campaign.
    /// @param amount - How much to donate in lamports.
    pub fn contribute(ctx: Context<Contribute>, amount: u64) -> Result<()> {
        let campaign = &mut ctx.accounts.campaign;
        let contribution = &mut ctx.accounts.contribution;
        let clock = Clock::get()?;
        let current_time = clock.unix_timestamp;

        // CRITICAL FIX: Prevent contributions after deadline
        require!(current_time < campaign.deadline, ErrorCode::CampaignEnded);
        
        // WARNING FIX: Prevent zero-amount contributions
        require!(amount > 0, ErrorCode::ZeroAmount);
        
        // EXTRA SAFETY: Prevent contributions if already claimed
        require!(!campaign.claimed, ErrorCode::AlreadyClaimed);

        // Requirement: Transfer SOL from donor to campaign vault (PDA)
        let cpi_accounts = anchor_lang::system_program::Transfer {
            from: ctx.accounts.donor.to_account_info(),
            to: ctx.accounts.vault.to_account_info(),
        };
        let cpi_program = ctx.accounts.system_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        
        anchor_lang::system_program::transfer(cpi_ctx, amount)?;

        // Update state with safe arithmetic
        campaign.raised = campaign.raised.checked_add(amount).ok_or(ErrorCode::Overflow)?;
        
        if contribution.amount == 0 {
            contribution.donor = ctx.accounts.donor.key();
        }
        contribution.amount = contribution.amount.checked_add(amount).ok_or(ErrorCode::Overflow)?;

        // Log requirement: "Contributed: {amount} lamports, total={raised}"
        msg!("Contributed: {} lamports, total={}", amount, campaign.raised);
        Ok(())
    }

    /// Allows the creator to claim funds if goal is reached after deadline.
    pub fn withdraw(ctx: Context<Withdraw>) -> Result<()> {
        let campaign = &mut ctx.accounts.campaign;
        let clock = Clock::get()?;
        let current_time = clock.unix_timestamp;

        // Requirements: raised >= goal, current_time >= deadline, creator check handled by Anchor address constraint
        require!(campaign.raised >= campaign.goal, ErrorCode::GoalNotReached);
        require!(current_time >= campaign.deadline, ErrorCode::CampaignOngoing);
        require!(!campaign.claimed, ErrorCode::AlreadyClaimed);
        
        let vault_lamports = ctx.accounts.vault.to_account_info().lamports();

        // Requirement: Transfer all SOL from vault to creator using invoke_signed for PDA vault
        let campaign_key = campaign.key();
        let bump = ctx.bumps.vault;
        let seeds = &[
            b"vault",
            campaign_key.as_ref(),
            &[bump],
        ];
        let signer = &[&seeds[..]];

        invoke_signed(
            &system_instruction::transfer(
                &ctx.accounts.vault.key(),
                &ctx.accounts.creator.key(),
                vault_lamports,
            ),
            &[
                ctx.accounts.vault.to_account_info(),
                ctx.accounts.creator.to_account_info(),
                ctx.accounts.system_program.to_account_info(),
            ],
            signer,
        )?;

        campaign.claimed = true;
        // Log requirement: "Withdrawn: {amount} lamports"
        msg!("Withdrawn: {} lamports", vault_lamports);
        Ok(())
    }

    /// Allows a donor to get money back if campaign failed after deadline.
    pub fn refund(ctx: Context<Refund>) -> Result<()> {
        let campaign = &mut ctx.accounts.campaign;
        let contribution = &mut ctx.accounts.contribution;
        let clock = Clock::get()?;
        let current_time = clock.unix_timestamp;

        // Requirements: raised < goal, current_time >= deadline
        require!(campaign.raised < campaign.goal, ErrorCode::GoalReachedNoRefund);
        require!(current_time >= campaign.deadline, ErrorCode::CampaignOngoing);
        require!(contribution.amount > 0, ErrorCode::NoContributionFound);

        let amount_to_refund = contribution.amount;

        // Requirement: Transfer donor's contribution back from vault (PDA signed)
        let campaign_key = campaign.key();
        let bump = ctx.bumps.vault;
        let seeds = &[
            b"vault",
            campaign_key.as_ref(),
            &[bump],
        ];
        let signer = &[&seeds[..]];

        invoke_signed(
            &system_instruction::transfer(
                &ctx.accounts.vault.key(),
                &ctx.accounts.donor.key(),
                amount_to_refund,
            ),
            &[
                ctx.accounts.vault.to_account_info(),
                ctx.accounts.donor.to_account_info(),
                ctx.accounts.system_program.to_account_info(),
            ],
            signer,
        )?;

        // WARNING FIX: Keep state consistent
        campaign.raised = campaign.raised.checked_sub(amount_to_refund).ok_or(ErrorCode::Underflow)?;
        contribution.amount = 0;

        // Log requirement: "Refunded: {amount} lamports"
        msg!("Refunded: {} lamports", amount_to_refund);
        Ok(())
    }

    /// INNOVATION: Allows the creator to close the campaign account and reclaim rent
    /// after the campaign is finished (claimed or expired).
    pub fn close_campaign(ctx: Context<CloseCampaign>) -> Result<()> {
        let campaign = &ctx.accounts.campaign;
        let clock = Clock::get()?;
        let current_time = clock.unix_timestamp;

        // Allow closing if:
        // 1. Funds were successfully claimed
        // 2. OR Campaign failed and enough time has passed (e.g., 30 days after deadline)
        let can_close = campaign.claimed || (current_time > campaign.deadline + 2592000 && campaign.raised < campaign.goal);
        
        require!(can_close, ErrorCode::CannotCloseYet);

        msg!("Campaign closed by creator. Rent reclaimed.");
        Ok(())
    }
}

#[derive(Accounts)]
pub struct CreateCampaign<'info> {
    #[account(
        init, 
        payer = creator, 
        space = 8 + 32 + 8 + 8 + 8 + 1
    )]
    pub campaign: Account<'info, Campaign>,
    #[account(mut)]
    pub creator: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Contribute<'info> {
    #[account(mut)]
    pub campaign: Account<'info, Campaign>,
    
    #[account(
        init_if_needed, 
        payer = donor, 
        space = 8 + 32 + 8,
        seeds = [b"contribution", donor.key().as_ref(), campaign.key().as_ref()],
        bump
    )]
    pub contribution: Account<'info, Contribution>,

    /// CHECK: Safe because we use deterministic seeds for the vault PDA
    #[account(
        mut,
        seeds = [b"vault", campaign.key().as_ref()],
        bump
    )]
    pub vault: SystemAccount<'info>,

    #[account(mut)]
    pub donor: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut)]
    pub campaign: Account<'info, Campaign>,
    
    /// CHECK: Safe vault PDA
    #[account(
        mut,
        seeds = [b"vault", campaign.key().as_ref()],
        bump
    )]
    pub vault: SystemAccount<'info>,

    #[account(
        mut, 
        address = campaign.creator @ ErrorCode::NotCreator
    )]
    pub creator: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Refund<'info> {
    #[account(mut)]
    pub campaign: Account<'info, Campaign>,
    
    #[account(
        mut, 
        seeds = [b"contribution", donor.key().as_ref(), campaign.key().as_ref()], 
        bump,
        close = donor
    )]
    pub contribution: Account<'info, Contribution>,
    
    /// CHECK: Safe vault PDA
    #[account(
        mut,
        seeds = [b"vault", campaign.key().as_ref()],
        bump
    )]
    pub vault: SystemAccount<'info>,

    #[account(mut)]
    pub donor: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct CloseCampaign<'info> {
    #[account(
        mut, 
        address = campaign.creator @ ErrorCode::NotCreator,
        close = creator
    )]
    pub campaign: Account<'info, Campaign>,
    #[account(mut)]
    pub creator: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct Campaign {
    pub creator: Pubkey,
    pub goal: u64,
    pub raised: u64,
    pub deadline: i64,
    pub claimed: bool,
}

#[account]
pub struct Contribution {
    pub donor: Pubkey,
    pub amount: u64,
}

#[error_code]
pub enum ErrorCode {
    #[msg("Deadline must be in the future.")]
    DeadlineInPast,
    #[msg("Campaign is still ongoing.")]
    CampaignOngoing,
    #[msg("Campaign has already ended.")]
    CampaignEnded,
    #[msg("Goal not reached, creator cannot withdraw.")]
    GoalNotReached,
    #[msg("Campaign has already been claimed.")]
    AlreadyClaimed,
    #[msg("Goal reached, refunds are no longer available.")]
    GoalReachedNoRefund,
    #[msg("No contribution found for this user.")]
    NoContributionFound,
    #[msg("Only the creator can call this function.")]
    NotCreator,
    #[msg("Contribution amount must be greater than zero.")]
    ZeroAmount,
    #[msg("Arithmetic overflow.")]
    Overflow,
    #[msg("Arithmetic underflow.")]
    Underflow,
    #[msg("Campaign cannot be closed yet. Must be claimed or significantly past deadline.")]
    CannotCloseYet,
}
