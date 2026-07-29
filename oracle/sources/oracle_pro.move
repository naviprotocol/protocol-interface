module oracle::oracle_pro {

    use std::ascii::{String};
    use sui::clock::{Self, Clock};
    use oracle::oracle_provider::{Self as provider, OracleProviderConfig};
    use oracle::oracle::{PriceOracle};
    use oracle::config::{OracleConfig};
    use SupraOracle::SupraSValueFeed::{OracleHolder};
    use pyth::price_info::{PriceInfoObject};
    use pyth_pro_compatible::price_info::{PriceInfoObject as ProPriceInfoObject};
    use switchboard::aggregator::{Aggregator};

    // Events
    struct PriceRegulation has copy, drop {
        level: u8,
        config_address: address,
        feed_address: address,
        price_diff_threshold1: u64,
        price_diff_threshold2: u64,
        current_time: u64,
        diff_threshold2_timer: u64,
        max_duration_within_thresholds: u64,
        primary_price: u256,
        secondary_price: u256,
    }

    struct InvalidOraclePrice has copy, drop {
        config_address: address,
        feed_address: address,
        provider: String,
        price: u256,
        maximum_effective_price: u256,
        minimum_effective_price: u256,
        maximum_allowed_span: u64,
        current_timestamp: u64,
        historical_price_ttl: u64,
        historical_price: u256,
        historical_updated_time: u64,
    }

    struct OracleUnavailable has copy, drop {
        type: u8,
        config_address: address,
        feed_address: address,
        provider: String,
        price: u256,
        updated_time: u64,
    }

    // Deprecated: legacy Pyth deployment is retired after the Pyth Core upgrade (2026-07-31)
    #[allow(unused_variable)]
    native public fun update_single_price_v2(clock: &Clock, oracle_config: &mut OracleConfig, price_oracle: &mut PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject, switchboard_aggregator: &Aggregator, feed_address: address);

    native public fun update_single_price_v3(clock: &Clock, oracle_config: &mut OracleConfig, price_oracle: &mut PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &ProPriceInfoObject, switchboard_aggregator: &Aggregator, feed_address: address);

    #[allow(unused_variable)]
    native public fun update_single_price(clock: &Clock, oracle_config: &mut OracleConfig, price_oracle: &mut PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject, feed_address: address);

    #[allow(unused_variable)]
    native public fun get_price_from_adaptor(oracle_provider_config: &OracleProviderConfig, target_decimal: u8, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject): (u256, u64);

    // Deprecated: legacy Pyth deployment is retired after the Pyth Core upgrade (2026-07-31)
    #[allow(unused_variable)]
    native public fun get_price_from_adaptor_v2(oracle_provider_config: &OracleProviderConfig, target_decimal: u8, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject, switchboard_aggregator: &Aggregator): (u256, u64);

    native public fun get_price_from_adaptor_v3(oracle_provider_config: &OracleProviderConfig, target_decimal: u8, supra_oracle_holder: &OracleHolder, pyth_price_info: &ProPriceInfoObject, switchboard_aggregator: &Aggregator): (u256, u64);

}
