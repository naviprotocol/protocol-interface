module oracle::strategy {
    native public fun validate_price_difference(primary_price: u256, secondary_price: u256, threshold1: u64, threshold2: u64, current_timestamp: u64, max_duration_within_thresholds: u64, ratio2_usage_start_time: u64): u8;

    // return bool: is_normal
    native public fun validate_price_range_and_history(
        price: u256,
        maximum_effective_price: u256,
        minimum_effective_price: u256,
        maximum_allowed_span_percentage: u64,
        current_timestamp: u64,
        historical_price_ttl: u64,
        historical_price: u256,
        historical_updated_time: u64,
    ): bool;

    native public fun is_oracle_price_fresh(current_timestamp: u64, oracle_timestamp: u64, max_timestamp_diff: u64): bool;
}