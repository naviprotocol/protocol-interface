#[lint_allow(self_transfer)]
#[allow(unused_use, lint(public_entry))]
// Deprecated: `incentive_v2` is kept for upgrade compatibility only.
// It no longer distributes rewards, and no new reward features will be added here.
// All reward functionality is implemented in `lending_core::incentive_v3`.
module lending_core::incentive_v2 {

    use std::vector::{Self};
    use std::type_name::{TypeName};
    use sui::coin::{Coin};
    use sui::object::{Self, UID};
    use sui::table::{Table};
    use sui::clock::{Self, Clock};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{TxContext};
    use oracle::oracle::{PriceOracle};
    use lending_core::pool::{Pool};
    use lending_core::version::{Self};
    use lending_core::account::{AccountCap};
    use lending_core::incentive::{Self as incentive_v1, Incentive as IncentiveV1};
    use lending_core::storage::{Self, Storage, OwnerCap as StorageOwnerCap};

    struct OwnerCap has key, store {
        id: UID,
    }

    struct Incentive has key, store {
        id: UID,
        version: u64,
        pool_objs: vector<address>,
        inactive_objs: vector<address>,
        pools: Table<address, IncentivePool>,
        funds: Table<address, IncentiveFundsPoolInfo>,
    }

    struct IncentivePool has key, store {
        id: UID,
        phase: u64,
        funds: address, // IncentiveFundsPool.id -> pre_check: object::id_to_address(IncentiveFundsPool.id) equals IncentivePool.funds
        start_at: u64, // Distribution start time
        end_at: u64, // Distribution end time
        closed_at: u64, // Distribution closed time, that means you cannot claim after this time. But the administrator can set this value to 0, which means it can always be claimed.
        total_supply: u64, // sui::balance::supply_value max is 18446744073709551615u64, see https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/balance.move#L53
        option: u8, // supply, withdraw, borrow, repay or liquidation
        asset_id: u8, // the asset id on protocol pool
        factor: u256, // the ratio, type in 1e18
        last_update_at: u64,
        distributed: u64,
        index_reward: u256,
        index_rewards_paids: Table<address, u256>,
        total_rewards_of_users: Table<address, u256>,
        total_claimed_of_users: Table<address, u256>,
    }

    struct IncentiveFundsPool<phantom CoinType> has key, store {
        id: UID,
        oracle_id: u8,
        balance: Balance<CoinType>,
        coin_type: TypeName,
    }

    struct IncentiveFundsPoolInfo has key, store {
        id: UID,
        oracle_id: u8,
        coin_type: TypeName
    }

    // Events
    struct CreateFundsPool has copy, drop {
        sender: address,
        coin_type: TypeName,
        oracle_id: u8,
        force: bool,
    }

    struct IncreasedFunds has copy, drop {
        sender: address,
        balance_before: u64,
        balance_after: u64,
    }

    struct WithdrawFunds has copy, drop {
        sender: address,
        value: u64,
    }

    struct CreateIncentive has copy, drop {
        sender: address,
        incentive_pool_pro: address,
    }

    struct CreateIncentivePool has copy, drop {
        sender: address,
        pool: address,
    }

    struct RewardsClaimed has copy, drop {
        sender: address,
        pool: address,
        amount: u64,
    }

    native public fun create_and_transfer_owner(_: &StorageOwnerCap, ctx: &mut TxContext);

    native public fun version_verification(incentive: &Incentive);

    native public fun version_migrate(_: &OwnerCap, incentive: &mut Incentive);

    // +++++++++++++++Split: For Funds Pool+++++++++++++++
    native public fun create_funds_pool<T>(_: &OwnerCap, incentive: &mut Incentive, oracle_id: u8, force: bool, ctx: &mut TxContext);

    // TODO: to be entry?
    native public fun add_funds<T>(_: &OwnerCap, funds: &mut IncentiveFundsPool<T>, funds_coin: Coin<T>, value: u64, ctx: &mut TxContext);

    native public fun withdraw_funds<T>(_: &OwnerCap, funds: &mut IncentiveFundsPool<T>, value: u64, ctx: &mut TxContext);

    // +++++++++++++++Split: For Incentive Pool+++++++++++++++
    native public fun create_incentive(_: &OwnerCap, ctx: &mut TxContext);

    native public fun create_incentive_pool<T>(_: &OwnerCap, incentive: &mut Incentive, funds: &IncentiveFundsPool<T>, phase: u64, start_at: u64, end_at: u64, closed_at: u64, total_supply: u64, option: u8, asset_id: u8, factor: u256, ctx: &mut TxContext);

    native public fun freeze_incentive_pool(_: &OwnerCap, incentive_v2: &mut Incentive, deadline: u64);

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

    native public fun get_pool_info(incentive: &Incentive, obj: address): (address, u64, address, u64, u64, u64, u64, u8, u8, u256, u64, u64, u256);

    native public fun get_pool_length(incentive: &Incentive): u64;

    native public fun get_funds_value<T>(funds: &IncentiveFundsPool<T>): u64;

    native public fun calculate_one_from_pool(incentive: &Incentive, obj: address, current_timestamp: u64, supply: u256, user: address, user_balance: u256): (u256, u256);

    native public fun get_total_claimed_from_user(incentive: &Incentive, obj: address, user: address): u256;

    native public fun get_funds_info(incentive: &Incentive, obj: address): (address, u8, TypeName);

    // lending protocol entry function
    #[allow(unused_variable)]
    native public entry fun entry_deposit<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public fun deposit_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, account_cap: &AccountCap);

    #[allow(unused_variable)]
    native public entry fun entry_deposit_on_behalf_of_user<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, amount: u64, user: address, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public entry fun entry_withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public fun withdraw_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    #[allow(unused_variable)]
    native public fun withdraw<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    #[allow(unused_variable)]
    native public entry fun entry_borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public fun borrow_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    #[allow(unused_variable)]
    native public fun borrow<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    #[allow(unused_variable)]
    native public entry fun entry_repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public fun repay_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, incentive: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;

    #[allow(unused_variable)]
    native public fun entry_repay_on_behalf_of_user<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, user: address, incentive: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public fun repay<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, repay_coin: Coin<CoinType>, amount: u64, incentive: &mut Incentive, ctx: &mut TxContext): Balance<CoinType>;

    #[allow(unused_variable)]
    native public entry fun entry_liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_coin: Coin<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, liquidate_amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext);

    #[allow(unused_variable)]
    native public fun liquidation<DebtCoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<DebtCoinType>, debt_balance: Balance<DebtCoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, liquidate_user: address, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext): (Balance<CollateralCoinType>, Balance<DebtCoinType>);

}
