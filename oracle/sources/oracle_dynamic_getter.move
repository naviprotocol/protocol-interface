module oracle::oracle_dynamic_getter {

    use sui::clock::{Self, Clock};
    use oracle::oracle::{PriceOracle};
    use oracle::config::{OracleConfig};
    use SupraOracle::SupraSValueFeed::{OracleHolder};
    use pyth::price_info::{PriceInfoObject};
    use pyth_pro_compatible::price_info::{PriceInfoObject as ProPriceInfoObject};
    use switchboard::aggregator::{Aggregator};

    // Deprecated: legacy Pyth deployment is retired after the Pyth Core upgrade (2026-07-31)
    #[allow(unused_variable)]
    native public fun get_dynamic_single_price(clock: &Clock, oracle_config: &OracleConfig, price_oracle: &PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject, feed_address: address): (u64, u256);

    /// a dynamic function to fetch a latest price without actually updating the price
    /// return (result, price)
    #[allow(unused_assignment)]
    native public fun get_dynamic_single_price_v2(clock: &Clock, oracle_config: &OracleConfig, price_oracle: &PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &ProPriceInfoObject, switchboard_aggregator: &Aggregator, feed_address: address): (u64, u256);

}
