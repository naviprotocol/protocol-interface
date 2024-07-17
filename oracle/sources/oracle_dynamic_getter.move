module oracle::oracle_dynamic_getter {
    use sui::clock::{Clock};
    use oracle::oracle::{PriceOracle};
    use oracle::config::{OracleConfig};
    use SupraOracle::SupraSValueFeed::{OracleHolder};
    use pyth::price_info::{PriceInfoObject};

    #[allow(unused_assignment)]
    native public fun get_dynamic_single_price(clock: &Clock, oracle_config: &OracleConfig, price_oracle: &PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject, feed_address: address): (u64, u256);
}