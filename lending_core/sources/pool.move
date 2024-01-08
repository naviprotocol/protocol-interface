#[allow(unused_field, unused_mut_parameter)]
module lending_core::pool {
    use std::ascii::{String};
    use sui::object::{UID};
    use sui::balance::{Balance};
    use sui::tx_context::{TxContext};


    friend lending_core::lending;
    friend lending_core::storage;

    struct Pool<phantom CoinType> has key, store {
        id: UID,
        balance: Balance<CoinType>,
        treasury_balance: Balance<CoinType>,
        decimal: u8,
    }

    struct PoolAdminCap has key, store {
        id: UID,
        creator: address,
    }

    struct PoolCreate has copy, drop {
        creator: address,
    }

    struct PoolBalanceRegister has copy, drop {
        sender: address,
        amount: u64,
        new_amount: u64,
        pool: String,
    }

    struct PoolDeposit has copy, drop {
        sender: address,
        amount: u64,
        pool: String,
    }

    struct PoolWithdraw has copy, drop {
        sender: address,
        recipient: address,
        amount: u64,
        pool: String,
    }

    native public fun withdraw_treasury<CoinType>(_cap: &mut PoolAdminCap, pool: &mut Pool<CoinType>, amount: u64, recipient: address, ctx: &mut TxContext);

    native public fun get_coin_decimal<CoinType>(pool: &Pool<CoinType>): u8;

    native public fun convert_amount(amount: u64, cur_decimal: u8, target_decimal: u8): u64;

    native public fun normal_amount<CoinType>(pool: &Pool<CoinType>, amount: u64): u64;

    native public fun unnormal_amount<CoinType>(pool: &Pool<CoinType>, amount: u64): u64;

    native public fun uid<T>(pool: &Pool<T>): &UID;
}