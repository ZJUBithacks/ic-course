use candid::{candid_method, CandidType, Deserialize, Nat, Principal};
use ic_cdk_macros::*;
use std::collections::HashMap;
use std::cell::RefCell;
use std::default::Default;

#[derive(Deserialize, CandidType, Clone)]
struct Metadata {
    name: String,
    symbol: String,
    decimals: u8,
    total_supply: Nat,
    owner: Principal,
}

impl Default for Metadata {
    fn default() -> Self {
        Self {
            name: "".to_string(),
            symbol: "".to_string(),
            decimals: 0u8,
            total_supply: Nat::from(0),
            owner: Principal::anonymous(),
        }
    }
}

#[derive(Deserialize, CandidType, Clone)]
pub struct TxRecord {
    index: usize,
    from: Principal,
    to: Principal,
    amount: Nat,
    timestamp: u64,
    status: TxStatus,
}

#[derive(Deserialize, CandidType, PartialEq, Clone)]
pub enum TxStatus {
    Succeed,
    Fail(TxError),
}

#[derive(Deserialize, CandidType, PartialEq, Clone)]
pub enum TxError {
    InsufficientBalance,
}

#[derive(CandidType, Default, Deserialize, Clone)]
pub struct TxLog(Vec<TxRecord>);

type Balances = HashMap<Principal, Nat>;

thread_local! {
    static BALANCES: RefCell<HashMap<Principal, Nat>> = RefCell::new(HashMap::default());
    static META: RefCell<Metadata> = RefCell::new(Metadata::default());
    static TXLOG: RefCell<TxLog> = RefCell::new(TxLog::default());
}

#[init]
#[candid_method(init)]
fn init(owner: Principal, name: String, symbol: String, decimals: u8, total_supply: Nat,) {
    META.with(|s| {
        let mut meta = s.borrow_mut();
        meta.name = name;
        meta.symbol = symbol;
        meta.decimals = decimals;
        meta.total_supply = total_supply.clone();
        meta.owner = owner;
    });
    BALANCES.with(|b| {
        b.borrow_mut().insert(owner, total_supply.clone());
    });
    TXLOG.with(|t| {
        t.borrow_mut().0.push(_new_record(Principal::from_text("aaaaa-aa").unwrap(), owner, total_supply.clone(), TxStatus::Succeed));
    });
}

#[update]
#[candid_method(update)]
fn transfer(to: Principal, amount: Nat) -> TxRecord {
    let from = ic_cdk::api::caller();
    let balance_from = get_balance(from);
    let status = if balance_from < amount.clone() {
        TxStatus::Fail(TxError::InsufficientBalance)
    } else {
        let balance_to = get_balance(to);
        BALANCES.with(|b| {
            let mut b = b.borrow_mut();
            b.insert(from, balance_from - amount.clone());
            b.insert(to, balance_to + amount.clone());
        });
        TxStatus::Succeed
    };
    let record = _new_record(from, to, amount.clone(), status);
    TXLOG.with(|t| t.borrow_mut().0.push(record.clone()));
    record
}

#[query(name = "getBalance")]
#[candid_method(query, rename = "getBalance")]
fn get_balance(who: Principal) -> Nat {
    BALANCES.with(|b| {
        let b = b.borrow();
        match b.get(&who) {
            None => Nat::from(0),
            Some(bal) => bal.to_owned()
        }
    })
}

#[query(name = "getTxRecordSize")]
#[candid_method(query, rename = "getTxRecordSize")]
fn get_tx_record_size() -> Nat {
    TXLOG.with(|t| {
        Nat::from(t.borrow().0.len())
    })
}

#[query(name = "getTxRecord")]
#[candid_method(query, rename = "getTxRecord")]
fn get_tx_record(index: u64) -> Option<TxRecord> {
    TXLOG.with(|t| {
        t.borrow().0.get(index as usize).map(|x| x.to_owned())
    })
}

#[query(name = "getMetadata")]
#[candid_method(query, rename = "getMetadata")]
fn get_metadata() -> Metadata {
    META.with(|m| {
        m.borrow().to_owned()
    })
}

// needed to export candid on save
#[query(name = "__get_candid_interface_tmp_hack")]
fn export_candid() -> String {
    candid::export_service!();
    __export_service()
}

#[pre_upgrade]
fn pre_upgrade() {
  let meta = META.with(|s| s.borrow().clone());
  let balances = BALANCES.with(|b| b.borrow().clone());
  let tx_log = TXLOG.with(|t| t.borrow().clone());
  ic_cdk::storage::stable_save((meta, balances, tx_log)).unwrap();
}

#[post_upgrade]
fn post_upgrade() {
  let (metadata_stored, balances_stored, tx_log_stored): (
    Metadata,
    Balances,
    TxLog,
  ) = ic_cdk::storage::stable_restore().unwrap();
  META.with(|m| {
    let mut meta = m.borrow_mut();
    *meta = metadata_stored;
  });
  BALANCES.with(|b| {
    let mut balances = b.borrow_mut();
    *balances = balances_stored;
  });
  TXLOG.with(|t| {
    let mut tx_log = t.borrow_mut();
    *tx_log = tx_log_stored;
  });
}

fn _new_record(from: Principal, to: Principal, amount: Nat, status: TxStatus) -> TxRecord {
    TxRecord {
        index: TXLOG.with(|t| t.borrow().0.len()),
        from,
        to,
        timestamp: ic_cdk::api::time(),
        amount,
        status,
    }
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn save_candid() {
        use std::env;
        use std::fs::write;
        use std::path::PathBuf;

        let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
        write(dir.join("token.did"), export_candid()).expect("Write failed.");
    }
}