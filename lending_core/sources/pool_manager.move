#[allow(unused_field, unused_mut_parameter)]
module lending_core::pool_manager {

    use sui::bag::{Bag};
    use sui::object::{UID};
    use sui::balance::{Balance};
    use std::u64;
    use liquid_staking::stake_pool::{StakePool};
    use liquid_staking::cert::{Metadata, CERT};

    // The treasury pool, which is used to hold all the funds
    struct SuiPoolManager has key, store {
        id: UID,
        // the theoretical sui amount of the pool
        // original_sui_amount = sum(sui_deposit) - sum(sui_withdraw)
        original_sui_amount: u64, 
        vsui_balance: Balance<CERT>,
        temp_sui_balance: Bag,
        enabled_manage: bool,
        // a target sui amount for the pool, 
        // the extra sui amount will be staked to vsui
        target_sui_amount: u64,
        vsui_stake_pool: StakePool,
        vsui_metadata: Metadata<CERT>,
    }

    // Event
    struct FundUpdated has copy, drop {
        original_sui_amount: u64,
        current_sui_amount: u64,
        vsui_balance_amount: u64,
        // treasury_amount: u64,
        target_sui_amount: u64,
    }

    struct StakingTreasuryWithdrawn has copy, drop {
        taken_vsui_balance_amount: u64,
        equal_sui_balance_amount: u64
    }

    struct SuiKey has store, copy, drop {}

}
