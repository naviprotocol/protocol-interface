module lending_core::version {
    native public fun this_version(): u64;

    native public fun next_version(): u64;

    native public fun pre_check_version(v: u64);
}