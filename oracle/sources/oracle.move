#[allow(lint(self_transfer))]
module oracle::oracle {

    use std::vector;
    use sui::object::{UID};
    use sui::table::{Table};
    use sui::clock::{Self, Clock};
    use sui::tx_context::{TxContext};
    use oracle::oracle_version::{Self as version};

    struct OracleAdminCap has key, store {
        id: UID,
    }

    struct OracleFeederCap has key, store {
        id: UID,
    }

    struct PriceOracle has key {
        id: UID,
        version: u64,
        update_interval: u64,
        price_oracles: Table<u8, Price>,
    }

    struct Price has store {
        value: u256,
        decimal: u8,
        timestamp: u64
    }

    // Events
    struct PriceUpdated has copy, drop {
        price_oracle: address,
        id: u8,
        price: u256,
        last_price: u256,
        update_at: u64,
        last_update_at: u64,
    }

    native public fun create_feeder(_: &OracleAdminCap, ctx: &mut TxContext);

    #[allow(unused_variable, unused_mut_parameter)]
    native entry fun version_migrate(_: &OracleAdminCap, oracle: &mut PriceOracle);

    native public entry fun set_update_interval(_: &OracleAdminCap, price_oracle: &mut PriceOracle, update_interval: u64);

    native public entry fun register_token_price(_: &OracleAdminCap, clock: &Clock, price_oracle: &mut PriceOracle, oracle_id: u8, token_price: u256, price_decimal: u8);

    // function to externally update prices by the feeder
    native public entry fun update_token_price(_: &OracleFeederCap, clock: &Clock, price_oracle: &mut PriceOracle, oracle_id: u8, token_price: u256);

    native public entry fun update_token_price_batch(cap: &OracleFeederCap, clock: &Clock, price_oracle: &mut PriceOracle, oracle_ids: vector<u8>, token_prices: vector<u256>);

    native public fun get_token_price(clock: &Clock, price_oracle: &PriceOracle, oracle_id: u8): (bool, u256, u8);

    native public fun price_object(price_oracle: &PriceOracle, oracle_id: u8): &Price;

    native public fun decimal(price_oracle: &mut PriceOracle, oracle_id: u8): u8;

    native public fun safe_decimal(price_oracle: &PriceOracle, oracle_id: u8): u8;

}
