module lending_core::manage {

    use sui::object::{UID};
    use sui::clock::{Clock};
    use sui::coin::{Coin};
    use sui::tx_context::{TxContext};
    use lending_core::pool::{Self, Pool};
    use lending_core::storage::{Self, Storage};
    use lending_core::storage::{StorageAdminCap, OwnerCap as StorageOwnerCap};
    use lending_core::flash_loan::{Config as FlashLoanConfig};
    use lending_core::incentive_v2::{OwnerCap as IncentiveOwnerCap};
    use lending_core::incentive_v3::{Incentive as IncentiveV3, RewardFund};
    use lending_core::storage::EmodeAsset;

    struct BorrowFeeCap has key, store {
        id: UID,
    }

    #[allow(unused_variable)]
    native public fun create_flash_loan_config(_: &StorageAdminCap, ctx: &mut TxContext);

    native public fun create_flash_loan_config_with_storage(_: &StorageAdminCap, storage: &Storage, ctx: &mut TxContext);

    native public fun create_flash_loan_asset<T>(_: &StorageAdminCap, config: &mut FlashLoanConfig, storage: &Storage, pool: &Pool<T>, asset_id: u8, rate_to_supplier: u64, rate_to_treasury: u64, maximum: u64, minimum: u64, ctx: &mut TxContext);

    native public fun set_flash_loan_asset_rate_to_supplier<T>(_: &StorageAdminCap, config: &mut FlashLoanConfig, _value: u64);

    native public fun set_flash_loan_asset_rate_to_treasury<T>(_: &StorageAdminCap, config: &mut FlashLoanConfig, _value: u64);

    native public fun set_flash_loan_asset_min<T>(_: &StorageAdminCap, config: &mut FlashLoanConfig, _value: u64);

    native public fun set_flash_loan_asset_max<T>(_: &StorageAdminCap, config: &mut FlashLoanConfig, _value: u64);

    // Incentive V3
    native public fun withdraw_borrow_fee<T>(_: &StorageAdminCap, incentive: &mut IncentiveV3, amount: u64, recipient: address, ctx: &mut TxContext);

    native public fun incentive_v3_version_migrate(_: &StorageAdminCap, incentive: &mut IncentiveV3);

    native public fun create_incentive_v3_reward_fund<T>(_: &IncentiveOwnerCap, ctx: &mut TxContext);

    native public fun create_incentive_v3_reward_fund_with_storage<T>(_: &IncentiveOwnerCap, storage: &Storage, ctx: &mut TxContext);

    #[allow(lint(self_transfer))]
    native public fun deposit_incentive_v3_reward_fund<T>(_: &IncentiveOwnerCap, reward_fund: &mut RewardFund<T>, deposit_coin: Coin<T>, amount: u64, ctx: &mut TxContext);

    native public fun withdraw_incentive_v3_reward_fund<T>(_: &StorageAdminCap, reward_fund: &mut RewardFund<T>, amount: u64, recipient: address, ctx: &mut TxContext);

    native public fun create_incentive_v3(_: &IncentiveOwnerCap, ctx: &mut TxContext);

    native public fun create_incentive_v3_with_storage(_: &IncentiveOwnerCap, storage: &Storage, ctx: &mut TxContext);

    native public fun create_incentive_v3_pool<T>(_: &IncentiveOwnerCap, incentive: &mut IncentiveV3, storage: &Storage, asset_id: u8, ctx: &mut TxContext);

    native public fun create_incentive_v3_rule<T, RewardCoinType>(_: &IncentiveOwnerCap, clock: &Clock, incentive: &mut IncentiveV3, option: u8, ctx: &mut TxContext);

    native public fun enable_incentive_v3_by_rule_id<T>(_: &IncentiveOwnerCap, incentive: &mut IncentiveV3, rule_id: address, ctx: &mut TxContext);

    native public fun disable_incentive_v3_by_rule_id<T>(_: &IncentiveOwnerCap, incentive: &mut IncentiveV3, rule_id: address, ctx: &mut TxContext);

    native public fun set_incentive_v3_reward_rate_by_rule_id<T>(_: &IncentiveOwnerCap, clock: &Clock, incentive: &mut IncentiveV3, storage: &mut Storage, rule_id: address, total_supply: u64, duration_ms: u64, ctx: &mut TxContext);

    native public fun set_incentive_v3_max_reward_rate_by_rule_id<T>(_: &IncentiveOwnerCap, incentive: &mut IncentiveV3, rule_id: address, max_total_supply: u64, duration_ms: u64);

    native public fun set_incentive_v3_borrow_fee_rate(_: &StorageAdminCap, incentive: &mut IncentiveV3, rate: u64, ctx: &mut TxContext);

    // init
    native public fun init_fields_batch(_: &StorageOwnerCap, storage: &mut Storage, incentive: &mut IncentiveV3, ctx: &mut TxContext);

    native public fun mint_borrow_fee_cap(_: &StorageAdminCap, recipient: address, ctx: &mut TxContext);

    native public fun set_borrow_fee_rate(_: &BorrowFeeCap, incentive: &mut IncentiveV3, rate: u64, ctx: &mut TxContext);

    native public fun set_asset_borrow_fee_rate(_: &BorrowFeeCap, incentive: &mut IncentiveV3, asset_id: u8, rate: u64, ctx: &mut TxContext);

    native public fun set_user_borrow_fee_rate(_: &BorrowFeeCap, incentive: &mut IncentiveV3, user: address, asset_id: u8, rate: u64, ctx: &mut TxContext);

    native public fun remove_incentive_v3_asset_borrow_fee_rate(_: &BorrowFeeCap, incentive: &mut IncentiveV3, asset_id: u8, ctx: &mut TxContext);

    native public fun remove_incentive_v3_user_borrow_fee_rate(_: &BorrowFeeCap, incentive: &mut IncentiveV3, user: address, asset_id: u8, ctx: &TxContext);

    native public fun set_designated_liquidators(_: &StorageOwnerCap, storage: &mut Storage, liquidator: address, user: address, is_designated: bool, ctx: &mut TxContext);

    native public fun set_protected_liquidation_users(_: &StorageOwnerCap, storage: &mut Storage, user: address, is_protected: bool);

    native public fun create_emode_asset(_: &StorageAdminCap, asset: u8, is_collateral: bool, is_debt: bool, ltv: u256, lt: u256, liquidation_bonus: u256): EmodeAsset;

    native public fun create_emode_pair(_: &StorageAdminCap, storage: &mut Storage, assetA: EmodeAsset, assetB: EmodeAsset);

    native public fun set_emode_config_active(_: &StorageAdminCap, storage: &mut Storage, emode_id: u64, is_active: bool);

    native public fun set_emode_asset_lt(_: &StorageAdminCap, storage: &mut Storage, emode_id: u64, asset: u8, lt: u256);

    native public fun set_emode_asset_ltv(_: &StorageAdminCap, storage: &mut Storage, emode_id: u64, asset: u8, ltv: u256);

    native public fun set_emode_asset_liquidation_bonus(_: &StorageAdminCap, storage: &mut Storage, emode_id: u64, asset: u8, liquidation_bonus: u256);

    native public fun create_new_market(_: &StorageAdminCap, main_storage: &mut Storage, ctx: &mut TxContext);

    native public fun set_borrow_weight(_: &StorageAdminCap, storage: &mut Storage, asset: u8, weight: u64);

    native public fun remove_borrow_weight(_: &StorageAdminCap, storage: &mut Storage, asset: u8);

}
