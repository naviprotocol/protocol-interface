module oracle::adaptor_pyth {
    use sui::clock::{Clock};
    use pyth::state::{State};
    use pyth::price_info::{PriceInfoObject};

    
    // get_price_native: Just return the price/decimal(expo)/timestamp from pyth oracle
    native public fun get_price_native(clock: &Clock, pyth_state: &State, pyth_price_info: &PriceInfoObject): (u64, u64, u64);

    // get_price_unsafe_native: return the price(uncheck timestamp)/decimal(expo)/timestamp from pyth oracle
    native public fun get_price_unsafe_native(pyth_price_info: &PriceInfoObject): (u64, u64, u64);

    // get_price_to_target_decimal: return the target decimal price and timestamp
    native public fun get_price_to_target_decimal(clock: &Clock, pyth_state: &State, pyth_price_info: &PriceInfoObject, target_decimal: u8): (u256, u64);

    // get_price_unsafe_to_target_decimal: return the target decimal price(uncheck timestamp) and timestamp
    native public fun get_price_unsafe_to_target_decimal(pyth_price_info: &PriceInfoObject, target_decimal: u8): (u256, u64);

    native public fun get_identifier_to_vector(price_info_object: &PriceInfoObject): vector<u8>;

    native public fun get_price_info_object_id(pyth_state: &State, price_feed_id: address): address;
}