module lending_core::validation {
    use lending_core::storage::{Storage};

    native public fun validate_deposit<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_withdraw<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_borrow<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_repay<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_liquidate<LoanCointype, CollateralCoinType>(storage: &mut Storage, debt_asset: u8, collateral_asset: u8, amount: u256);
}