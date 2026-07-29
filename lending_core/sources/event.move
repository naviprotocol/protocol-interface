/// Event
module lending_core::event {

    use std::ascii::{String};

    // Flash Loan Event
    struct ConfigCreated has copy, drop {
        sender: address,
        id: address,
        market_id: u64,
    }

    struct AssetConfigCreated has copy, drop {
        sender: address,
        config_id: address,
        asset_id: address,
        market_id: u64,
    }

    struct FlashLoan has copy, drop {
        sender: address,
        asset: address,
        amount: u64,
        market_id: u64,
    }

    struct FlashRepay has copy, drop {
        sender: address,
        asset: address,
        amount: u64,
        fee_to_supplier: u64,
        fee_to_treasury: u64,
        market_id: u64,
    }

    // Incentive_v3 Event
    // Event
    struct RewardFundCreated has copy, drop {
        sender: address,
        reward_fund_id: address,
        coin_type: String,
        market_id: u64,
    }

    struct RewardFundDeposited has copy, drop {
        sender: address,
        reward_fund_id: address,
        amount: u64,
        market_id: u64,
    }

    struct RewardFundWithdrawn has copy, drop {
        sender: address,
        reward_fund_id: address,
        amount: u64,
        market_id: u64,
    }

    struct IncentiveCreated has copy, drop {
        sender: address,
        incentive_id: address,
        market_id: u64,
    }

    struct AssetPoolCreated has copy, drop {
        sender: address,
        asset_id: u8,
        asset_coin_type: String,
        pool_id: address,
        market_id: u64,
    }

    struct RuleCreated has copy, drop {
        sender: address,
        pool: String,
        rule_id: address,
        option: u8,
        reward_coin_type: String,
        market_id: u64,
    }

    struct BorrowFeeRateUpdated has copy, drop {
        sender: address,
        rate: u64,
        market_id: u64,
    }

    struct BorrowFeeWithdrawn has copy, drop {
        sender: address,
        coin_type: String,
        amount: u64,
        market_id: u64,
    }

    struct RewardStateUpdated has copy, drop {
        sender: address,
        rule_id: address,
        enable: bool,
        market_id: u64,
    }

    struct MaxRewardRateUpdated has copy, drop {
        rule_id: address,
        max_total_supply: u64,
        duration_ms: u64,
        market_id: u64,
    }

    struct RewardRateUpdated has copy, drop {
        sender: address,
        pool: String,
        rule_id: address,
        rate: u256,
        total_supply: u64,
        duration_ms: u64,
        timestamp: u64,
        market_id: u64,
    }

    struct RewardClaimed has copy, drop {
        user: address,
        total_claimed: u64,
        coin_type: String,
        rule_ids: vector<address>,
        rule_indices: vector<u256>,
        market_id: u64,
    }

    struct AssetBorrowFeeRateUpdated has copy, drop {
        sender: address,
        asset_id: u8,
        user: address,
        rate: u64,
        market_id: u64,
    }

    struct AssetBorrowFeeRateRemoved has copy, drop {
        sender: address,
        asset_id: u8,
        user: address,
        market_id: u64,
    }

    struct BorrowFeeDeposited has copy, drop {
        sender: address,
        coin_type: String,
        fee: u64,
        market_id: u64,
    }

