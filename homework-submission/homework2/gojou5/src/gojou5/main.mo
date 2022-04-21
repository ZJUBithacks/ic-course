import Time "mo:base/Time";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Array "mo:base/Array";
import TrieSet "mo:base/TrieSet";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";

actor VotingActor {
  type Response<T> = Result.Result<T, Text>;
  type VoteType = {
    #Support;
    #Against;
  };
  type Receipt = {
    proposalId: Nat;
    voter: Principal;
    voteType: VoteType;
    timestamp: Time.Time;
  };

  type Proposal = {
    id: Nat;
    proposer: Principal;
    createTime: Time.Time;
    content: Text;
    startTime: Time.Time;
    endTime: Time.Time;
    var supportVote: Nat;
    var againstVote: Nat;
    receipts: HashMap.HashMap<Principal, Receipt>;
  };
  type ProposalExt = {
    id: Nat;
    proposer: Principal;
    createTime: Time.Time;
    content: Text;
    startTime: Time.Time;
    endTime: Time.Time;
    supportVote: Nat;
    againstVote: Nat;
  };
  type ProposalUpgrade = {
    id: Nat;
    proposer: Principal;
    createTime: Time.Time;
    content: Text;
    startTime: Time.Time;
    endTime: Time.Time;
    supportVote: Nat;
    againstVote: Nat;
    receipts: [(Principal, Receipt)];
  };
  type VoteResult = {
    #Approved;
    #Rejected;
    #Draw;
  };
  private stable var proposal_upgrade: [ProposalUpgrade] = [];
  private var proposals = Buffer.Buffer<Proposal>(1);
  private func _newProposal(proposer: Principal, start: Time.Time, end: Time.Time, content: Text) : Proposal {
    {
      id = proposals.size();
      proposer = proposer;
      createTime = Time.now();
      content = content;
      startTime = start;
      endTime = end;
      var supportVote = 0;
      var againstVote = 0;
      receipts = HashMap.HashMap<Principal, Receipt>(1, Principal.equal, Principal.hash);
    }
  };
  private func _newReceipt(proposalId: Nat, voter: Principal, voteType: VoteType) : Receipt{
    {
      proposalId = proposalId;
      voter = voter;
      voteType = voteType;
      timestamp = Time.now();
    }
  };
  private func _toProposalExt(proposal: Proposal) : ProposalExt {
    {
      id = proposal.id;
      proposer = proposal.proposer;
      createTime = proposal.createTime;
      content = proposal.content;
      startTime = proposal.startTime;
      endTime = proposal.endTime;
      supportVote = proposal.supportVote;
      againstVote = proposal.againstVote;
    }
  };
  private func _toProposalUpgrade(proposal: Proposal) : ProposalUpgrade {
    {
      id = proposal.id;
      proposer = proposal.proposer;
      createTime = proposal.createTime;
      content = proposal.content;
      startTime = proposal.startTime;
      endTime = proposal.endTime;
      supportVote = proposal.supportVote;
      againstVote = proposal.againstVote;
      receipts = Iter.toArray(proposal.receipts.entries());
    }
  };
  private func _fromProposalUpgrade(proposal: ProposalUpgrade) : Proposal {
    {
      id = proposal.id;
      proposer = proposal.proposer;
      createTime = proposal.createTime;
      content = proposal.content;
      startTime = proposal.startTime;
      endTime = proposal.endTime;
      var supportVote = proposal.supportVote;
      var againstVote = proposal.againstVote;
      receipts = HashMap.fromIter<Principal, Receipt>(proposal.receipts.vals(), 1, Principal.equal, Principal.hash);
    }
  };

  public shared(msg) func createProposal(start: Time.Time, end: Time.Time, content: Text) : async Response<ProposalExt> {
    if (start >= end) {
      return #err("End time must bigger than start time");
    };
    if (start <= Time.now()) {
      return #err("Start time must bigger than now");
    };
    let p = _newProposal(msg.caller, start, end, content);
    proposals.add(p);
    #ok(_toProposalExt(p))
  };
  public query func getProposal(id: Nat) : async Response<ProposalExt> {
    if (id >= proposals.size()) {
      return #err("Proposal not exist");
    };
    #ok(_toProposalExt(proposals.get(id)))
  };

  public shared(msg) func vote(id: Nat, voteType: VoteType) :async Response<Receipt> {
    if (id >= proposals.size()) {
      return #err("Proposal not exist");
    };
    let now = Time.now();
    let voter = msg.caller;
    let proposal = proposals.get(id);
    if (now < proposal.startTime) {
      return #err("Vote not start");
    };
    if (now > proposal.endTime) {
      return #err("Vote has ended");
    };
    if (Option.isSome(proposal.receipts.get(voter))) {
      return #err("User has already vote for this proposal");
    };
    let receipt = _newReceipt(id, voter, voteType);
    proposal.receipts.put(voter, receipt);
    switch(voteType) {
      case (#Support) {
        proposal.supportVote += 1;
      };
      case (#Against) {
        proposal.againstVote += 1;
      };
    };
    #ok(receipt)
  };

  public query func proposalResult(id: Nat) : async Response<VoteResult> {
    if (id >= proposals.size()) {
      return #err("Proposal not exist");
    };
    let now = Time.now();
    let proposal = proposals.get(id);
    if (now < proposal.startTime) {
      return #err("Vote not start");
    };
    if (now < proposal.endTime) {
      return #err("Vote not end");
    };
    if (proposal.supportVote > proposal.againstVote) {
      #ok(#Approved)
    } else if (proposal.supportVote < proposal.againstVote) {
      #ok(#Rejected)
    } else {
      #ok(#Draw)
    };
  };

  public query func getReceipts(proposalId: Nat) : async Response<[(Principal, Receipt)]> {
    if (proposalId >= proposals.size()) {
      return #err("Proposal not exist");
    };
    let proposal = proposals.get(proposalId);
    #ok(Iter.toArray(proposal.receipts.entries()))
  };

  public query func getReceipt(proposalId: Nat, voter: Principal) : async Response<Receipt> {
    if (proposalId >= proposals.size()) {
      return #err("Proposal not exist");
    };
    let proposal = proposals.get(proposalId);
    switch (proposal.receipts.get(voter)) {
      case (null) {
        #err("Receipt not exist");
      };
      case (?r) {
        #ok(r)
      };
    };
  };

  system func preupgrade() {
    proposal_upgrade := Array.map<Proposal, ProposalUpgrade>(proposals.toArray(), _toProposalUpgrade);
  };

  system func postupgrade() {
    proposals := Buffer.Buffer<Proposal>(proposal_upgrade.size());
    for (p in proposal_upgrade.vals()) {
      proposals.add(_fromProposalUpgrade(p));
    };
    proposal_upgrade := [];
  };
};
