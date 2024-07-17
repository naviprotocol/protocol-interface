module oracle::oracle_provider {
    use std::ascii::{String};

    #[allow(unused_field)]
    struct OracleProviderConfig has store {
        provider: OracleProvider,
        enable: bool,
        pair_id: vector<u8>,
    }

    #[allow(unused_field)]
    struct OracleProvider has copy, store, drop {
        name: String
    }

    native public fun get_pair_id_from_oracle_provider_config(provider_config: &OracleProviderConfig): vector<u8>;

    native public fun is_oracle_provider_config_enable(provider_config: &OracleProviderConfig): bool;

    native public fun get_provider_from_oracle_provider_config(provider_config: &OracleProviderConfig): OracleProvider;

    native public fun supra_provider(): OracleProvider;

    native public fun pyth_provider(): OracleProvider;

    native public fun new_empty_provider(): OracleProvider;

    native public fun to_string(f: &OracleProvider): String;

    native public fun is_empty(f: &OracleProvider): bool;
}