module oracle::adaptor_switchboard {

    use switchboard::aggregator::{Self, Aggregator};

    native public fun get_price_native(aggregator: &Aggregator): (u128, u8, u64);

    // get_price_to_target_decimal: return the target decimal price and timestamp
    native public fun get_price_to_target_decimal(aggregator: &Aggregator, target_decimal: u8): (u256, u64);

    native public fun get_identifier_to_vector(aggregator: &Aggregator): vector<u8>;

    native public fun get_aggregator_id(aggregator: &Aggregator): address;

}
