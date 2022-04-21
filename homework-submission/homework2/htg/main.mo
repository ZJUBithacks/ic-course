import Map "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

actor Vote{
  type Proposal = {
    id: Text;
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    var supportVote: Nat;
    var againstVote: Nat;
  };
  type ProposalExt = {
    id: Text;
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    supportVote: Nat;
    againstVote: Nat;
  };

  type VoteType = {
    #Support;
    #Against;
  };

  type VoteResult = {
    #Approved;
    #Rejected;
    #Error: Text;
  };

  // Map<K, V>
  private var proposalMap = Map.HashMap<Text, Proposal>(1, Text.equal, Text.hash);
 
  // stable
  private stable var proposalsEntries: [(Text, Proposal)] = [];
  private stable var votesEntries: [(Text, Bool)] = [];

  // immutable
  private func toExt(proposal: Proposal) : ProposalExt {
    return {
      id = proposal.id;
      proposer = proposal.proposer;
      createTime = proposal.createTime;
      startTime = proposal.startTime;
      endTime = proposal.endTime;
      supportVote = proposal.supportVote;
      againstVote = proposal.againstVote;
    }
  };

  private func createHelper(proposalId: Text, proposer: Principal, startTime: Int, endTime: Int) : Proposal {
      let baseTime = 1000000000;
      let createTime = Time.now();
      {
        id = proposalId;
        proposer = proposer;
        createTime = createTime;
        startTime = createTime + startTime * baseTime;
        endTime = createTime + endTime * baseTime;
        var supportVote = 0;
        var againstVote = 0;
      }
  };

  public shared(msg) func createProposal(proposalId: Text, startTime: Int, endTime: Int) : async Result.Result<ProposalExt, Text> {
    if (startTime >= endTime or startTime < 0) {
      return #err("time invalid.");
    };

    switch(proposalMap.get(proposalId)) {
      case (null) {};
      case (?proposal) {
        return #err("vote exist.");
      };
    };

    let proposal = createHelper(proposalId, msg.caller, startTime, endTime);
    proposalMap.put(proposalId, proposal);

    #ok(toExt(proposal));
  };

  private func queryHelper(proposalId: Text) : Proposal {
    switch (proposalMap.get(proposalId)) {
      case (null) {
        {
          id = "placeholder";
          proposer = Principal.fromText("aaaaa-aa");
          createTime = 0;
          startTime = 0;
          endTime = 0;
          var supportVote = 0;
          var againstVote = 0;
        };
      };
      case (?proposal) {
        proposal;
      };
    };
  };

  // how to use option return type?
  public query func getProposal(proposalId: Text) : async ProposalExt {
      toExt(queryHelper(proposalId));
  };

  public shared(msg) func vote(proposalId: Text, voteType: VoteType) :async Result.Result<Text, Text> {
    var proposal = queryHelper(proposalId);

    if (proposal.startTime >= Time.now()) {
      return #err("vote has not started yet.");
    };
    if (proposal.endTime <= Time.now()) {
      return #err("vote has ended.");
    };

    switch(voteType) {
      case (#Support) {
        proposal.supportVote += 1;
      };
      case (#Against) {
        proposal.againstVote += 1;
      };
    };

    #ok("voted");
  };

  public query func proposalResult(proposalId : Text) : async VoteResult {
    var proposal = queryHelper(proposalId);

    if (proposal.id == "placeholder") {
      return #Error("proposal not found!");
    };
    if (proposal.endTime >= Time.now()) {
      return #Error("Vote ongoing");
    };

    if (proposal.supportVote >= proposal.againstVote) {
      return #Approved;
    } else {
      return #Rejected;
    };
  };
};


// test output log
/* 
› createProposal("test", 1, 20)
(variant {ok=record {id="test"; startTime=1649853223751009026; endTime=1649853242751009026; createTime=1649853222751009026; againstVote=0; proposer=principal "2vxsx-fae"; supportVote=0}})
› getProposal("test")
(record {id="test"; startTime=1649853223751009026; endTime=1649853242751009026; createTime=1649853222751009026; againstVote=0; proposer=principal "2vxsx-fae"; supportVote=0})
› proposalResult("test")
(variant {Error="Vote ongoing"})
› vote("test", variant {Against})
(variant {ok="voted"})
› vote("test", variant {Support})
(variant {err="vote has ended."})
› proposalResult("test")
(variant {Rejected})
*/
