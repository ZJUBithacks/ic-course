export const idlFactory = ({ IDL }) => {
  const VoteResult = IDL.Variant({
    'Approved' : IDL.Null,
    'Rejected' : IDL.Null,
  });
  const VoteMsg = IDL.Record({
    'id' : IDL.Text,
    'topic' : IDL.Text,
    'message' : VoteResult,
  });
  const VoteType = IDL.Variant({ 'Support' : IDL.Null, 'Against' : IDL.Null });
  const Time = IDL.Int;
  const ProposalExt = IDL.Record({
    'id' : IDL.Text,
    'startTime' : Time,
    'endTime' : Time,
    'createTime' : Time,
    'againstVote' : IDL.Nat,
    'proposer' : IDL.Principal,
    'supportVote' : IDL.Nat,
  });
  const VoteErr = IDL.Variant({
    'VotePermissionDenied' : IDL.Null,
    'VoteNotExist' : IDL.Null,
    'VoteNotBegin' : IDL.Null,
    'VoteRepeat' : IDL.Null,
    'VoteIsOver' : IDL.Null,
  });
  const VoteReceipt = IDL.Variant({ 'Ok' : ProposalExt, 'Err' : VoteErr });
  const MetaData = IDL.Record({
    'decimals' : IDL.Nat8,
    'name' : IDL.Text,
    'totalSupply' : IDL.Nat,
    'symbol' : IDL.Text,
  });
  const Status = IDL.Variant({
    'Fail' : IDL.Variant({ 'InsuffcientBalance' : IDL.Null }),
    'Succeed' : IDL.Null,
  });
  const TxRecord = IDL.Record({
    'to' : IDL.Principal,
    'status' : Status,
    'from' : IDL.Principal,
    'timestamp' : Time,
    'index' : IDL.Nat,
    'amount' : IDL.Nat,
  });
  const VoteResultErr = IDL.Variant({
    'VoteNotExist' : IDL.Null,
    'VoteNotOver' : IDL.Null,
    'VoteDraw' : IDL.Null,
  });
  const VoteResultReceipt = IDL.Variant({
    'Ok' : VoteResult,
    'Err' : VoteResultErr,
  });
  const Subscriber = IDL.Record({
    'topic' : IDL.Text,
    'callback' : IDL.Func([VoteMsg], [], ['oneway']),
  });
  const Demo = IDL.Service({
    'allFans' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'allVoteMsgs' : IDL.Func([], [IDL.Vec(VoteMsg)], ['query']),
    'createProposal' : IDL.Func([IDL.Text, IDL.Int, IDL.Int], [], ['oneway']),
    'follow' : IDL.Func([IDL.Principal, IDL.Text, VoteType], [VoteReceipt], []),
    'getAllProrosal' : IDL.Func([], [IDL.Vec(ProposalExt)], ['query']),
    'getBalance' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'getMetaData' : IDL.Func([], [MetaData], ['query']),
    'getProposal' : IDL.Func([IDL.Text], [ProposalExt], ['query']),
    'getTxRecord' : IDL.Func([IDL.Nat], [IDL.Opt(TxRecord)], ['query']),
    'getTxRecordSize' : IDL.Func([], [IDL.Nat], ['query']),
    'keeper' : IDL.Func([IDL.Text], [], []),
    'newFans' : IDL.Func([IDL.Principal], [], []),
    'proposalResult' : IDL.Func([IDL.Text], [VoteResultReceipt], ['query']),
    'publish' : IDL.Func([VoteMsg], [], ['oneway']),
    'saveVoteLog' : IDL.Func([VoteMsg], [], ['oneway']),
    'subscribe' : IDL.Func([Subscriber], [], ['oneway']),
    'transfer' : IDL.Func([IDL.Principal, IDL.Nat], [TxRecord], []),
    'vote' : IDL.Func([IDL.Text, VoteType], [VoteReceipt], []),
    'watching' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
  });
  return Demo;
};
export const init = ({ IDL }) => { return []; };
