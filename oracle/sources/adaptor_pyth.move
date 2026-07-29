module oracle::adaptor_pyth {

    use sui::clock::{Clock};
    use pyth::state::{State};
    use pyth::price_info::{PriceInfoObject};
    use pyth_pro_compatible::state::{State as ProState};
    use pyth_pro_compatible::price_info::{PriceInfoObject as ProPriceInfoObject};

    // Legacy Pyth (0x8d97..) is retired after the Pyth Core upgrade (2026-07-31).
    // Each legacy function below is kept as an abort stub for upgrade compatibility,
    // with its pro-compatible replacement (_v2) directly underneath.
    #[allow(unused_variable)]
    native public fun get_price_native(clock: &Clock, pyth_state: &State, pyth_price_info: &PriceInfoObject): (u64, u64, u64);

    // get_price_native_v2: Just return the price/decimal(expo)/timestamp from pyth oracle
    native public fun get_price_native_v2(clock: &Clock, pyth_state: &ProState, pyth_price_info: &ProPriceInfoObject): (u64, u64, u64);

    #[allow(unused_variable)]
    native public fun get_price_unsafe_native(pyth_price_info: &PriceInfoObject): (u64, u64, u64);

    // get_price_unsafe_native_v2: return the price(uncheck timestamp)/decimal(expo)/timestamp from pyth oracle
    native public fun get_price_unsafe_native_v2(pyth_price_info: &ProPriceInfoObject): (u64, u64, u64);

    #[allow(unused_variable)]
    native public fun get_price_to_target_decimal(clock: &Clock, pyth_state: &State, pyth_price_info: &PriceInfoObject, target_decimal: u8): (u256, u64);

    // get_price_to_target_decimal_v2: return the target decimal price and timestamp
    native public fun get_price_to_target_decimal_v2(clock: &Clock, pyth_state: &ProState, pyth_price_info: &ProPriceInfoObject, target_decimal: u8): (u256, u64);

    #[allow(unused_variable)]
    native public fun get_price_unsafe_to_target_decimal(pyth_price_info: &PriceInfoObject, target_decimal: u8): (u256, u64);

    // get_price_unsafe_to_target_decimal_v2: return the target decimal price(uncheck timestamp) and timestamp
    native public fun get_price_unsafe_to_target_decimal_v2(pyth_price_info: &ProPriceInfoObject, target_decimal: u8): (u256, u64);

    #[allow(unused_variable)]
    native public fun get_identifier_to_vector(price_info_object: &PriceInfoObject): vector<u8>;

    native public fun get_identifier_to_vector_v2(price_info_object: &ProPriceInfoObject): vector<u8>;

    #[allow(unused_variable)]
    native public fun get_price_info_object_id(pyth_state: &State, price_feed_id: address): address;

    native public fun get_price_info_object_id_v2(pyth_state: &ProState, price_feed_id: address): address;

}
