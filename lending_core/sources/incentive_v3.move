/// The `incentive_v3` module manages the incentive structures for the lending protocol.
/// It includes functionality for creating and managing incentives, pools, and rules,
/// as well as handling reward distribution and borrow fee management.
#[allow(unused_variable, lint(public_entry))]
module lending_core::incentive_v3 {

    use std::vector::{Self};
    use std::ascii::{String};
    use std::type_name::{TypeName};
    use sui::bag::{Bag};
    use sui::object::{UID};
    use sui::coin::{Coin};
    use sui::table::{Table};
    use sui::clock::{Self, Clock};
    use sui::balance::{Self, Balance};
    use sui::vec_map::{VecMap};
    use sui::tx_context::{TxContext};
    use lending_core::pool::{Pool};
    use lending_core::version::{Self};
    use lending_core::storage::{Self, Storage};
    use lending_core::account::{AccountCap};
    use lending_core::incentive_v2::{Self, Incentive as IncentiveV2};
    use oracle::oracle::{PriceOracle};
    use lending_core::storage::StorageAdminCap;
    use sui_system::sui_system::{SuiSystemState};

    struct Incentive has key, store {
        id: UID,
        version: u64,
        pools: VecMap<String, AssetPool>,
        borrow_fee_rate: u64,
        fee_balance: Bag, // K: TypeName(CoinType): V: Balance<CoinType>
    }

    struct AssetPool has key, store {
        id: UID,
        asset: u8,
        asset_coin_type: String, // just for display
        rules: VecMap<address, Rule>,
    }

    struct Rule has key, store {
        id: UID,
        option: u8,
        enable: bool,
        reward_coin_type: String,
        rate: u256, // RAY number,ray_div(total_release, duration) --> 20usdt in 1month = ray_div(20 * 1e6, (86400 * 30 * 1000)) = 7.716049575617284e+24
        max_rate: u256, // rate limit to prevent operation errors --> 0 means no limit
        last_update_at: u64, // milliseconds
        global_index: u256,
        user_index: Table<address, u256>,
        user_total_rewards: Table<address, u256>, // total rewards of the user
        user_rewards_claimed: Table<address, u256>, // total rewards of the user claimed
    }

    struct RewardFund<phantom CoinType> has key, store {
        id: UID,
        balance: Balance<CoinType>,
        coin_type: String,
    }

    // Claimable rewards for a user
    struct ClaimableReward has copy, drop {
        asset_coin_type: String,
        reward_coin_type: String,
        user_claimable_reward: u256,
        user_claimed_reward: u256,
        rule_ids: vector<address>,
    }

    // Event
    struct RewardFundCreated has copy, drop {
        sender: address,
        reward_fund_id: address,
        coin_type: String,
    }

    struct RewardFundDeposited has copy, drop {
        sender: address,
        reward_fund_id: address,
        amount: u64,
    }

    struct RewardFundWithdrawn has copy, drop {
        sender: address,
        reward_fund_id: address,
        amount: u64,
    }

    struct IncentiveCreated has copy, drop {
        sender: address,
        incentive_id: address,
    }

    struct AssetPoolCreated has copy, drop {
        sender: address,
        asset_id: u8,
        asset_coin_type: String,
        pool_id: address,
    }

    struct RuleCreated has copy, drop {
        sender: address,
        pool: String,
        rule_id: address,
        option: u8,
        reward_coin_type: String,
    }

    struct BorrowFeeRateUpdated has copy, drop {
        sender: address,
        rate: u64,
    }

    struct BorrowFeeWithdrawn has copy, drop {
        sender: address,
        coin_type: String,
        amount: u64,
    }

    struct RewardStateUpdated has copy, drop {
        sender: address,
        rule_id: address,
        enable: bool,
    }

    struct MaxRewardRateUpdated has copy, drop {
        rule_id: address,
        max_total_supply: u64,
        duration_ms: u64,
    }

    struct RewardRateUpdated has copy, drop {
        sender: address,
        pool: String,
        rule_id: address,
        rate: u256,
        total_supply: u64,
        duration_ms: u64,
        timestamp: u64,
    }

    struct RewardClaimed has copy, drop {
        user: address,
        total_claimed: u64,
        coin_type: String,
        rule_ids: vector<address>,
        rule_indices: vector<u256>,
    }

    struct AssetBorrowFeeRateUpdated has copy, drop {
        sender: address,
        asset_id: u8,
        user: address,
        rate: u64,
    }

    struct AssetBorrowFeeRateRemoved has copy, drop {
        sender: address,
        asset_id: u8,
        user: address,
    }

    struct BorrowFeeDeposited has copy, drop {
        sender: address,
        coin_type: String,
        fee: u64
    }

    // === dynamic field keys ===
    struct ASSET_BORROW_FEES_KEY has copy, drop, store {}

    struct USER_BORROW_FEES_KEY has copy, drop, store {}

    struct MARKET_ID_KEY has copy, drop, store {}

    // Functions
    native public fun version(incentive: &Incentive): u64;

    native public fun version_verification(incentive: &Incentive);

    native public fun init_for_main_market(_: &StorageAdminCap, incentive: &mut Incentive);

