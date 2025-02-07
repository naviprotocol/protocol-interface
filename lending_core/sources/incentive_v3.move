#[allow(unused_field)]
module lending_core::incentive_v3 {

    use std::ascii::{String};
    use sui::bag::{Bag};
    use sui::object::{UID};
    use sui::coin::{Coin};
    use sui::table::{Table};
    use sui::clock::{Clock};
    use sui::balance::{Balance};
    use sui::vec_map::{VecMap};
    use sui::tx_context::{TxContext};

    use lending_core::pool::{Pool};
    use lending_core::storage::{Storage};
    use lending_core::account::{AccountCap};
    use lending_core::incentive_v2::{Incentive as IncentiveV2};
    use oracle::oracle::{PriceOracle};

    // Main structs
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

    // Reward claiming
    native public fun claim_reward<RewardCoinType>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, reward_fund: &mut RewardFund<RewardCoinType>, coin_types: vector<String>, rule_ids: vector<address>, ctx: &mut TxContext): Balance<RewardCoinType>;

    native public entry fun claim_reward_entry<RewardCoinType>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, reward_fund: &mut RewardFund<RewardCoinType>, coin_types: vector<String>, rule_ids: vector<address>, ctx: &mut TxContext);
    
    native public fun claim_reward_with_account_cap<RewardCoinType>(clock: &Clock, incentive: &mut Incentive, storage: &mut Storage, reward_fund: &mut RewardFund<RewardCoinType>, coin_types: vector<String>, rule_ids: vector<address>, account_cap: &AccountCap): Balance<RewardCoinType>;

    // Core lending operations with incentive
    native public entry fun entry_deposit<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);
    
    native public fun deposit_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap);
    
    native public entry fun entry_deposit_on_behalf_of_user<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);

    native public entry fun entry_withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);
    
    native public fun withdraw_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;
    
    native public fun withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);
    
    native public fun borrow_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;
    
    native public fun borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);
    
    native public fun repay_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;
    
    native public fun entry_repay_on_behalf_of_user<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);
    
    native public fun repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_coin: Coin<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, liquidate_amount: u64, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext);
    
    native public fun liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_balance: Balance<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, incentive_v2: &mut IncentiveV2, incentive_v3: &mut Incentive, ctx: &mut TxContext): (Balance<CollateralCoinType>, Balance<DebtCoinType>);

    // Getter functions
    native public fun pools(incentive: &Incentive): &VecMap<String, AssetPool>;
    
    native public fun get_pool_info(pool: &AssetPool): (address, u8, String, &VecMap<address, Rule>);
    
    native public fun get_rule_info(rule: &Rule): (address, u8, bool, String, u256, u64, u256, &Table<address, u256>, &Table<address, u256>, &Table<address, u256>);
    
    native public fun get_user_index_by_rule(rule: &Rule, user: address): u256;
    
    native public fun get_user_total_rewards_by_rule(rule: &Rule, user: address): u256;
    
    native public fun get_user_rewards_claimed_by_rule(rule: &Rule, user: address): u256;
    
    native public fun get_balance_value_by_reward_fund<T>(reward_fund: &RewardFund<T>): u64;
    
    native public fun get_user_claimable_rewards(clock: &Clock, storage: &mut Storage, incentive: &Incentive, user: address): vector<ClaimableReward>;
}