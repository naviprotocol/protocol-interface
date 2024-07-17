module oracle::oracle_utils {
    native public fun to_target_decimal_value_safe(value: u256, decimal: u64, target_decimal: u64): u256;

    native public fun to_target_decimal_value(value: u256, decimal: u8, target_decimal: u8): u256;

    native public fun calculate_amplitude(a: u256, b: u256): u64;

    native public fun abs_sub(a: u256, b: u256): u256;
}