    // Lending Event
    // Event
    struct DepositEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
        market_id: u64,
    }

    struct DepositOnBehalfOfEvent has copy, drop {
        reserve: u8,
        sender: address,
        user: address,
        amount: u64,
        market_id: u64,
    }

    struct WithdrawEvent has copy, drop {
        reserve: u8,
        sender: address,
        to: address,
        amount: u64,
        market_id: u64,
    }

    struct BorrowEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
        market_id: u64,
    }

    struct RepayEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
        market_id: u64,
    }

    struct RepayOnBehalfOfEvent has copy, drop {
        reserve: u8,
        sender: address,
        user: address,
        amount: u64,
        market_id: u64,
    }

    #[allow(unused_field)]
    struct LiquidationCallEvent has copy, drop {
        reserve: u8,
        sender: address,
        liquidate_user: address,
        liquidate_amount: u64,
        market_id: u64,
    }

    struct LiquidationEvent has copy, drop {
        sender: address,
        user: address,
        collateral_asset: u8,
        collateral_price: u256,
        collateral_amount: u64,
        treasury: u64,
        debt_asset: u8,
        debt_price: u256,
        debt_amount: u64,
        market_id: u64,
    }

    // logic Event
    struct StateUpdated has copy, drop {
        user: address,
        asset: u8,
        user_supply_balance: u256,
        user_borrow_balance: u256,
        new_supply_index: u256,
        new_borrow_index: u256,
        market_id: u64,
    }

    // pool_manager Event
    struct FundUpdated has copy, drop {
        original_sui_amount: u64,
        current_sui_amount: u64,
        vsui_balance_amount: u64,
        // treasury_amount: u64,
        target_sui_amount: u64,
        manager_id: address,
    }

    struct StakingTreasuryWithdrawn has copy, drop {
        taken_vsui_balance_amount: u64,
        equal_sui_balance_amount: u64,
        manager_id: address,
    }

    // pool Event
    // Event
    struct PoolCreate has copy, drop {
        creator: address,
        coin_type: String,
        pool_id: address,
        market_id: u64,
    }

    struct PoolBalanceRegister has copy, drop {
        sender: address,
        amount: u64,
        new_amount: u64,
        pool: String,
        market_id: u64,
    }

    struct PoolDeposit has copy, drop {
        sender: address,
        amount: u64,
        pool: String,
        market_id: u64,
    }

    struct PoolWithdraw has copy, drop {
        sender: address,
        recipient: address,
        amount: u64,
        pool: String,
        market_id: u64,
    }

    struct PoolWithdrawReserve has copy, drop {
        sender: address,
        recipient: address,
        amount: u64,
        before: u64,
        after: u64,
        pool: String,
        poolId: address,
        market_id: u64,
    }

    // Event
    struct StorageConfiguratorSetting has copy, drop {  
        sender: address,
        configurator: address,
        value: bool,
        market_id: u64,
    }

    struct Paused has copy, drop {
        paused: bool,
        market_id: u64,
    }

    struct WithdrawTreasuryEvent has copy, drop {
        sender: address,
        recipient: address,
        asset: u8,
        amount: u256,
        poolId: address,
        before: u256,
        after: u256,
        index: u256,
        market_id: u64,
    }

    struct LiquidatorSet has copy, drop {
        liquidator: address,
        user: address,
        is_liquidatable: bool,
        market_id: u64,
    }

    struct ProtectedUserSet has copy, drop {
        user: address,
        is_protected: bool,
        market_id: u64,
    }

    struct EmodePairCreated has copy, drop {
        emode_id: u64,
        assetA: u8,
        assetB: u8,
        market_id: u64,
    }

    struct EmodeParamSet has copy, drop {
        emode_id: u64,
        asset: u8,
        value: u256,
        param_type: String,
        market_id: u64,
    }

    struct EmodeActiveSet has copy, drop {
        emode_id: u64,
        is_active: bool,
        market_id: u64,
    }

    struct EmodeUserStateChanged has copy, drop {
        user: address,
        emode_id: u64,
        is_entered: bool,
        market_id: u64,
    }

    struct MarketCreated has copy, drop { market_id: u64 }

    struct BorrowWeightSet has copy, drop {
        asset: u8,
        weight: u64,
        market_id: u64,
    }

    struct BorrowWeightRemoved has copy, drop { asset: u8, market_id: u64 }

    struct StorageParamsUpdated has copy, drop {
        asset: u8,
        param_type: String,
        value: u256,
        market_id: u64,
    }

}
