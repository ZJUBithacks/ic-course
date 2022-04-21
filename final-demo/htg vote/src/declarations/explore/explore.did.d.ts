import type { Principal } from '@dfinity/principal';
export interface ProposalExt {
  'id' : string,
  'startTime' : Time,
  'endTime' : Time,
  'createTime' : Time,
  'againstVote' : bigint,
  'proposer' : Principal,
  'supportVote' : bigint,
}
export type Result = { 'ok' : string } |
  { 'err' : string };
export type Result_1 = { 'ok' : ProposalExt } |
  { 'err' : string };
export type Time = bigint;
export type VoteResult = { 'Error' : string } |
  { 'Approved' : null } |
  { 'Rejected' : null };
export type VoteType = { 'Support' : null } |
  { 'Against' : null };
export interface _SERVICE {
  'createProposal' : (arg_0: string, arg_1: bigint, arg_2: bigint) => Promise<
      Result_1
    >,
  'getProposal' : (arg_0: string) => Promise<ProposalExt>,
  'proposalResult' : (arg_0: string) => Promise<VoteResult>,
  'vote' : (arg_0: string, arg_1: VoteType) => Promise<Result>,
}
