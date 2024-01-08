module lending_core::calculator {
    use sui::clock::{Clock};
    use oracle::oracle::{PriceOracle};
    use lending_core::storage::{Storage};

    native public fun caculate_utilization(storage: &mut Storage, asset: u8): u256;

    native public fun calculate_borrow_rate(storage: &mut Storage, asset: u8): u256;

    native public fun calculate_supply_rate(storage: &mut Storage, asset: u8, borrow_rate: u256): u256;
    
    native public fun calculate_compounded_interest(timestamp_difference: u256, rate: u256): u256;

    native public fun calculate_linear_interest(timestamp_difference: u256, rate: u256): u256;

    native public fun calculate_value(clock: &Clock, oracle: &PriceOracle, amount: u256, oracle_id: u8): u256;
    
    native public fun calculate_amount(clock: &Clock, oracle: &PriceOracle, value: u256, oracle_id: u8): u256;
}
