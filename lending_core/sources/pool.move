#[allow(unused_field, unused_mut_parameter)]
module lending_core::pool {

    use std::ascii::{String};
    use sui::coin::{Coin};
    use sui::object::{UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{TxContext};
    use sui::vec_map::{VecMap};
    use sui_system::sui_system::{SuiSystemState};
    use sui::sui::{SUI};
    use liquid_staking::stake_pool::{StakePool, OperatorCap};
    use liquid_staking::cert::{Metadata, CERT};

    // The treasury pool, which is used to hold all the funds
    struct Pool<phantom CoinType> has key, store {
        id: UID,
        balance: Balance<CoinType>, // BTC. ETH
        treasury_balance: Balance<CoinType>,
        decimal: u8,
    }

    struct PoolAdminCap has key, store {
        id: UID,
        creator: address,
    }

    // Event
    struct PoolCreate has copy, drop {
        creator: address,
    }

    struct PoolBalanceRegister has copy, drop {
        sender: address,
        amount: u64,
        new_amount: u64,
        pool: String,
    }

    struct PoolDeposit has copy, drop {
        sender: address,
        amount: u64,
        pool: String,
    }

    struct PoolWithdraw has copy, drop {
        sender: address,
        recipient: address,
        amount: u64,
        pool: String,
    }

    struct PoolWithdrawReserve has copy, drop {
        sender: address,
        recipient: address,
        amount: u64,
        before: u64,
        after: u64,
        pool: String,
        poolId: address,
    }

    // === dynamic field keys ===
    struct PoolManagerKey has copy, drop, store {}

    struct MarketIdKey has copy, drop, store {}

    // only current main market needs to be initialized
    // other markets will be initialized when creating reserves
    native public fun init_pool_for_main_market<CoinType>(_: &PoolAdminCap, pool: &mut Pool<CoinType>);

    native public fun withdraw_treasury<CoinType>(_cap: &mut PoolAdminCap, pool: &mut Pool<CoinType>, amount: u64, recipient: address, ctx: &mut TxContext);

    /// Get coin decimal
    native public fun get_coin_decimal<CoinType>(pool: &Pool<CoinType>): u8;

    /// Convert amount from current decimal to target decimal
    native public fun convert_amount(amount: u64, cur_decimal: u8, target_decimal: u8): u64;

    /// Normal coin amount in dola protocol
    native public fun normal_amount<CoinType>(pool: &Pool<CoinType>, amount: u64): u64;

    /// Unnormal coin amount in dola protocol
    native public fun unnormal_amount<CoinType>(pool: &Pool<CoinType>, amount: u64): u64;

    native public fun uid<T>(pool: &Pool<T>): &UID;

    // ------Pool Manager------
    native public fun init_sui_pool_manager(_: &PoolAdminCap, pool: &mut Pool<SUI>, stake_pool: StakePool, metadata: Metadata<CERT>, target_sui_amount: u64, ctx: &mut TxContext);

    native public fun enable_manage(_: &PoolAdminCap, pool: &mut Pool<SUI>);

    native public fun disable_manage(_: &PoolAdminCap, pool: &mut Pool<SUI>);

    native public fun refresh_stake(pool: &mut Pool<SUI>, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    native public fun withdraw_vsui_from_treasury(_: &PoolAdminCap, pool: &mut Pool<SUI>, recipient: address, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    native public fun set_target_sui_amount(_: &PoolAdminCap, pool: &mut Pool<SUI>, target_sui_amount: u64, system_state: &mut SuiSystemState, ctx: &mut TxContext);

    native public fun unstake_vsui(pool: &mut Pool<SUI>, system_state: &mut SuiSystemState, vsui_coin: Coin<CERT>, ctx: &mut TxContext): Coin<SUI>;

    native public fun set_validator_weights_vsui(pool: &mut Pool<SUI>, system_state: &mut SuiSystemState, vsui_operator_cap: &OperatorCap, validator_weights: VecMap<address, u64>, ctx: &mut TxContext);

    native public fun direct_deposit_sui(_: &PoolAdminCap, pool: &mut Pool<SUI>, sui_coin: Coin<SUI>, ctx: &mut TxContext);

    native public fun get_treasury_sui_amount(pool: &Pool<SUI>): u64;

    native public fun get_market_id<CoinType>(pool: &Pool<CoinType>): u64;

}
