module lending_core::calculator {

    use sui::clock::{Clock};
    use oracle::oracle::{Self, PriceOracle};
    use lending_core::storage::{Self, Storage};

    native public fun caculate_utilization(storage: &mut Storage, asset: u8): u256;

    native public fun calculate_borrow_rate(storage: &mut Storage, asset: u8): u256;

    native public fun calculate_supply_rate(storage: &mut Storage, asset: u8, borrow_rate: u256): u256;

    /**
    * Title: Calculating compound interest
    * Input(current_timestamp): 1685029315718
    * Input(last_update_timestamp): 1685029255718
    * Input(rate): 6.3 * 1e27
    */
    native public fun calculate_compounded_interest(timestamp_difference: u256, rate: u256): u256;

    /**
    * Title: Calculating liner interest
    * Input(current_timestamp): 1685029315718
    * Input(last_update_timestamp): 1685029255718
    * Input(rate): 6.3 * 1e27
    */
    native public fun calculate_linear_interest(timestamp_difference: u256, rate: u256): u256;

    native public fun calculate_value(clock: &Clock, oracle: &PriceOracle, amount: u256, oracle_id: u8): u256;

    native public fun calculate_amount(clock: &Clock, oracle: &PriceOracle, value: u256, oracle_id: u8): u256;

}
