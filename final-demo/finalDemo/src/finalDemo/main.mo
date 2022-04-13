import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import T "types";

shared (msg) actor class Demo() {
  let TOMICROSECONDS = 1000000000;

  private stable var proposalsEntries: [(Text, T.Proposal)] = [];
  private var proposals = HashMap.HashMap<Text, T.Proposal>(1, Text.equal, Text.hash);
  stable var fans: List.List<Principal> = List.nil(); //粉丝
  stable var following: List.List<Principal> = List.nil(); //关注

  // user balance
  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
  private stable var balanceEntries: [(Principal, Nat)] = [];
  // tx record
  private var records = Buffer.Buffer<T.TxRecord>(10);
  private stable var recordArray: [T.TxRecord] = [];

  //订阅名单
  private stable var subscribers: List.List<T.Subscriber> = List.nil();
  //所有完成的投票
  private stable var voteMsgs: List.List<T.VoteMsg> = List.nil();

  public func subscribe(subscriber : T.Subscriber) {
    subscribers := List.push(subscriber, subscribers);
  };    

  //通过Candid UI来调用，部署时候和调用msg.caller不是同一个，所以临时替换
  // 代币相关的参数也可以放在构造函数中间
  let owner: Principal = Principal.fromText("2vxsx-fae");
  // let owner: Principal = installer.caller; 
  let name: Text = "ET-token";
  let symbol: Text = "test";
  let decimals: Nat8 = 2;
  let totalSupply : Nat = 50000;

  private stable let meta: T.MetaData = {
    name = name;
    symbol = symbol;
    decimals = decimals;
    totalSupply = totalSupply;
  };

  // genesis record
  balances.put(owner, totalSupply);
  private let genesis : T.TxRecord = {
      index = 0;
      from = Principal.fromText("aaaaa-aa");
      to = owner;
      amount = totalSupply;
      timestamp = Time.now();
      status = #Succeed;
  };
  records.add(genesis);


  private let genPro : T.ProposalExt = {
    id = "not found";
    proposer = Principal.fromText("aaaaa-aa");
    createTime = 0;
    startTime = 0;
    endTime = 0;
    supportVote = 0;
    againstVote = 0;
};

  public shared(msg) func createProposal(id: Text, start: Int, end: Int) { //多少秒后开始，结束
    let proposer = msg.caller;
    let proposal = _newProposal(id, proposer, start, end);
    proposals.put(id, proposal);
  };

  private func _newProposal(id: Text, proposer: Principal, start: Int, end: Int) : T.Proposal {
    let createTime = Time.now();
    let startTime = createTime + start * TOMICROSECONDS;
    let endTime = createTime + end * TOMICROSECONDS;
    {
      id = id;
      proposer = proposer;
      createTime = createTime;
      startTime = startTime;
      endTime = endTime;
      var supportVote = 0;
      var againstVote = 0;
    }
  };

  public shared(msg) func follow (p: Principal, id: Text, vote: T.VoteType): async T.VoteReceipt{
    let canister: T.Vote = actor(Principal.toText(p));
    var all: List.List<T.ProposalExt> = List.nil();
    if (not List.some(following, func (who: Principal ): Bool { who == p })) {
      following := List.push(p, following);
      //第一次follow的时候也订阅了频道
      await canister.subscribe({ 
          topic = "hash";
          callback = saveVoteLog; // 当对方publish的时候将所有已经执行完的投票结果保存到log中
        });
    };
      await canister.newFans(msg.caller);
      let res = await canister.vote(id, vote)
      /* 测试返回对方数据 */
      // let msgs = await canister.getAllProrosal();
      // for (msg in Iter.fromArray(msgs)) {
      //   all := List.push(msg, all);
      // };
      // List.toArray(all)

  };

  public query func watching() : async [Principal] {
    List.toArray(following); 
  };

  public query func allFans() : async [Principal] {
    List.toArray(fans); 
  };

  public query func allVoteMsgs() : async [T.VoteMsg] {
    List.toArray(voteMsgs); 
  };


  public func newFans(id: Principal): async() {
    if (not List.some(fans, func (who: Principal ): Bool { who==id })) {
      fans := List.push(id, fans);
    };
  };
  public query func getProposal(id: Text) : async T.ProposalExt {
      _getProposal(id);
  };

  private func _getProposal(id: Text) : T.ProposalExt {
      switch (proposals.get(id)) {
        case (null) {
          genPro //初始分配的情况
        };
        case (?bal) {
          transform(bal)
        };
      }
  };

  // Proposal用来处理和存储，需要展示的时候进行一次变形即可
    private func _getproposal(id: Text) : T.Proposal {
    switch (proposals.get(id)) {
      case (null) { // 如何处理option为空的情况？一种可以用Err包装，或者呢
        {
          id = "default prop";
          proposer = Principal.fromText("aaaaa-aa");
          createTime = 0;
          startTime = 0;
          endTime = 0;
          var supportVote = 0;
          var againstVote = 0;
        };
      };
      case (?val) {
        val;
      };
    };
  };

 
  // 将可变的proposal转换为不可变的返回值
  private func transform(p: T.Proposal) : T.ProposalExt {
    {
      id = p.id;
      proposer = p.proposer;
      createTime = p.createTime;
      startTime = p.startTime;
      endTime = p.endTime;
      supportVote = p.supportVote;
      againstVote = p.againstVote;
    }
  };

  // 将投票的id名称与投票者组合起来，成为唯一的变量。每个人只能对一个投票实例投票一次
  private var isVote = HashMap.HashMap<T.IdVote, Bool>(1, func (a : T.IdVote, b : T.IdVote) : Bool {
    Text.equal(a.0, b.0) and Principal.equal(a.1,b.1)
  }, func (k : T.IdVote){
    Text.hash(Text.concat(k.0, Principal.toText(k.1)))
  });

  private func supportInc(prop : T.Proposal, who : Principal) : T.ProposalExt {
    let balance = _getBalance(who);
      let ans = {  
        id = prop.id;
        proposer = prop.proposer;
        createTime = prop.createTime;
        startTime = prop.startTime;
        endTime = prop.endTime;
        var supportVote = prop.supportVote + balance;
        var againstVote = prop.againstVote;   
      };
      proposals.put(prop.id, ans);
      transform(ans);
  };

  private func againstInc(prop : T.Proposal, who : Principal) : T.ProposalExt {
    let balance = _getBalance(who);
        let ans = {  
          id = prop.id;
          proposer = prop.proposer;
          createTime = prop.createTime;
          startTime = prop.startTime;
          endTime = prop.endTime;
          var supportVote = prop.supportVote;
          var againstVote = prop.againstVote + balance;   
        };
        proposals.put(prop.id, ans);
        transform(ans);
      };  

  public shared(msg) func vote(id: Text, votetype: T.VoteType) : async T.VoteReceipt{
    // if (not List.some(fans, func (who: Principal ): Bool { who == msg.caller})) {
    //   return #Err(#VotePermissionDenied);
    // };
    var prop = _getproposal(id);
    if (prop.createTime == 0) {
        return #Err(#VoteNotExist);
    };
    if (prop.startTime >= Time.now()) {
      return #Err(#VoteNotBegin);
    };
    if (prop.endTime <= Time.now()) {
      return #Err(#VoteIsOver);
    };
    let iv = (id, msg.caller);
    let isvote = _getvote(iv);
    if (isvote == true) {
      return #Err(#VoteRepeat);
    };
    if (votetype == #Support) {
      #Ok(supportInc(prop, msg.caller));
    } else {
      #Ok(againstInc(prop, msg.caller));
    };
  };


  private func _getvote(idVote: T.IdVote) : Bool {
    switch (isVote.get(idVote)) {
      case (null) {
        isVote.put(idVote, true);
        false;
      };
      case (?val) {
        val;
      };
    };
  };

  // 模拟keeper方法，定期检查投票是否结束，结束后返回结果。并通过订阅机制发送给所有订阅者
  public func keeper(_id : Text) : async () {
    let prop = _getproposal(_id);
    assert(prop.endTime < Time.now());
    let receipt = await proposalResult(_id);
    switch(receipt) {
      case (#Ok(tmp)) {
          let msg : T.VoteMsg = {
            topic = "hash";
            id = _id;
            message = tmp;
        };
        publish(msg);
      };
      case _ {};
    };
  };

  public func publish(msg : T.VoteMsg) {
    let tmp = List.toArray(subscribers);
    for (subscriber in tmp.vals()) {
      if (subscriber.topic == msg.topic) {
        subscriber.callback(msg);
      };
    };
  };

  public func saveVoteLog(msg : T.VoteMsg) {
    voteMsgs := List.push(msg, voteMsgs);
  };


  public query func proposalResult(id : Text) : async T.VoteResultReceipt {
    var prop = _getproposal(id);
    if (prop.endTime >= Time.now()) {
      return #Err(#VoteNotOver);
    } else {
      let supportVote = prop.supportVote;
      let againstVote = prop.againstVote;
      if (prop.createTime == 0) {
        return #Err(#VoteNotExist);
      };
      if (supportVote == againstVote) {
        return #Err(#VoteDraw);
      };
      if (supportVote > againstVote) {
        return #Ok(#Approved);
      } else {
        return #Ok(#Rejected);
      }
    }
  };


  //查询合约中存在的所有的投票（此时此刻的状态）
  public query func getAllProrosal() : async [T.ProposalExt]{
    let vals = proposals.vals();
    let mappedIter = Iter.map(vals, func (x : T.Proposal) : T.ProposalExt {transform(x)});
    let arr = Iter.toArray(mappedIter);
    // debug_show(arr);
  };

  // transfer from msg.caller to `to`, with `amount`
  public shared(msg) func transfer(to: Principal, amount: Nat) : async T.TxRecord {
    let from = msg.caller;
    let balanceFrom = _getBalance(from);
    let status = if (balanceFrom < amount) {
      #Fail(#InsuffcientBalance)
    } else {
      let balanceTo = _getBalance(to);
      balances.put(from, balanceFrom - amount);
      balances.put(to, balanceTo + amount);
      #Succeed
    };
    let record = _newRecord(from, to, amount, status);
    records.add(record);
    return record;
  };

  public query func getBalance(who: Principal) : async Nat {
    _getBalance(who)
  };

  public query func getTxRecordSize() : async Nat {
    records.size()
  };

  public query func getTxRecord(index: Nat) : async ?T.TxRecord {
    records.getOpt(index)
  };

  public query func getMetaData() : async T.MetaData {
    meta
  };

  private func _getBalance(who: Principal) : Nat {
    switch (balances.get(who)) {
      case (null) {
        0
      };
      case (?bal) {
        bal
      };
    };
  };

  private func _newRecord(from: Principal, to: Principal, amount: Nat, status: T.Status) : T.TxRecord {
    {
      index = records.size();
      from = from;
      to = to;
      amount = amount;
      timestamp = Time.now();
      status = status;
    }
  };

    system func preupgrade() {
    proposalsEntries := Iter.toArray(proposals.entries());
    balanceEntries := Iter.toArray(balances.entries());
    recordArray := records.toArray();
  };

    system func postupgrade() {
    proposals := HashMap.fromIter<Text, T.Proposal>(proposalsEntries.vals(), 1, Text.equal, Text.hash);
    proposalsEntries := [];
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
    balanceEntries := [];

    records := Buffer.Buffer<T.TxRecord>(recordArray.size());
    for (record in recordArray.vals()) {
      records.add(record);
    };
    recordArray := [];
  };
};