import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";

import Type "Types";

actor class Homework() {
  type Homework = Type.Homework;
  let homeworkDiary = Buffer.Buffer<Homework>(0);

  public shared func addHomework(homework : Homework) : async Nat {
    let id = homeworkDiary.size();
    homeworkDiary.add(homework);
    return id;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id < homeworkDiary.size()) {
      return #ok(homeworkDiary.get(id));
    };
    return #err("Homework not found");
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size()) {
      homeworkDiary.put(id, homework);
      return #ok(());
    };
    return #err("Homework not found");
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size()) {
      let homework = homeworkDiary.get(id);
      let newHomework = {
        title = homework.title;
        description = homework.description;
        dueDate = homework.dueDate;
        completed = true;
      };
      homeworkDiary.put(id, newHomework);
      return #ok(());
    };
    return #err("Homework not found");
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size()) {
      let del = homeworkDiary.remove(id);
      return #ok();
    };
    return #err("Homework not found");
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    let array = Buffer.toArray<Homework>(homeworkDiary);
    return array;
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let array = Buffer.toArray<Homework>(homeworkDiary);
    let pending = Array.filter<Homework>(
      array,
      func(obj) { not obj.completed },
    );
    return pending;

  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let array = Buffer.toArray<Homework>(homeworkDiary);
    let search = Array.filter<Homework>(
      array,
      func(obj) { obj.title == searchTerm or obj.description == searchTerm },
    );
    return search;

  };
};
