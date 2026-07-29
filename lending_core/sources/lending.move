#[allow(unused_mut_parameter, unused_function)]
module lending_core::lending {

    use sui::balance::{Balance};
    use sui::clock::{Clock};
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};
    use oracle::oracle::{PriceOracle};
    use lending_core::pool::{Self, Pool};
    use lending_core::storage::{Self, Storage};
    use lending_core::incentive::{Incentive};
    use lending_core::account::{AccountCap};
    use lending_core::flash_loan::{Config as FlashLoanConfig, Receipt as FlashLoanReceipt};
    use sui_system::sui_system::{SuiSystemState};

    // Event
    struct DepositEvent has copy, drop {
        reserve: u8,
        sender: address,
        amount: u64,
    }

    struct DepositOnBehalfOfEvent has copy, drop {
        reserve: u8,
        sender: address,
        user: address,
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

    struct RepayOnBehalfOfEvent has copy, drop {
        reserve: u8,
        sender: address,
        user: address,
        amount: u64,
    }

    #[allow(unused_field)]
    struct LiquidationCallEvent has copy, drop {
        reserve: u8,
        sender: address,
        liquidate_user: address,
        liquidate_amount: u64,
    }

    struct LiquidationEvent has copy, drop {
        sender: address,
        user: address,
        collateral_asset: u8,
        collateral_price: u256,
        collateral_amount: u64,
        treasury: u64,
        debt_asset: u8,
        debt_price: u256,
        debt_amount: u64,
    }

    native public entry fun deposit<CoinType>(_clock: &Clock, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _deposit_coin: Coin<CoinType>, _amount: u64, _incentive: &mut Incentive, _ctx: &mut TxContext);

    native public entry fun withdraw<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _amount: u64, _to: address, _incentive: &mut Incentive, _ctx: &mut TxContext);

    native public entry fun borrow<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _amount: u64, _ctx: &mut TxContext);

    native public entry fun repay<CoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _pool: &mut Pool<CoinType>, _asset: u8, _repay_coin: Coin<CoinType>, _amount: u64, _ctx: &mut TxContext);

    native public entry fun liquidation_call<CoinType, CollateralCoinType>(_clock: &Clock, _oracle: &PriceOracle, _storage: &mut Storage, _debt_asset: u8, _debt_pool: &mut Pool<CoinType>, _collateral_asset: u8, _collateral_pool: &mut Pool<CollateralCoinType>, _debt_coin: Coin<CoinType>, _liquidate_user: address, _liquidate_amount: u64, _incentive: &mut Incentive, _ctx: &mut TxContext);

    // Account Cap
    native public fun create_account(ctx: &mut TxContext): AccountCap;

    native public fun delete_account(_cap: AccountCap);

    native public fun flash_loan_with_ctx<CoinType>(config: &FlashLoanConfig, pool: &mut Pool<CoinType>, amount: u64, ctx: &mut TxContext): (Balance<CoinType>, FlashLoanReceipt<CoinType>);

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun flash_loan_with_ctx_v2<CoinType>(config: &FlashLoanConfig, pool: &mut Pool<CoinType>, amount: u64, system_state: &mut SuiSystemState, ctx: &mut TxContext): (Balance<CoinType>, FlashLoanReceipt<CoinType>);

    native public fun flash_loan_with_account_cap<CoinType>(config: &FlashLoanConfig, pool: &mut Pool<CoinType>, amount: u64, account_cap: &AccountCap): (Balance<CoinType>, FlashLoanReceipt<CoinType>);

    // V2: Supports all assets. Adds sui_system and ctx parameters for SUI pools with staking/unstaking.
    native public fun flash_loan_with_account_cap_v2<CoinType>(config: &FlashLoanConfig, pool: &mut Pool<CoinType>, amount: u64, account_cap: &AccountCap, system_state: &mut SuiSystemState, ctx: &mut TxContext): (Balance<CoinType>, FlashLoanReceipt<CoinType>);

    native public fun flash_repay_with_ctx<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, receipt: FlashLoanReceipt<CoinType>, repay_balance: Balance<CoinType>, ctx: &mut TxContext): Balance<CoinType>;

    native public fun flash_repay_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, receipt: FlashLoanReceipt<CoinType>, repay_balance: Balance<CoinType>, account_cap: &AccountCap): Balance<CoinType>;

    native public fun verify_market_storage_pool<CoinType>(storage: &Storage, pool: &Pool<CoinType>);

    native public fun verify_market_flash_loan_config_pool<CoinType>(config: &FlashLoanConfig, pool: &Pool<CoinType>);

    // ------------------ Emode related functions ------------------
    native public fun enter_emode(storage: &mut Storage, emode_id: u64, ctx: &mut TxContext);

    native public fun enter_emode_with_account_cap(storage: &mut Storage, emode_id: u64, account_cap: &AccountCap);

    native public fun exit_emode(storage: &mut Storage, ctx: &mut TxContext);

    native public fun exit_emode_with_account_cap(storage: &mut Storage, account_cap: &AccountCap);

    // ------------------ State related functions ------------------
    native public fun update_state_of_user(clock: &Clock, storage: &mut Storage, user: address);

    native public fun update_state_of_all(clock: &Clock, storage: &mut Storage);

}
