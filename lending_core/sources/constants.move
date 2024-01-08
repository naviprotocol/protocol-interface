module lending_core::constants {
    public fun seconds_per_year(): u256 {60 * 60 * 24 * 365}
    public fun option_type_supply(): u8 {1}
    public fun option_type_withdraw(): u8 {2}
    public fun option_type_borrow(): u8 {3}
    public fun option_type_repay(): u8 {4}
    public fun max_number_of_reserves(): u8 {255}
    public fun version(): u64 {6}
    public fun FlashLoanMultiple(): u64 {10000}
}