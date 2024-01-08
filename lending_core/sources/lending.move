#[allow(unused_mut_parameter, unused_field)]
module lending_core::lending {
    use sui::clock::{Clock};
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};
    use oracle::oracle::{PriceOracle};

    use lending_core::pool::{Pool};
    use lending_core::storage::{Storage};
    use lending_core::incentive::{Incentive};
    use lending_core::account::{AccountCap};

    friend lending_core::incentive_v2;

    struct DepositEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
    }

    struct WithdrawEvent has copy, drop {
        reserve: u8,
        sender: address,
        to: address,
        amount: u64,
    }

    struct BorrowEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
    }

    struct RepayEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
    }

    struct LiquidationCallEvent has copy, drop {
        reserve: u8,
        sender: address,
        liquidate_user: address,
        liquidate_amount: u64,
    }

    native public entry fun deposit<CoinType>(_clock: &Clock, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _deposit_coin: Coin<CoinType>, _amount: u64, _incentive: &mut Incentive, _ctx: &mut TxContext);

    native public entry fun withdraw<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _amount: u64, _to: address, _incentive: &mut Incentive, _ctx: &mut TxContext);

    native public entry fun borrow<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _amount: u64, _ctx: &mut TxContext);

    native public entry fun repay<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _repay_coin: Coin<CoinType>, _amount: u64, _ctx: &mut TxContext);

    native public entry fun liquidation_call<CoinType, CollateralCoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, debt_asset: u8, debt_pool: &mut Pool<CoinType>, collateral_asset: u8, collateral_pool: &mut Pool<CollateralCoinType>, debt_coin: Coin<CoinType>, liquidate_user: address, liquidate_amount: u64, incentive: &mut Incentive, ctx: &mut TxContext);

    native public fun create_account(ctx: &mut TxContext): AccountCap;

    native public fun delete_account(cap: AccountCap);
}