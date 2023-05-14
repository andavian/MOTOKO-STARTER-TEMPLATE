import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {

  public type Account = Account.Account;

  let ledger : TrieMap.TrieMap<Account.Account, Nat> = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);
  let bootcampActor = BootcampLocalActor;

  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var total : Nat = 0;
    for ((_, balance) in ledger.entries()) {
      total += balance;
    };
    return total;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    let maybeBalance = ledger.get(account);
    return switch (maybeBalance) {
      case (null) { 0 };
      case (?balance) { balance };
    };

  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    let senderBalance = await balanceOf(from);
    if (Nat.notEqual(senderBalance, amount)) {
      return #err("Saldo insuficiente");
    } else {
      let receiverBalance = await balanceOf(to);
      let newSenderBalance = Nat.sub(senderBalance, amount);
      let newReceiverBalance = Nat.add(receiverBalance, amount);
      ledger.put(from, newSenderBalance);
      ledger.put(to, newReceiverBalance);
      return #ok();
    };
  };

  let studentsBootcamp : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
  } = actor ("rww3b -zqaaa -aaaam -abioa -cai");

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    try {
      let students = await studentsBootcamp.getAllStudentsPrincipal();
      for (principal in students.vals()) {
        let account : Account = {
          owner = principal;
          subaccount = null;
        };
        let currentValue = Option.get(ledger.get(account), 0);
        let newValue = currentValue + 100;
        ledger.put(account, newValue);
      };
      return #ok();
    } catch (e) {
      return #err("Something when wrong when calling the bootcamp canister");
    };
  };
};
