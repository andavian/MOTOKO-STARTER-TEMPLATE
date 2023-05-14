import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import IC "Ic";
import HTTP "Http";
import Type "Types";
import Calculator "Calculator";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  var studentProfileStore : HashMap.HashMap<Principal, StudentProfile> = HashMap.HashMap<Principal, StudentProfile>(5, Principal.equal, Principal.hash);

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let profileOption = ?studentProfileStore.get(caller);
    if (?profileOption != null) {
      return #err("Profile already exists");
    } else {
      studentProfileStore.put(caller, profile);
      return #ok(());
    };
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let profileOpt = studentProfileStore.get(p);
    switch (profileOpt) {
      case (?profile) {
        return #ok(profile);
      };
      case (null) {
        return #err("Profile not found");
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (?studentProfileStore.get(caller)) {
      case (null) {
        return #err("Profile not found");
      };
      case (?existingProfile) {
        studentProfileStore.put(caller, profile);
        return #ok(());
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    switch (?studentProfileStore.remove(caller)) {
      case (null) {
        return #err("Profile not found");
      };
      case (opt) {
        return #ok(());
      };
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let calculator = await Calculator.Calculator();

    // Escenario 1: Llamada a reset seguida de add(1) devuelve un valor incorrecto.
    let result1 = await calculator.reset();
    if (Int.notEqual(result1, 0)) {
      return #err(#UnexpectedValue "Reset failed");
    };

    let result2 = await calculator.add(1);
    if (Int.notEqual(result2, 2)) {
      return #err(#UnexpectedValue "Addition failed");
    };

    // Escenario 2: Llamadas a la calculadora que devuelven resultados esperados.
    let result3 = await calculator.reset();
    if (Int.notEqual(result3, 1)) {
      return #err(#UnexpectedValue "Reset failed");
    };

    let result4 = await calculator.add(2);
    if (Int.notEqual(result4, 2)) {
      return #err(#UnexpectedValue "Addition failed");
    };

    let result5 = await calculator.sub(1);
    if (Int.notEqual(result5, 1)) {
      return #err(#UnexpectedValue "Subtraction failed");
    };
    return #ok(());
  };

  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    return #err("not implemented");
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    return #err("not implemented");
  };
  // STEP 4 - END

  // STEP 5 - BEGIN
  public type HttpRequest = HTTP.HttpRequest;
  public type HttpResponse = HTTP.HttpResponse;

  // NOTE: Not possible to develop locally,
  // as Timer is not running on a local replica
  public func activateGraduation() : async () {
    return ();
  };

  public func deactivateGraduation() : async () {
    return ();
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {
    return ({
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("");
      streaming_strategy = null;
    });
  };
  // STEP 5 - END
};
