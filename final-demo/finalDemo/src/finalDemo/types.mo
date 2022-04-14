import Time "mo:base/Time";

module {
    public type Vote = actor {
        getAllProrosal: shared query() -> async [ProposalExt];
        proposalResult: shared query(Text) -> async VoteResultReceipt;
        vote: shared(Text, VoteType) -> async VoteReceipt;
        createProposal: shared (Text, Int, Int) -> async ();
        getProposal: shared query(Text) -> async ProposalExt;
        follow: shared (Principal, Text, VoteType) -> async VoteReceipt;
        newFans: shared (Principal) -> async ();
        subscribe: shared (Subscriber) -> async ();
  };

    public type Token = actor {
        transfer: shared(Principal, Nat)  -> async TxRecord;
        getBalance: shared(Principal) -> async Nat;
        getTxRecord: shared(Nat) -> async ?TxRecord;
        getMetaData: shared query() -> async MetaData;
  };
  
    public type IdVote = (Text, Principal);

    public type Proposal = {
        id: Text;
        proposer: Principal;
        createTime: Time.Time;
        startTime: Time.Time;
        endTime: Time.Time;
        var supportVote: Nat;
        var againstVote: Nat;
    };
    public type ProposalExt = {
        id: Text;
        proposer: Principal;
        createTime: Time.Time;
        startTime: Time.Time;
        endTime: Time.Time;
        supportVote: Nat;
        againstVote: Nat;
    };
    public type TxRecord = {
        index: Nat;
        from: Principal;
        to: Principal;
        amount: Nat;
        timestamp: Time.Time;
        status: Status;
    };

    public type MetaData = {
        name : Text;
        symbol : Text;
        decimals : Nat8;
        totalSupply : Nat;
    };

    // 订阅发布模式，当自动执行器keeper根据响应时候调用时。合约向所有订阅者发送投票结果消息
    public type VoteMsg = {
        topic : Text;
        id  : Text; // 投票名称
        message : VoteResult; //发送是否接受
    };

    public type Subscriber = {
        topic : Text;
        callback : shared VoteMsg -> ();
    };

    public type VoteType = {
        #Support;
        #Against;
    };
    public type VoteErr = {
        #VoteNotBegin;
        #VoteIsOver;
        #VoteRepeat;
        #VotePermissionDenied;
        #VoteNotExist;
    };

    public type VoteReceipt = {
        #Ok: ProposalExt;
        #Err: VoteErr;
    };
    public type VoteResult = {
        #Approved;
        #Rejected;
    };
    public type VoteResultErr = {
        #VoteNotOver;
        #VoteDraw;
        #VoteNotExist;
    };

    public type VoteResultReceipt = {
        #Ok: VoteResult;
        #Err: VoteResultErr;
    };
    public type Status = {
        #Succeed;
        #Fail: {
        #InsuffcientBalance;
        };
    };
}