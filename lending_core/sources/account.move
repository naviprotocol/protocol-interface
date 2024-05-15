module lending_core::account {
    use sui::object::{UID};

    #[allow(unused_field)]
    struct AccountCap has key, store {
        id: UID,
        owner: address
    }

    native public fun account_owner(cap: &AccountCap): address;
}