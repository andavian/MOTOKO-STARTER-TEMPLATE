import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";

actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  // Declaración de la variable messageId
  var messageId : Nat = 0;

  // Creación del HashMap para almacenar los mensajes
  var wall : HashMap.HashMap<Nat, Message> = HashMap.HashMap<Nat, Message>(5, Nat.equal, Hash.hash);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    messageId += 1;
    let message : Message = { vote = 0; content = c; creator = caller };
    wall.put(messageId, message);
    return messageId;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let message = wall.get(messageId);

    switch (message) {
      case (?msg) {
        return #ok(msg);
      };
      case (_) {
        return #err("Invalid messageId");
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let message = wall.get(messageId);

    switch (message) {
      case (?msg) {
        if (msg.creator == caller) {
          let updatedMessage : Message = {
            vote = msg.vote;
            content = c;
            creator = msg.creator;
          };
          wall.put(messageId, updatedMessage);
          return #ok(());
        } else {
          return #err("Caller is not the creator of the message");
        };
      };
      case (_) {
        return #err("Invalid messageId");
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);

    switch (message) {
      case (?_) {
        wall.delete(messageId);
        return #ok(());
      };
      case (_) {
        return #err("Invalid messageId");
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);

    switch (message) {
      case (?msg) {
        let updatedMessage : Message = {
          vote = msg.vote + 1;
          content = msg.content;
          creator = msg.creator;
        };
        wall.put(messageId, updatedMessage);
        return #ok(());
        wall.put(messageId, msg);
        return #ok(());
      };
      case (_) {
        return #err("Invalid messageId");
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);

    switch (message) {
      case (?msg) {
        if (msg.vote > 0) {
          let updatedMessage : Message = {
            vote = msg.vote - 1;
            content = msg.content;
            creator = msg.creator;
          };
          wall.put(messageId, updatedMessage);
          return #ok(());
        } else {
          return #err("Vote count cannot be negative");
        };
      };
      case (_) {
        return #err("Invalid messageId");
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let buffer = Buffer.Buffer<Message>(0);
    for (message in wall.vals()) {
      buffer.add(message);
    };
    return Buffer.toArray<Message>(buffer);
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    let buffer = Buffer.Buffer<Message>(0);
    for (message in wall.vals()) {
      buffer.add(message);
    };
    let array = Buffer.toArray<Message>(buffer);
    let ranked = Array.filter<Message>(
      array,
      func(obj) { obj.vote != 0 },
    );

    return ranked;
  };
};
