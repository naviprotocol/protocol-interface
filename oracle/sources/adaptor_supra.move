// Source Interface: https://gb-docs.supraoracles.com/docs/data-feeds/pull-model
module oracle::adaptor_supra {
    use SupraOracle::SupraSValueFeed::{OracleHolder};

    // get_price_native: Just return the price/decimal/timestamp from supra oracle
    native public fun get_price_native(supra_oracle_holder: &OracleHolder, pair: u32): (u128, u16, u128);
    // get_price: return the target decimal price and timestamp
    native public fun get_price_to_target_decimal(supra_oracle_holder: &OracleHolder, pair: u32, target_decimal: u8): (u256, u64);

    native public fun pair_id_to_vector(v: u32): vector<u8>;

    native public fun vector_to_pair_id(v: vector<u8>): u32;
}