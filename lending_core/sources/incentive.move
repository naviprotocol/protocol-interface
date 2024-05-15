module lending_core::incentive {
    use std::ascii::{String};

    use sui::object::{UID};
    use sui::table::{Table};
    use sui::clock::{ Clock};
    use sui::balance::{Balance};
    use sui::tx_context::{TxContext};
    use lending_core::storage::{Storage};
    use lending_core::account::{AccountCap};

    #[allow(unused_field)]
    struct IncentiveBal<phantom CoinType> has key, store {
        id: UID,
        asset: u8,
        current_idx: u64,
        distributed_amount: u256,
        balance: Balance<CoinType>
    }

    #[allow(unused_field)]
    struct PoolInfo has store {
        id: u8,
        last_update_time: u64,
        coin_types: vector<String>,
        start_times: vector<u64>,
        end_times: vector<u64>,
        total_supplys: vector<u256>,
        rates: vector<u256>,
        index_rewards: vector<u256>,
        index_rewards_paids: vector<Table<address, u256>>,
        user_acc_rewards: vector<Table<address, u256>>,
        user_acc_rewards_paids: vector<Table<address, u256>>,
        oracle_ids: vector<u8>,
    }

    #[allow(unused_field)]
    struct Incentive has key, store {
        id: UID,
        creator: address,
        owners: Table<u256, bool>,
        admins: Table<u256, bool>,

        pools: Table<u8, PoolInfo>,
        assets: vector<u8>,
    }


    native public entry fun claim_reward<CoinType>(incentive: &mut Incentive, bal: &mut IncentiveBal<CoinType>, clock: &Clock, storage: &mut Storage, account: address, ctx: &mut TxContext);

    native public fun claim_reward_non_entry<CoinType>(incentive: &mut Incentive, bal: &mut IncentiveBal<CoinType>, clock: &Clock, storage: &mut Storage, ctx: &mut TxContext): Balance<CoinType>;

    native public fun claim_reward_with_account_cap<CoinType>(incentive: &mut Incentive, bal: &mut IncentiveBal<CoinType>, clock: &Clock, storage: &mut Storage, account_cap: &AccountCap): Balance<CoinType>;

    native public fun get_pool_count(incentive: &Incentive, asset: u8): u64;

    native public fun get_pool_info(incentive: &Incentive, asset: u8, pool_idx: u64): (u64, u64, u256, u8);

    native public fun earned(incentive: &Incentive, storage: &mut Storage, clock: &Clock, asset: u8, account: address): (vector<String>, vector<u256>, vector<u8>);
}
