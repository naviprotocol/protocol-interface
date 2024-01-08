module oracle::oracle {
    use sui::object::{UID};
    use sui::table::{Table};
    use sui::clock::{Clock};

    const VERSION: u64 = 1;
    const DEFAULT_UPDATE_INTERVAL: u64 = 30000;

    const INCORRECT_VERSION: u64 = 50000;
    const NOT_AVAILABLE_VERSION: u64 = 50001;
    const LENGTH_NOT_MATCH: u64 = 50002;
    const ENONEXISTENT_ORACLE: u64 = 50003;
    const EALREADY_EXIST_ORACLE: u64 = 50004;

    struct OracleAdminCap has key, store {
        id: UID,
    }

    struct OracleFeederCap has key, store {
        id: UID,
    }

    struct PriceOracle has key {
        id: UID,
        version: u64,
        update_interval: u64,
        price_oracles: Table<u8, Price>,
    }

    struct Price has store {
        value: u256,
        decimal: u8,
        timestamp: u64
    }

    native public fun get_token_price(clock: &Clock, price_oracle: &PriceOracle, oracle_id: u8): (bool, u256, u8);
}