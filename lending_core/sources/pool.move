#[allow(unused_field, unused_mut_parameter)]
module lending_core::pool {
    use sui::object::{UID};
    use sui::balance::{Balance};

    struct Pool<phantom CoinType> has key, store {
        id: UID,
        balance: Balance<CoinType>,
        treasury_balance: Balance<CoinType>,
        decimal: u8,
    }

    native public fun get_coin_decimal<CoinType>(pool: &Pool<CoinType>): u8;

    native public fun convert_amount(amount: u64, cur_decimal: u8, target_decimal: u8): u64;

    native public fun normal_amount<CoinType>(pool: &Pool<CoinType>, amount: u64): u64;

    native public fun unnormal_amount<CoinType>(pool: &Pool<CoinType>, amount: u64): u64;

    native public fun uid<T>(pool: &Pool<T>): &UID;
}