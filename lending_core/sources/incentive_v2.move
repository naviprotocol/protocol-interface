module lending_core::incentive_v2 {
    use std::type_name::{TypeName};
    use sui::coin::{Coin};
    use sui::object::{UID};
    use sui::table::{Table};
    use sui::clock::{Clock};
    use sui::balance::{Balance};
    use sui::tx_context::{TxContext};

    use oracle::oracle::{PriceOracle};

    use lending_core::pool::{Pool};
    use lending_core::account::{AccountCap};
    use lending_core::incentive::{Incentive as IncentiveV1};
    use lending_core::storage::{Storage};

    #[allow(unused_field)]
    struct Incentive has key, store {
        id: UID,
        version: u64,
        pool_objs: vector<address>,
        inactive_objs: vector<address>,
        pools: Table<address, IncentivePool>,
        funds: Table<address, IncentiveFundsPoolInfo>,
    }

    #[allow(unused_field)]
    struct IncentivePool has key, store {
        id: UID,
        phase: u64,
        funds: address,
        start_at: u64,
        end_at: u64,
        closed_at: u64,
        total_supply: u64,
        option: u8,
        asset_id: u8,
        factor: u256,
        last_update_at: u64,
        distributed: u64,
        index_reward: u256,
        index_rewards_paids: Table<address, u256>,
        total_rewards_of_users: Table<address, u256>,
        total_claimed_of_users: Table<address, u256>,
    }

    #[allow(unused_field)]
    struct IncentiveFundsPool<phantom CoinType> has key, store {
        id: UID,
        oracle_id: u8,
        balance: Balance<CoinType>,
        coin_type: TypeName,
    }

    #[allow(unused_field)]
    struct IncentiveFundsPoolInfo has key, store {
        id: UID,
        oracle_id: u8,
        coin_type: TypeName
    }

    native public entry fun claim_reward<T>(clock: &Clock, incentive: &mut Incentive, funds_pool: &mut IncentiveFundsPool<T>, storage: &mut Storage, asset_id: u8, option: u8, ctx: &mut TxContext);

    native public fun claim_reward_non_entry<T>(clock: &Clock, incentive: &mut Incentive, funds_pool: &mut IncentiveFundsPool<T>, storage: &mut Storage, asset_id: u8, option: u8, ctx: &TxContext): Balance<T>;

    native public fun claim_reward_with_account_cap<T>(clock: &Clock, incentive: &mut Incentive, funds_pool: &mut IncentiveFundsPool<T>, storage: &mut Storage, asset_id: u8, option: u8, account_cap: &AccountCap): Balance<T>;

    native public fun get_pool_from_funds_pool<T>(incentive: &Incentive, funds_pool: &IncentiveFundsPool<T>, asset_id: u8, option: u8): vector<address>;

    native public fun calculate_release_rate(pool: &IncentivePool): u256;

    native public fun calculate_user_effective_amount(option: u8, supply_balance: u256, borrow_balance: u256, factor: u256): u256;

    native public fun get_pool_from_asset_and_option(incentive: &Incentive, asset_id: u8, option: u8): (vector<address>, vector<address>, vector<address>);

    native public fun get_active_pools(incentive: &Incentive, asset_id: u8, option: u8, now: u64): vector<address>;
    native public fun get_pool_objects(incentive: &Incentive): vector<address>;

    native public fun get_inactive_pool_objects(incentive: &Incentive): vector<address>;

    // public getter
    native public fun option_supply(): u8;

    native public fun option_withdraw(): u8;

    native public fun option_borrow(): u8;

    native public fun option_repay(): u8;

    native public fun get_pool_info(incentive: &Incentive, obj: address): (
        address, // id
        u64, // phase
        address, // funds
        u64, // start_at
        u64, // end_at
        u64, // closed_at
        u64, // total_supply
        u8, // option
        u8, // asset_id
        u256, // factor
        u64, // last_update_at
        u64, // distributed
        u256 // index_reward
    );

    native public fun get_pool_length(incentive: &Incentive): u64;

    native public fun get_funds_value<T>(funds: &IncentiveFundsPool<T>): u64;

    native public fun calculate_one_from_pool(incentive: &Incentive, obj: address, current_timestamp: u64, supply: u256, user: address, user_balance: u256): (u256, u256);

    native public fun get_total_claimed_from_user(incentive: &Incentive, obj: address, user: address): u256;

    native public fun get_funds_info(incentive: &Incentive, obj: address): (address, u8, TypeName);

    native public entry fun entry_deposit<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    native public fun deposit_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, account_cap: &AccountCap);

    native public entry fun entry_deposit_on_behalf_of_user<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, user: address, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    native public entry fun entry_withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    native public fun withdraw_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    native public fun withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext);

    native public fun borrow_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    native public fun borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext);

    native public fun repay_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, incentive: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    native public fun entry_repay_on_behalf_of_user<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, user: address, incentive: &mut Incentive, ctx: &mut TxContext);

    native public fun repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    native public entry fun entry_liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_coin: Coin<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, liquidate_amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    native public fun liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_balance: Balance<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext): (Balance<CollateralCoinType>, Balance<DebtCoinType>);
}