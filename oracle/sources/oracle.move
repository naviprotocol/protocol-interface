module oracle::oracle {
    use sui::object::{UID};
    use sui::table::{Table};
    use sui::clock::{Clock};

    #[allow(unused_field)]
    struct PriceOracle has key {
        id: UID,
        version: u64,
        update_interval: u64,
        price_oracles: Table<u8, Price>,
    }

    #[allow(unused_field)]
    struct Price has store {
        value: u256,
        decimal: u8,
        timestamp: u64
    }

    native public fun get_token_price(clock: &Clock, price_oracle: &PriceOracle, oracle_id: u8): (bool, u256, u8);

    native public fun safe_decimal(price_oracle: &mut PriceOracle, oracle_id: u8): u8;
}
