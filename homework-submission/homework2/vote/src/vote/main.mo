import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import ICRaw "mo:base/ExperimentalInternetComputer";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";


actor {
  // public func greet(name : Text) : async Text {
  //   return "Hello, " # name # "!";
  // };

  stable var next_proposal_id : Nat = 0;
  public type ResultArg<T, E> = Result.Result<T, E>;


  type Proposal = {
    id: Nat/Text;
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    var supportVote: Nat;
    var againstVote: Nat;
  };

  type ProposalExt = {
    id: Nat/Text;
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    supportVote: Nat;
    againstVote: Nat;
  };

  public type Tokens = { 
    amount_e8s : Nat 
  };
  func account_get(id : Principal) : ?Tokens = Trie.get(accounts, account_key(id), Principal.equal);
  func account_put(id : Principal, tokens : Tokens) {
    accounts := Trie.put(accounts, account_key(id), Principal.equal, tokens).0;
  };
  public func account_key(t: Principal) : Trie.Key<Principal> = {
    key = t;
    hash = Principal.hash t
  };
  func proposal_get(id : Nat) : ?Proposal = Trie.get(proposals, proposal_key(id), Nat.equal);
  func proposal_put(id : Nat, proposal : Proposal) {
    proposals := Trie.put(proposals, proposal_key(id), Nat.equal, proposal).0;
  };
  public func proposal_key(t: Nat) : Trie.Key<Nat> = { 
    key = t; 
    hash = Int.hash t 
  };

  public shared(msg) func createProposal() : async ResultArg<Nat, Text> {
    // Result.chain(deduct_proposal_submission_deposit(msg.caller), func (()) : ResultArg<Nat, Text> {
      let proposal_id = next_proposal_id;
      next_proposal_id += 1;
      let proposal : Proposal = {
        id = proposal_id;
        proposer = msg.caller;
        createTime = Time.now();
        startTime = null;
        endTime = null;
        supportVote = 0;
        againstVote = 0;
      };
      proposal_put(proposal_id, proposal);
      #ok(proposal_id)
    // })
  };

  public query getProposal(proposal_id: Nat) : async ProposalExt {
    proposal_get(proposal_id)
  };

  type VoteType = {
    #Support;
    #Against;
  };

  public type VoteArgs = { 
    vote : VoteType;
    proposal_id : Nat;
  };

  public shared(msg) func vote(args: VoteArgs) : async ResultArg<VoteResult, Text> {
    switch (proposal_get(args.proposal_id)) {
      case null { 
        #err("No proposal with ID " # debug_show(args.proposal_id) # " exists") 
      };
      case (?proposal) {
        var state;
        let proposalStartTime = Time.now();
        switch (account_get(msg.caller)) {
          case null { 
            return #err("Caller does not have any tokens to vote with")
          };
          case (?{ amount_e8s = voting_tokens }) {
            var supportVote = proposal.supportVote;
            var againstVote = proposal.againstVote;
            switch (args.vote) {
              case (#Support) { 
                supportVote += voting_tokens
              };
              case (#Against) { 
                againstVote += voting_tokens
              };
            };

            if (supportVote >= againstVote) {
              state := #Approved;
            } else {
              state := #Rejected;
            };

            let updated_proposal = {
              id = proposal.id;
              proposer = proposal.proposer;
              createTime = proposal.timestamp;
              startTime = proposalStartTime;
              endTime = Time.now();
              supportVote = supportVote;                              
              againstVote = againstVote;
            };
            proposal_put(args.proposal_id, updated_proposal);
          };
        };
        #ok(state)
      };
    };
  };

  type VoteResult = {
    #Approved;
    #Rejected;
  };

  public query func proposalResult() : async VoteResult {
    Iter.toArray(Iter.map(Trie.iter(proposals), func (kv : (Nat, Proposal)) : Proposal = kv.1))
  };

};
