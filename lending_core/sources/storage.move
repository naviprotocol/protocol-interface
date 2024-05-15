module lending_core::storage {
    use std::ascii::{String};
    use sui::object::{UID};
    use sui::table::{Table};

    #[allow(unused_field)]
    struct Storage has key, store {
        id: UID,
        version: u64,
        paused: bool,
        reserves: Table<u8, ReserveData>,
        reserves_count: u8,
        users: vector<address>,
        user_info: Table<address, UserInfo>
    }

    #[allow(unused_field)]
    struct ReserveData has store {
        id: u8,
        oracle_id: u8,
        coin_type: String,
        is_isolated: bool,
        supply_cap_ceiling: u256,
        borrow_cap_ceiling: u256,
        current_supply_rate: u256,
        current_borrow_rate: u256,
        current_supply_index: u256,
        current_borrow_index: u256,
        supply_balance: TokenBalance,
        borrow_balance: TokenBalance,
        last_update_timestamp: u64,
        ltv: u256,
        treasury_factor: u256,
        treasury_balance: u256,
        borrow_rate_factors: BorrowRateFactors,
        liquidation_factors: LiquidationFactors,
        reserve_field_a: u256,
        reserve_field_b: u256,
        reserve_field_c: u256,
    }

    #[allow(unused_field)]
    struct UserInfo has store {
        collaterals: vector<u8>,
        loans: vector<u8>
    }

    #[allow(unused_field)]
    struct TokenBalance has store {
        user_state: Table<address, u256>,
        total_supply: u256,
    }

    #[allow(unused_field)]
    struct BorrowRateFactors has store {
        base_rate: u256,
        multiplier: u256,
        jump_rate_multiplier: u256,
        reserve_factor: u256,
        optimal_utilization: u256
    }

    #[allow(unused_field)]
    struct LiquidationFactors has store {
        ratio: u256, 
        bonus: u256,
        threshold: u256,
    }
    
    native public fun reserve_validation<CoinType>(storage: &Storage);
    
    native public fun pause(storage: &Storage): bool;

    native public fun get_reserves_count(storage: &Storage): u8;

    native public fun get_user_assets(storage: &Storage, user: address): (vector<u8>, vector<u8>);

    native public fun get_oracle_id(storage: &Storage, asset: u8): u8;

    native public fun get_coin_type(storage: &Storage, asset: u8): String;

    native public fun get_supply_cap_ceiling(storage: &mut Storage, asset: u8): u256;

    native public fun get_borrow_cap_ceiling_ratio(storage: &mut Storage, asset: u8): u256;

    native public fun get_current_rate(storage: &mut Storage, asset: u8): (u256, u256);

    native public fun get_index(storage: &mut Storage, asset: u8): (u256, u256);

    native public fun get_total_supply(storage: &mut Storage, asset: u8): (u256, u256);

    native public fun get_user_balance(storage: &mut Storage, asset: u8, user: address): (u256, u256);

    native public fun get_last_update_timestamp(storage: &Storage, asset: u8): u64;

    native public fun get_asset_ltv(storage: &Storage, asset: u8): u256;

    native public fun get_treasury_factor(storage: &mut Storage, asset: u8): u256;

    native public fun get_treasury_balance(storage: &Storage, asset: u8): u256;

    native public fun get_borrow_rate_factors(storage: &mut Storage, asset: u8): (u256, u256, u256, u256, u256);

    native public fun get_liquidation_factors(storage: &mut Storage, asset: u8): (u256, u256, u256);
}