    native public fun init_fund_for_market<T>(_: &StorageAdminCap, reward_fund: &mut RewardFund<T>);

    native public fun contains_rule(pool: &AssetPool, option: u8, reward_coin_type: String): bool;

    // returns: user_total_supply, user_total_borrow, total_supply, total_borrow
    native public fun get_effective_balance(storage: &mut Storage, asset: u8, user: address): (u256, u256, u256, u256);

    /** update the reward state by asset
    * @param clock: the clock
    * @param incentive: the incentive
    * @param storage: the storage
    * @param user: the user address
    */
    native public fun update_reward_state_by_asset<T>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, user: address);

    // Public Get Functions
    /// Returns the pools of the incentive.Keys are the coin type of the pool.
    native public fun pools(incentive: &Incentive): &VecMap<String, AssetPool>;

    // Pool
    native public fun get_pool_info(pool: &AssetPool): (address, u8, String, &VecMap<address, Rule>);

    // Rule Info
    // id: UID,
    // option: u8,
    // enable: bool,
    // reward_coin_type: String,
    // rate: u256,
    // last_update_at: u64,
    // global_index: u256,
    // user_index: Table<address, u256>,
    // user_total_rewards: Table<address, u256>,
    // user_rewards_claimed: Table<address, u256>,
    native public fun get_rule_info(rule: &Rule): (address, u8, bool, String, u256, u64, u256, &Table<address, u256>, &Table<address, u256>, &Table<address, u256>);

    native public fun get_user_index_by_rule(rule: &Rule, user: address): u256;

    native public fun get_user_total_rewards_by_rule(rule: &Rule, user: address): u256;

    native public fun get_user_rewards_claimed_by_rule(rule: &Rule, user: address): u256;

    native public fun get_balance_value_by_reward_fund<T>(reward_fund: &RewardFund<T>): u64;

    native public fun get_user_claimable_rewards(clock: &Clock, storage: &mut Storage, incentive: &Incentive, user: address): vector<ClaimableReward>;

    /// parse the claimable rewards to return the asset coin types, reward coin types, user total rewards, user claimed rewards, and rule ids
    native public fun parse_claimable_rewards(claimable_rewards: vector<ClaimableReward>): (vector<String>, vector<String>, vector<u256>, vector<u256>, vector<vector<address>>);

    // Public functions
    native public fun claim_reward<RewardCoinType>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, reward_fund: &mut RewardFund<RewardCoinType>, coin_types: vector<String>, rule_ids: vector<address>, ctx: &mut TxContext): Balance<RewardCoinType>;

    #[allow(lint(self_transfer))]
    native public entry fun claim_reward_entry<RewardCoinType>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, reward_fund: &mut RewardFund<RewardCoinType>, coin_types: vector<String>, rule_ids: vector<address>, ctx: &mut TxContext);

    native public fun claim_reward_with_account_cap<RewardCoinType>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, reward_fund: &mut RewardFund<RewardCoinType>, coin_types: vector<String>, rule_ids: vector<address>, account_cap: &AccountCap): Balance<RewardCoinType>;

    native public entry fun entry_deposit<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    native public fun deposit_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap);

    native public entry fun entry_deposit_on_behalf_of_user<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public entry fun entry_withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public entry fun entry_withdraw_v2<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public fun withdraw_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun withdraw_with_account_cap_v2<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap, system_state: &mut SuiSystemState, ctx: &mut TxContext): Balance<CoinType>;

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public fun withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun withdraw_v2<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, system_state: &mut SuiSystemState, ctx: &mut TxContext): Balance<CoinType>;

    native public fun get_borrow_fee_v2(incentive: &Incentive, user: address, asset_id: u8, amount: u64): u64;

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public entry fun entry_borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public entry fun entry_borrow_v2<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public fun borrow_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun borrow_with_account_cap_v2<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap, system_state: &mut SuiSystemState, ctx: &mut TxContext): Balance<CoinType>;

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public fun borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun borrow_v2<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, system_state: &mut SuiSystemState, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    native public fun repay_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    #[allow(lint(self_transfer))]
    native public fun entry_repay_on_behalf_of_user<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    native public fun repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public entry fun entry_liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_coin: Coin<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, liquidate_amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public entry fun entry_liquidation_v2<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_coin: Coin<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, liquidate_amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    // V1: Only supports non-SUI assets. May be deprecated in the future, use v2 instead.
    native public fun liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_balance: Balance<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): (Balance<CollateralCoinType>, Balance<DebtCoinType>);

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun liquidation_v2<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_balance: Balance<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, system_state: &mut SuiSystemState, ctx: &mut TxContext): (Balance<CollateralCoinType>, Balance<DebtCoinType>);

    native public fun get_market_id(incentive_v3: &Incentive): u64;

    native public fun get_fund_market_id<T>(reward_fund: &RewardFund<T>): u64;

    native public fun verify_market_storage_incentive(storage: &Storage, incentive: &Incentive);

    native public fun verify_market_incentive_funds<T>(incentive: &Incentive, funds_pool: &RewardFund<T>);

}
