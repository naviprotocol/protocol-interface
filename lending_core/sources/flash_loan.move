module lending_core::flash_loan {
    use std::ascii::{String};

    use sui::object::{UID};
    use sui::table::{Table};

    #[allow(unused_field)]
    struct Config has key, store {
        id: UID,
        version: u64,
        support_assets: Table<vector<u8>, address>,
        assets: Table<address, AssetConfig>,
    }

    #[allow(unused_field)]
    struct AssetConfig has key, store {
        id: UID,
        asset_id: u8,
        coin_type: String,
        pool_id: address,
        rate_to_supplier: u64,
        rate_to_treasury: u64,
        max: u64,
        min: u64,
    }

    #[allow(unused_field)]
    struct Receipt<phantom CoinType> {
        user: address,
        asset: address,
        amount: u64,
        pool: address,
        fee_to_supplier: u64,
        fee_to_treasury: u64,
    }

    // returns user/asset/amount/pool/fee_to_supplier/fee_to_treasury
    native public fun parsed_receipt<T>(receipt: &Receipt<T>): (address, address, u64, address, u64, u64);

    native public fun get_asset<T>(config: &Config): (address, u8, vector<u8>, address, u64, u64, u64, u64);
}