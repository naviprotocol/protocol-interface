#[allow(unused_field)]
module lending_core::storage {

    use std::vector;
    use std::ascii::{String};
    use sui::object::{UID};
    use sui::table::{Table};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, CoinMetadata};
    use sui::tx_context::{TxContext};
    use sui_system::sui_system::{SuiSystemState};
    use lending_core::pool::{Self, Pool, PoolAdminCap};
    use lending_core::version::{Self};

    struct OwnerCap has key, store {
        id: UID,
    }

    struct StorageAdminCap has key, store {
        id: UID,
    }

    struct Storage has key, store {
        id: UID,
        version: u64,
        paused: bool, // Whether the pool is paused
        reserves: Table<u8, ReserveData>, // Reserve list. like: {0: ReserveData<USDT>, 1: ReserveData<ETH>}
        reserves_count: u8, // Total reserves count
        users: vector<address>, // uset list, like [0x01, 0x02]
        user_info: Table<address, UserInfo>
    }

    // supply_balance & borrow_balance, It is used to keep track of all balance
    struct ReserveData has store {
        id: u8, // reserve index
        oracle_id: u8, // The id from navi oracle, update from admin
        coin_type: String, // The coin type, like 0x02::sui::SUI
        is_isolated: bool, // THe isolated of the reserve, update from admin
        supply_cap_ceiling: u256, // Total supply limit of reserve, update from admin
        borrow_cap_ceiling: u256, // Total borrow percentage of reserve, update from admin
        current_supply_rate: u256, // Current supply rates, update from protocol
        current_borrow_rate: u256, // Current borrow rates, update from protocol
        current_supply_index: u256, // The supply exchange rate, update from protocol
        current_borrow_index: u256, // The borrow exchange rate, update from protocol
        supply_balance: TokenBalance, // The total amount deposit inside the pool
        borrow_balance: TokenBalance, // The total amount borrow inside the pool
        last_update_timestamp: u64, // Last update time for reserve, update from protocol
        // Loan-to-value, used to define the maximum amount of assets that can be borrowed against a given collateral
        ltv: u256,
        treasury_factor: u256, // The fee ratio, update from admin
        treasury_balance: u256, // The fee balance, update from protocol
        borrow_rate_factors: BorrowRateFactors, // Basic Configuration, rate and multiplier etc.
        liquidation_factors: LiquidationFactors, // Liquidation configuration
        // Reserved fields, no use for now
        reserve_field_a: u256,
        reserve_field_b: u256,
        reserve_field_c: u256,
    }

    struct UserInfo has store {
        collaterals: vector<u8>,
        loans: vector<u8>
    }

    struct ReserveConfigurationMap has copy, store {
        data: u256
    }

    struct UserConfigurationMap has copy, store {
        data: u256
    }

    struct TokenBalance has store {
        user_state: Table<address, u256>,
        total_supply: u256,
    }

    struct BorrowRateFactors has store {
        // Base borrow rate of the asset
        base_rate: u256,
        multiplier: u256,
        jump_rate_multiplier: u256,
        // Used to set community incentives
        reserve_factor: u256,
        optimal_utilization: u256
    }

    struct LiquidationFactors has store {
        ratio: u256, 
        bonus: u256,
        threshold: u256,
    }

    struct Emode has store {
		emodes_pair: Table<u64, EmodeConfig>,
		user_emode_id: Table<address, u64>,
        next_emode_id: u64, // each emode has a unique id, starting from 0
	}

    struct EmodeConfig has store {
        assetA: EmodeAsset,
        assetB: EmodeAsset,
        isActive: bool
    }

    struct EmodeAsset has store {
        assetId: u8,
        isCollateral: bool,
        isDebt: bool,
        ltv: u256,
        lt: u256,
        liquidation_bonus: u256
    }

    struct MarketInfo has store {
        market_id: u64,
        last_market_id: u64,
        is_main_market: bool
    }

    // Event
    struct StorageConfiguratorSetting has copy, drop {  
        sender: address,
        configurator: address,
        value: bool,
    }

    struct Paused has copy, drop {
        paused: bool
    }

    struct WithdrawTreasuryEvent has copy, drop {
        sender: address,
        recipient: address,
        asset: u8,
        amount: u256,
        poolId: address,
        before: u256,
        after: u256,
        index: u256,
    }

    struct LiquidatorSet has copy, drop {
        liquidator: address,
        user: address,
        is_liquidatable: bool
    }

    struct ProtectedUserSet has copy, drop {
        user: address,
        is_protected: bool
    }

    struct EmodePairCreated has copy, drop {
        emode_id: u64,
        assetA: u8,
        assetB: u8,
    }

    struct EmodeParamSet has copy, drop {
        emode_id: u64,
        asset: u8,
        value: u256,
        param_type: String,
    }

    struct EmodeUserStateChanged has copy, drop {
        user: address,
        emode_id: u64,
        is_entered: bool
    }

    struct MarketCreated has copy, drop { market_id: u64 }

    struct BorrowWeightSet has copy, drop {
        asset: u8,
        weight: u64,
    }

    struct BorrowWeightRemoved has copy, drop { asset: u8 }

    // === dynamic field keys ===
    struct DESIGNATED_LIQUIDATORS_KEY has copy, drop, store {}

    struct PROTECTED_LIQUIDATION_USERS_KEY has copy, drop, store {}

    // ------------------ Emode related functions ------------------
    struct EMODE_KEY has copy, drop, store {}

    // ------------------ Multiple markets related functions ------------------
    struct MARKET_KEY has copy, drop, store {}

    // ------------------ Borrow Weight related functions ------------------
    struct BORROW_WEIGHT_KEY has copy, drop, store {}

    native public fun when_not_paused(storage: &Storage);

    native public fun version_verification(storage: &Storage);

    native public entry fun version_migrate(_: &StorageAdminCap, storage: &mut Storage);

    native public entry fun init_reserve<CoinType>(_: &StorageAdminCap, pool_admin_cap: &PoolAdminCap, clock: &Clock, storage: &mut Storage, oracle_id: u8, is_isolated: bool, supply_cap_ceiling: u256, borrow_cap_ceiling: u256, base_rate: u256, optimal_utilization: u256, multiplier: u256, jump_rate_multiplier: u256, reserve_factor: u256, ltv: u256, treasury_factor: u256, liquidation_ratio: u256, liquidation_bonus: u256, liquidation_threshold: u256, coin_metadata: &CoinMetadata<CoinType>, ctx: &mut TxContext);

    //////////////////////////////////////////////////////////////////////////////////////////////
    //                    The methods required for protocol parameter updates                   //
    //////////////////////////////////////////////////////////////////////////////////////////////
    native public entry fun set_pause(_: &OwnerCap, storage: &mut Storage, val: bool);

    native public fun set_supply_cap(_: &OwnerCap, storage: &mut Storage, asset: u8, supply_cap_ceiling: u256);

    native public fun set_borrow_cap(_: &OwnerCap, storage: &mut Storage, asset: u8, borrow_cap_ceiling: u256);

    native public fun set_ltv(_: &OwnerCap, storage: &mut Storage, asset: u8, ltv: u256);

    native public fun set_treasury_factor(_: &OwnerCap, storage: &mut Storage, asset: u8, treasury_factor: u256);

    native public fun set_base_rate(_: &OwnerCap, storage: &mut Storage, asset: u8, base_rate: u256);

    native public fun set_multiplier(_: &OwnerCap, storage: &mut Storage, asset: u8, multiplier: u256);

    native public fun set_jump_rate_multiplier(_: &OwnerCap, storage: &mut Storage, asset: u8, jump_rate_multiplier: u256);

    native public fun set_reserve_factor(_: &OwnerCap, storage: &mut Storage, asset: u8, reserve_factor: u256);

    native public fun set_optimal_utilization(_: &OwnerCap, storage: &mut Storage, asset: u8, optimal_utilization: u256);

    native public fun set_liquidation_ratio(_: &OwnerCap, storage: &mut Storage, asset: u8, liquidation_ratio: u256);

    native public fun set_liquidation_bonus(_: &OwnerCap, storage: &mut Storage, asset: u8, liquidation_bonus: u256);

    native public fun set_liquidation_threshold(_: &OwnerCap, storage: &mut Storage, asset: u8, liquidation_threshold: u256);

    //////////////////////////////////////////////////////////////////////////////////////////////
    //                             The methods required to get value                            //
    //////////////////////////////////////////////////////////////////////////////////////////////
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

    native public fun withdraw_treasury<CoinType>(_: &StorageAdminCap, pool_admin_cap: &PoolAdminCap, storage: &mut Storage, asset: u8, pool: &mut Pool<CoinType>, amount: u64, recipient: address, ctx: &mut TxContext);

    native public fun withdraw_treasury_v2<CoinType>(_: &StorageAdminCap, pool_admin_cap: &PoolAdminCap, storage: &mut Storage, asset: u8, pool: &mut Pool<CoinType>, amount: u64, recipient: address, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    native public fun destory_user(_: &StorageAdminCap, _storage: &mut Storage);

    native public fun mint_owner_cap(_: &StorageAdminCap, recipient: address, ctx: &mut TxContext);

    native public fun is_liquidatable(storage: &mut Storage, liquidator: address, user: address): bool;

    native public fun when_liquidatable(storage: &mut Storage, liquidator: address, user: address);

    native public fun init_emode_for_main_market(_: &StorageAdminCap, storage: &mut Storage, ctx: &mut TxContext);

    native public fun verify_emode_support(storage: &Storage, user: address, asset_id: u8, check_is_collateral: bool, check_is_debt: bool);

    native public fun is_passed_emode_restrictions(storage: &Storage, user: address, asset_id: u8, check_is_collateral: bool, check_is_debt: bool): bool;

    native public fun is_in_emode(storage: &Storage, user: address): bool;

    native public fun get_user_emode_id(storage: &Storage, user: address): u64;

    // return (ltvA, ltA, liquidation_bonusA, isCollateralA, isDebtA, ltvB, ltB, liquidation_bonusB, isCollateralB, isDebtB, isActive)
    native public fun get_emode_info(storage: &Storage, emode_id: u64): (u256, u256, u256, bool, bool, u256, u256, u256, bool, bool, bool);

    // return (ltv, lt, liquidation_bonus)
    native public fun get_emode_asset_info(storage: &Storage, emode_id: u64, asset: u8): (u256, u256, u256);

    native public fun init_for_main_market(_: &StorageAdminCap, storage: &mut Storage);

    native public fun get_market_id(storage: &Storage): u64;

    // return (market_id, last_market_id, is_main_market)
    native public fun get_storage_market_info(storage: &Storage): (u64, u64, bool);

    native public fun verify_market_storage_pool<CoinType>(storage: &Storage, pool: &Pool<CoinType>);

    native public fun init_borrow_weight_for_main_market(_: &StorageAdminCap, storage: &mut Storage, ctx: &mut TxContext);

    native public fun get_borrow_weight(storage: &Storage, asset: u8): u64;

    // legacy: should be test only, but it's already public in the old version
    // #[test_only]
    native public fun get_reserve_for_testing(storage: &Storage, asset: u8): (&ReserveData);

}
