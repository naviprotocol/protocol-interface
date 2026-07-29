module oracle::oracle_utils {

    // to_target_decimal_value: return value, using target decimal
    // value = 10000000000, decimal = 9, target_decimal: 6 -> value = 10000000
    // production env: max target_decimal = 16, max value = max u128 => max return < max u256
    native public fun to_target_decimal_value_safe(value: u256, decimal: u64, target_decimal: u64): u256;

    native public fun to_target_decimal_value(value: u256, decimal: u8, target_decimal: u8): u256;

    native public fun calculate_amplitude(a: u256, b: u256): u64;

    native public fun abs_sub(a: u256, b: u256): u256;

}
