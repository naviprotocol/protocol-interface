module lending_core::dynamic_calculator {
    use sui::clock::{Clock};
    use oracle::oracle::{PriceOracle};
    use lending_core::pool::{ Pool};
    use lending_core::storage::{Storage};

    native public fun dynamic_health_factor<CoinType>(clock: &Clock, storage: &mut Storage, oracle: &PriceOracle, pool: &mut Pool<CoinType>, user: address, asset: u8, estimate_supply_value: u64, estimate_borrow_value: u64, is_increase: bool): u256;

    native public fun dynamic_user_health_collateral_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address, asset: u8, estimate_value: u256, is_increase: bool): u256;

    native public fun dynamic_user_health_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address, asset: u8, estimate_value: u256, is_increase: bool): u256;

    native public fun dynamic_user_collateral_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, asset: u8, user: address, estimate_value: u256, is_increase: bool): u256;

    native public fun dynamic_user_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, asset: u8, user: address, estimate_value: u256, is_increase: bool): u256;

    native public fun dynamic_user_collateral_balance(clock: &Clock, storage: &mut Storage, asset: u8, user: address, estimate_value: u256, is_increase: bool): u256;

    native public fun dynamic_user_loan_balance(clock: &Clock, storage: &mut Storage, asset: u8, user: address, estimate_value: u256, is_increase: bool): u256;

    native public fun dynamic_liquidation_threshold(clock: &Clock, storage: &mut Storage, oracle: &PriceOracle, user: address, asset: u8, estimate_value: u256, is_increase: bool): u256;

    native public fun calculate_current_index(clock: &Clock, storage: &mut Storage, asset: u8): (u256, u256);

    native public fun dynamic_calculate_apy<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, estimate_supply_value: u64, estimate_borrow_value: u64, is_increase: bool): (u256, u256);

    native public fun dynamic_calculate_borrow_rate( clock: &Clock, storage: &mut Storage, asset: u8, estimate_supply_value: u256, estimate_borrow_value: u256, is_increase: bool): u256;
    
    native public fun dynamic_calculate_supply_rate(clock: &Clock, storage: &mut Storage, asset: u8, borrow_rate: u256, estimate_supply_value: u256, estimate_borrow_value: u256, is_increase: bool): u256;

    native public fun dynamic_caculate_utilization(clock: &Clock, storage: &mut Storage, asset: u8, estimate_supply_value: u256, estimate_borrow_value: u256, is_increase: bool): u256;
}