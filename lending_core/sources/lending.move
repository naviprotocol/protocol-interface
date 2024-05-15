module lending_core::lending {
    use sui::balance::{Balance};
    use sui::clock::{Clock};
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};
    use oracle::oracle::{PriceOracle};

    use lending_core::pool::{Pool};
    use lending_core::storage::{Storage};
    use lending_core::incentive::{Incentive};
    use lending_core::account::{AccountCap};
    use lending_core::flash_loan::{Config as FlashLoanConfig, Receipt as FlashLoanReceipt};

    // Deprecated
    native public entry fun deposit<CoinType>(_clock: &Clock, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _deposit_coin: Coin<CoinType>, _amount: u64, _incentive: &mut Incentive, _ctx: &mut TxContext);

    // Deprecated
    native public entry fun withdraw<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _amount: u64, _to: address, _incentive: &mut Incentive, _ctx: &mut TxContext);

    // Deprecated
    native public entry fun borrow<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _amount: u64, _ctx: &mut TxContext);

    // Deprecated
    native public entry fun repay<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _repay_coin: Coin<CoinType>, _amount: u64, _ctx: &mut TxContext);

    // Deprecated
    native public entry fun liquidation_call<CoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<CoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, debt_coin: Coin<CoinType>, liquidate_user: address, liquidate_amount: u64, incentive: &mut Incentive, ctx: &mut TxContext);

    native public fun create_account(ctx: &mut TxContext): AccountCap;

    native public fun delete_account(cap: AccountCap);

    native public fun flash_loan_with_ctx<CoinType>(config: &FlashLoanConfig, pool: &mut Pool<CoinType>, amount: u64, ctx: &mut TxContext): (Balance<CoinType>, FlashLoanReceipt<CoinType>);

    native public fun flash_loan_with_account_cap<CoinType>(config: &FlashLoanConfig, pool: &mut Pool<CoinType>, amount: u64, account_cap: &AccountCap): (Balance<CoinType>, FlashLoanReceipt<CoinType>);

    native public fun flash_repay_with_ctx<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, receipt: FlashLoanReceipt<CoinType>, repay_balance: Balance<CoinType>, ctx: &mut TxContext): Balance<CoinType>;

    native public fun flash_repay_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, receipt: FlashLoanReceipt<CoinType>, repay_balance: Balance<CoinType>, account_cap: &AccountCap): Balance<CoinType>;
}