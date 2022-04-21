import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Random "mo:base/Random";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Order "mo:base/Order";

actor {
  public type Todo = {
    id: Text;
    content: Text;
    priority: Nat;
    createTime: Time.Time;
  };

  // List存储数据结构
  private var todoList = HashMap.HashMap<Text, Todo>(1, Text.equal, Text.hash);
  private var completeList = HashMap.HashMap<Text, Todo>(1, Text.equal, Text.hash);

  // stable
  private stable var todoListEntries: [(Text, Todo)] = [];
  private stable var completeListEntries: [(Text, Todo)] = [];

  private func createTodo(content: Text, priority: Nat) : Todo {
    let now = Time.now();
    {
      id = Int.toText(now);
      content = content;
      priority = priority;
      createTime = now;
    }
  };

  // 添加事项
  public shared func addTodo(content: Text, priority: Nat): async (){
    let todo = createTodo(content, priority);
    todoList.put(todo.id, todo);
  };

  // 完成事项
  public shared func complete(id: Text): async () {
    switch(todoList.get(id)) {
      case (null) {};
      case (?todo) {
        completeList.put(id, todo);
        switch(todoList.remove(id)) {
          case (null) {};
          case (?todo) {};
        };
      };
    };
  };

  // 取消完成事项
  public shared func delComplete(id: Text): async () {
    switch(completeList.get(id)) {
      case (null) {};
      case (?todo) {
        todoList.put(id, todo);
        switch(completeList.remove(id)) {
          case (null) {};
          case (?todo) {};
        };
      };
    };
  };

  // 删除事项
  public shared func delete(id: Text): async () {
    switch(todoList.remove(id)) {
      case (null) {};
      case (?todo) {};
    };
    switch(completeList.remove(id)) {
      case (null) {};
      case (?todo) {};
    };
  };

  // 获取个人未完成事项
  public shared query func getTodoList(): async [Todo] {
    let vals = todoList.vals();
    let mappedIter = Iter.map(vals, func (todo : Todo) : Todo { todo });
    let arr = Iter.toArray(mappedIter);
  };

  private func cmp(todo1: Todo, todo2: Todo): Order.Order {
    if (Text.less(todo1.id, todo2.id)) {
      #less;
    } else {
      #greater;
    }
  };

  // 获取个人已完成事项
  public shared query func getCompleteList(): async [Todo] {
    let vals = completeList.vals();
    let mappedIter = Iter.map(vals, func (todo : Todo) : Todo { todo });
    let arr = Array.sort(Iter.toArray(mappedIter), cmp);
  };

  // 获取个人未完成事情列表数量
  public shared query func getTodoListSize(): async Nat {
    todoList.size();
  };

  // 获取个人已完成事情列表数量
  public shared query func getCompleteListSize(): async Nat {
    completeList.size();
  };


  // system methods
  system func preupgrade() {
    todoListEntries := Iter.toArray(todoList.entries());
    completeListEntries := Iter.toArray(completeList.entries());
  };

    // system methods
  system func postupgrade() {
    todoList := HashMap.fromIter<Text, Todo>(todoListEntries.vals(), 1, Text.equal, Text.hash);
    todoListEntries := [];

    completeList := HashMap.fromIter<Text, Todo>(completeListEntries.vals(), 1, Text.equal, Text.hash);
    completeListEntries := [];
  };
};
