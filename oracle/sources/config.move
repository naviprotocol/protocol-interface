module oracle::config {
    use std::ascii::{String};
    use sui::object::{UID};
    use sui::table::{Table};
    use oracle::oracle_provider::{OracleProvider, OracleProviderConfig};

    // Structs
    #[allow(unused_field)]
    struct OracleConfig has key, store {
        id: UID,
        version: u64,
        paused: bool, // when the decentralized price goes wrong, it can be pause
        vec_feeds: vector<address>,
        feeds: Table<address, PriceFeed>,
    }

    #[allow(unused_field)]
    struct PriceFeed has store {
        id: UID,
        enable: bool, // when the decentralized price of a certain token goes wrong, it can be disable
        max_timestamp_diff: u64, // the expected difference between the current time and the oracle time
        price_diff_threshold1: u64,  // x1
        price_diff_threshold2: u64,  // x2
        max_duration_within_thresholds: u64,        // the maximum allowed usage time between ratio1(x1) and ratio2(x2), ms
        diff_threshold2_timer: u64,             // timestamp: save the first time the price difference ratio was used between ratio1 and ratio2
        maximum_allowed_span_percentage: u64,   // the current price cannot exceed this value compared to the last price range, must (x * 10000) --> 10% == 0.1 * 10000 = 1000
        maximum_effective_price: u256,          // the price cannot be greater than this value
        minimum_effective_price: u256,          // the price cannot be lower than this value
        oracle_id: u8,
        coin_type: String,
        primary: OracleProvider,
        secondary: OracleProvider,
        oracle_provider_configs: Table<OracleProvider, OracleProviderConfig>,
        historical_price_ttl: u64, // Is there any ambiguity about TTL(Time-To-Live)?
        history: History,
    }

    #[allow(unused_field)]
    struct History has copy, store {
        price: u256,
        updated_time: u64,
    }

    native public fun version_verification(cfg: &OracleConfig);

    native public fun is_price_feed_exists<CoinType>(cfg: &OracleConfig, oracle_id: u8): bool;

    // GET
    // OracleConfig
    native public fun get_config_id_to_address(cfg: &OracleConfig): address;

    native public fun is_paused(cfg: &OracleConfig): bool;

    native public fun get_vec_feeds(cfg: &OracleConfig): vector<address>;

    native public fun get_feeds(cfg: &OracleConfig): &Table<address, PriceFeed>;

    // PriceFeed
    native public fun get_price_feed(cfg: &OracleConfig, feed_id: address): &PriceFeed;

    native public fun get_price_feed_id(cfg: &OracleConfig, feed_id: address): address;

    native public fun get_price_feed_id_from_feed(price_feed: &PriceFeed): address;

    native public fun is_price_feed_enable(price_feed: &PriceFeed): bool;

    native public fun get_max_timestamp_diff(cfg: &OracleConfig, feed_id: address): u64;

    native public fun get_max_timestamp_diff_from_feed(price_feed: &PriceFeed): u64;

    native public fun get_price_diff_threshold1(cfg: &OracleConfig, feed_id: address): u64;

    native public fun get_price_diff_threshold1_from_feed(price_feed: &PriceFeed): u64;

    native public fun get_price_diff_threshold2(cfg: &OracleConfig, feed_id: address): u64;

    native public fun get_price_diff_threshold2_from_feed(price_feed: &PriceFeed): u64;

    native public fun get_max_duration_within_thresholds(cfg: &OracleConfig, feed_id: address): u64;

    native public fun get_max_duration_within_thresholds_from_feed(price_feed: &PriceFeed): u64;

    native public fun get_diff_threshold2_timer(cfg: &OracleConfig, feed_id: address): u64;

    native public fun get_diff_threshold2_timer_from_feed(price_feed: &PriceFeed): u64;

    native public fun get_maximum_allowed_span_percentage(cfg: &OracleConfig, feed_id: address): u64;

    native public fun get_maximum_allowed_span_percentage_from_feed(price_feed: &PriceFeed): u64;

    native public fun get_maximum_effective_price(cfg: &OracleConfig, feed_id: address): u256;

    native public fun get_maximum_effective_price_from_feed(price_feed: &PriceFeed): u256;

    native public fun get_minimum_effective_price(cfg: &OracleConfig, feed_id: address): u256;

    native public fun get_minimum_effective_price_from_feed(price_feed: &PriceFeed): u256;

    native public fun get_oracle_id(cfg: &OracleConfig, feed_id: address): u8;

    native public fun get_oracle_id_from_feed(price_feed: &PriceFeed): u8;

    native public fun get_coin_type(cfg: &OracleConfig, feed_id: address): String;

    native public fun get_coin_type_from_feed(price_feed: &PriceFeed): String;

    native public fun get_primary_oracle_provider(price_feed: &PriceFeed): &OracleProvider;

    native public fun get_secondary_oracle_provider(price_feed: &PriceFeed): &OracleProvider;

    native public fun get_oracle_provider_configs(cfg: &OracleConfig, feed_id: address): &Table<OracleProvider, OracleProviderConfig>;

    native public fun get_oracle_provider_configs_from_feed(price_feed: &PriceFeed): &Table<OracleProvider, OracleProviderConfig>;

    native public fun get_primary_oracle_provider_config(price_feed: &PriceFeed): &OracleProviderConfig;

    native public fun get_secondary_source_config(price_feed: &PriceFeed): &OracleProviderConfig;

    native public fun get_historical_price_ttl(price_feed: &PriceFeed): u64;

    native public fun get_history_price_from_feed(price_feed: &PriceFeed): History;

    native public fun get_history_price_data_from_feed(price_feed: &PriceFeed): (u256, u64);

    // SourceConfig
    native public fun get_oracle_provider_config(cfg: &OracleConfig, feed_id: address, provider: OracleProvider): &OracleProviderConfig;

    native public fun get_oracle_provider_config_from_feed(price_feed: &PriceFeed, provider: OracleProvider): &OracleProviderConfig;

    native public fun get_pair_id(cfg: &OracleConfig, feed_id: address, provider: OracleProvider): vector<u8>;

    native public fun get_pair_id_from_feed(price_feed: &PriceFeed, provider: OracleProvider): vector<u8>;

    native public fun get_pair_id_from_oracle_provider_config(provider_config: &OracleProviderConfig): vector<u8>;

    native public fun is_oracle_provider_config_enable(provider_config: &OracleProviderConfig): bool;

    native public fun get_oracle_provider_from_oracle_provider_config(provider_config: &OracleProviderConfig): OracleProvider;

    // History
    native public fun get_price_from_history(history: &History): u256;

    native public fun get_updated_time_from_history(history: &History): u64;

    native public fun is_secondary_oracle_available(price_feed: &PriceFeed): bool;
}

