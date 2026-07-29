module oracle::oracle_manage {

    use sui::tx_context::{TxContext};
    use oracle::oracle::{OracleAdminCap, PriceOracle};
    use oracle::config::{OracleConfig};
    use oracle::oracle_provider::{OracleProvider};

    native public fun create_config(_: &OracleAdminCap, ctx: &mut TxContext);

    native public fun version_migrate(cap: &OracleAdminCap, oracle_config: &mut OracleConfig, price_oracle: &mut PriceOracle);

    native public fun set_pause(_: &OracleAdminCap, oracle_config: &mut OracleConfig, value: bool);

    native public fun create_price_feed<CoinType>(_: &OracleAdminCap, oracle_config: &mut OracleConfig, oracle_id: u8, max_timestamp_diff: u64, price_diff_threshold1: u64, price_diff_threshold2: u64, max_duration_within_thresholds: u64, maximum_allowed_span_percentage: u64, maximum_effective_price: u256, minimum_effective_price: u256, historical_price_ttl: u64, ctx: &mut TxContext);

    native public fun set_enable_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: bool);

    native public fun set_max_timestamp_diff_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u64);

    native public fun set_price_diff_threshold1_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u64);

    native public fun set_price_diff_threshold2_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u64);

    native public fun set_max_duration_within_thresholds_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u64);

    native public fun set_maximum_allowed_span_percentage_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u64);

    native public fun set_maximum_effective_price_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u256);

    native public fun set_minimum_effective_price_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u256);

    native public fun set_historical_price_ttl_to_price_feed(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, value: u64);

    native public fun create_pyth_oracle_provider_config(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, pair_id: vector<u8>, enable: bool);

    native public fun set_pyth_price_oracle_provider_pair_id(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, pair_id: vector<u8>);

    native public fun enable_pyth_oracle_provider(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address);

    native public fun disable_pyth_oracle_provider(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address);

    native public fun create_supra_oracle_provider_config(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, pair_id: u32, enable: bool);

    native public fun set_supra_price_source_pair_id(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, pair_id: vector<u8>);

    native public fun enable_supra_oracle_provider(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address);

    native public fun disable_supra_oracle_provider(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address);

    native public fun create_switchboard_oracle_provider_config(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, pair_id: vector<u8>, enable: bool);

    native public fun set_switchboard_price_source_pair_id(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address, pair_id: vector<u8>);

    native public fun enable_switchboard_oracle_provider(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address);

    native public fun disable_switchboard_oracle_provider(_: &OracleAdminCap, oracle_config: &mut OracleConfig, feed_id: address);

    native public fun set_primary_oracle_provider(_: &OracleAdminCap, cfg: &mut OracleConfig, feed_id: address, provider: OracleProvider);

    native public fun set_secondary_oracle_provider(_: &OracleAdminCap, cfg: &mut OracleConfig, feed_id: address, provider: OracleProvider);

}
