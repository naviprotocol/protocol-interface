module oracle::oracle_pro {
    use sui::clock::{Clock};
    use oracle::oracle_provider::{OracleProviderConfig};
    use oracle::oracle::{PriceOracle};
    use oracle::config::{OracleConfig};
    use SupraOracle::SupraSValueFeed::{OracleHolder};
    use pyth::price_info::{PriceInfoObject};

    native public fun update_single_price(clock: &Clock, oracle_config: &mut OracleConfig, price_oracle: &mut PriceOracle, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject, feed_address: address);

    native public fun get_price_from_adaptor(oracle_provider_config: &OracleProviderConfig, target_decimal: u8, supra_oracle_holder: &OracleHolder, pyth_price_info: &PriceInfoObject): (u256, u64);
}