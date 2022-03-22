# 实现一个投票合约canister
- 创建提案
```
type Proposal = {
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    var supportVote: Nat;
    var againstVote: Nat;
};
type ProposalExt = {
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    supportVote: Nat;
    againstVote: Nat;
};
public shared(msg) func createProposal(...) {
    ...
};
public query getProposal(...) : async ProposalExt {
    ...
};
```
- 进行投票
  
  在[startTime, endTime]期间进行投票
```
type VoteType = {
    #Support;
    #Against;
};
public shared(msg) func vote(...) {
    ...
};
```
- 投票结果

  在投票结束后，根据投票数量计算结果
```
type VoteResult = {
    #Approved;
    #Rejected;
}
public query func proposalResult(...) : async VoteResult {
    ...
};
```

# 部署在主网
- [cycles领取](https://smartcontracts.org/docs/quickstart/cycles-faucet.html)
- 部署主网 `--network ic`