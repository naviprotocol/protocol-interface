module lending_core::account {

    use sui::object::{UID};
    use std::ascii::{String};

    struct AccountCap has key, store {
        id: UID,
        owner: address
    }

    // Display Field For Account Cap
    struct AccountField has store {
        account_name: String,
        account_description: String,
        last_update_time: String,
        market_balance: String,
    }

    // ==== dynamic field keys ====
    struct AccountFieldKey has copy, drop, store {}

    native public fun account_owner(cap: &AccountCap): address;

    native public fun set_account_name(cap: &mut AccountCap, name: String);

    native public fun set_account_description(cap: &mut AccountCap, description: String);

    native public fun set_last_update_time(cap: &mut AccountCap, last_update_time: String);

    native public fun set_market_balance(cap: &mut AccountCap, balance: String);

    native public fun get_account_info(cap: &AccountCap): (String, String, String, String);

}
