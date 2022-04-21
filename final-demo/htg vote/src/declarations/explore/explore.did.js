export const idlFactory = ({ IDL }) => {
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
  const Result_1 = IDL.Variant({ 'ok' : ProposalExt, 'err' : IDL.Text });
  const VoteResult = IDL.Variant({
    'Error' : IDL.Text,
    'Approved' : IDL.Null,
    'Rejected' : IDL.Null,
  });
  const VoteType = IDL.Variant({ 'Support' : IDL.Null, 'Against' : IDL.Null });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  return IDL.Service({
    'createProposal' : IDL.Func([IDL.Text, IDL.Int, IDL.Int], [Result_1], []),
    'getProposal' : IDL.Func([IDL.Text], [ProposalExt], ['query']),
    'proposalResult' : IDL.Func([IDL.Text], [VoteResult], ['query']),
    'vote' : IDL.Func([IDL.Text, VoteType], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
