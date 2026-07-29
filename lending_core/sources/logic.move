module lending_core::logic {

    use std::vector;
    use sui::address;
    use sui::clock::{Self, Clock};
    use oracle::oracle::{PriceOracle};
    use lending_core::storage::{Self, Storage};

    struct StateUpdated has copy, drop {
        user: address,
        asset: u8,
        user_supply_balance: u256,
        user_borrow_balance: u256,
        new_supply_index: u256,
        new_borrow_index: u256,
    }

    /**
    * Title: check the user's health status, is the health factors greater than 1.
    * Returns: true/false.
    */
    native public fun is_health(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): bool;

    native public fun user_health_factor_batch(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, users: vector<address>): vector<u256>;

    /**
    * Title: get the user's health factors.
    * Returns: RAY.
    */
    native public fun user_health_factor(clock: &Clock, storage: &mut Storage, oracle: &PriceOracle, user: address): u256;

    native public fun dynamic_liquidation_threshold(clock: &Clock, storage: &mut Storage, oracle: &PriceOracle, user: address): u256;

    /**
    * Title: get the number of collateral (based on the liquidation threshold and LTV) that the user has in all assets.
    * Returns: USD amount.
    */
    native public fun user_health_collateral_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    /**
    * Title: get the number of borrowings the user has in all asset.
    * Returns: USD amount.
    */
    native public fun user_health_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    // user_health_loan_value scaled by borrow weight
    native public fun weighted_user_health_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    /**
    * Title: get the number of borrowings the user has in given asset.
    * Returns: USD amount.
    */
    native public fun user_loan_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, asset: u8, user: address): u256;

    /**
    * Title: get the number of collaterals the user has in given asset.
    * Returns: USD amount.
    */
    native public fun user_collateral_value(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, asset: u8, user: address): u256;

    /**
    * Title: get the number of collaterals the user has in given asset, include interest.
    * Returns: token amount.
    */
    native public fun user_collateral_balance(storage: &mut Storage, asset: u8, user: address): u256;

    /**
    * Title: get the number of borrowings the user has in given asset, include interest.
    * Returns: token amount.
    */
    native public fun user_loan_balance(storage: &mut Storage, asset: u8, user: address): u256;

    /**
    * Title: check if the user's collateral list contains assets.
    * Returns: true/false.
    */
    native public fun is_collateral(storage: &mut Storage, asset: u8, user: address): bool;

    /**
    * Title: check if the user's loan list contains assets.
    * Returns: true/false.
    */
    native public fun is_loan(storage: &mut Storage, asset: u8, user: address): bool;

    native public fun calculate_avg_ltv(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

    // this is logically the same as dynamic_liquidation_threshold
    // was used in old version, now is a pure getter function
    native public fun calculate_avg_threshold(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, user: address): u256;

}
