module lending_core::validation {

    use lending_core::storage::{Self, Storage};

    /**
    * Title: Validates a deposit action
    * storage: -
    * asset: -
    * amount:
    *   - The decimals of ETH is 9
    *   - Total collateral is 1.2ETH --> amount = 1.2 * 1e9 = 1200000000
    */
    native public fun validate_deposit<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_withdraw<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    /**
    * Title: Validates borrow action
    * storage: -
    * asset: -
    * amount:
    *   - The decimals of ETH is 9
    *   - borrow amount is 1.2ETH --> amount = 1.2 * 1e9 = 1200000000
    */
    native public fun validate_borrow<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_repay<CoinType>(storage: &mut Storage, asset: u8, amount: u256);

    native public fun validate_liquidate<LoanCointype, CollateralCoinType>(storage: &mut Storage, debt_asset: u8, collateral_asset: u8, amount: u256);

}
