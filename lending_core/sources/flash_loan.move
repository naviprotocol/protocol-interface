module lending_core::flash_loan {

    use std::ascii::{String};
    use sui::object::{UID};
    use sui::table::{Table};
    use lending_core::version::{Self};
    use lending_core::pool::{Self};
    use lending_core::storage::{StorageAdminCap};

    struct Config has key, store {
        id: UID,
        version: u64,
        support_assets: Table<vector<u8>, address>, // Table<String, address>, 0x2::sui::SUI -> address
        assets: Table<address, AssetConfig>,
    }

    struct AssetConfig has key, store {
        id: UID,
        asset_id: u8,
        coin_type: String,
        pool_id: address, // lending pool 1000 -> 10
        rate_to_supplier: u64, // x * MultiBy --> 10% == 0.1 * 10000 = 1000, 0.09 -> 0.09 * 80% = supplier
        rate_to_treasury: u64, // x * MultiBy --> 10% == 0.1 * 10000 = 1000
        max: u64,
        min: u64,
    }

    struct Receipt<phantom CoinType> {
        user: address,
        asset: address,
        amount: u64,
        pool: address,
        fee_to_supplier: u64,
        fee_to_treasury: u64,
    }

    // === dynamic field keys ===
    struct MARKET_ID_KEY has copy, drop, store {}

    // Event
    struct ConfigCreated has copy, drop {
        sender: address,
        id: address,
    }

    struct AssetConfigCreated has copy, drop {
        sender: address,
        config_id: address,
        asset_id: address,
    }

    struct FlashLoan has copy, drop {
        sender: address,
        asset: address,
        amount: u64,
    }

    struct FlashRepay has copy, drop {
        sender: address,
        asset: address,
        amount: u64,
        fee_to_supplier: u64,
        fee_to_treasury: u64,
    }

    native public fun version_verification(config: &Config);

    native public fun version_migrate(_: &StorageAdminCap, cfg: &mut Config);

    // only current main market needs to be initialized
    // other markets will be initialized when creating reserves
    native public fun init_config_for_main_market(_: &StorageAdminCap, config: &mut Config);

    native public fun parsed_receipt<T>(receipt: &Receipt<T>): (address, address, u64, address, u64, u64);

    native public fun get_asset<T>(config: &Config): (address, u8, vector<u8>, address, u64, u64, u64, u64);

    native public fun get_market_id(config: &Config): u64;

}
