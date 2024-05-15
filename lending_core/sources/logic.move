module lending_core::logic {
    use sui::clock::{Clock};

    use oracle::oracle::{PriceOracle};
    use lending_core::storage::{Storage};

    native public fun is_health(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): bool;

    native public fun user_health_factor_batch(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, users: vector<address>): vector<u256>;

    native public fun user_health_factor(clock: &Clock, storage: &mut Storage, oracle: &PriceOracle, user: address): u256;

    native public fun dynamic_liquidation_threshold(clock: &Clock, storage: &mut Storage, oracle: &PriceOracle, user: address): u256;

    native public fun user_health_collateral_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    native public fun user_health_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    native public fun user_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, asset: u8, user: address): u256;

    native public fun user_collateral_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, asset: u8, user: address): u256;

    native public fun user_collateral_balance(storage: &mut Storage, asset: u8, user: address): u256;

    native public fun user_loan_balance(storage: &mut Storage, asset: u8, user: address): u256;

    native public fun is_collateral(storage: &mut Storage, asset: u8, user: address): bool;

    native public fun is_loan(storage: &mut Storage, asset: u8, user: address): bool;
    
    native public fun calculate_avg_ltv(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    native public fun calculate_avg_threshold(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;
}