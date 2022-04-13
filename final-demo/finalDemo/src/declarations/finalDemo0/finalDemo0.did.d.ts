import type { Principal } from '@dfinity/principal';
export interface Demo {
  'allFans' : () => Promise<Array<Principal>>,
  'allVoteMsgs' : () => Promise<Array<VoteMsg>>,
  'createProposal' : (arg_0: string, arg_1: bigint, arg_2: bigint) => Promise<
      undefined
    >,
  'follow' : (arg_0: Principal, arg_1: string, arg_2: VoteType) => Promise<
      VoteReceipt
    >,
  'getAllProrosal' : () => Promise<Array<ProposalExt>>,
  'getBalance' : (arg_0: Principal) => Promise<bigint>,
  'getMetaData' : () => Promise<MetaData>,
  'getProposal' : (arg_0: string) => Promise<ProposalExt>,
  'getTxRecord' : (arg_0: bigint) => Promise<[] | [TxRecord]>,
  'getTxRecordSize' : () => Promise<bigint>,
  'keeper' : (arg_0: string) => Promise<undefined>,
  'newFans' : (arg_0: Principal) => Promise<undefined>,
  'proposalResult' : (arg_0: string) => Promise<VoteResultReceipt>,
  'publish' : (arg_0: VoteMsg) => Promise<undefined>,
  'saveVoteLog' : (arg_0: VoteMsg) => Promise<undefined>,
  'subscribe' : (arg_0: Subscriber) => Promise<undefined>,
  'transfer' : (arg_0: Principal, arg_1: bigint) => Promise<TxRecord>,
  'vote' : (arg_0: string, arg_1: VoteType) => Promise<VoteReceipt>,
  'watching' : () => Promise<Array<Principal>>,
}
export interface MetaData {
  'decimals' : number,
  'name' : string,
  'totalSupply' : bigint,
  'symbol' : string,
}
export interface ProposalExt {
  'id' : string,
  'startTime' : Time,
  'endTime' : Time,
  'createTime' : Time,
  'againstVote' : bigint,
  'proposer' : Principal,
  'supportVote' : bigint,
}
export type Status = { 'Fail' : { 'InsuffcientBalance' : null } } |
  { 'Succeed' : null };
export interface Subscriber {
  'topic' : string,
  'callback' : [Principal, string],
}
export type Time = bigint;
export interface TxRecord {
  'to' : Principal,
  'status' : Status,
  'from' : Principal,
  'timestamp' : Time,
  'index' : bigint,
  'amount' : bigint,
}
export type VoteErr = { 'VotePermissionDenied' : null } |
  { 'VoteNotExist' : null } |
  { 'VoteNotBegin' : null } |
  { 'VoteRepeat' : null } |
  { 'VoteIsOver' : null };
export interface VoteMsg {
  'id' : string,
  'topic' : string,
  'message' : VoteResult,
}
export type VoteReceipt = { 'Ok' : ProposalExt } |
  { 'Err' : VoteErr };
export type VoteResult = { 'Approved' : null } |
  { 'Rejected' : null };
export type VoteResultErr = { 'VoteNotExist' : null } |
  { 'VoteNotOver' : null } |
  { 'VoteDraw' : null };
export type VoteResultReceipt = { 'Ok' : VoteResult } |
  { 'Err' : VoteResultErr };
export type VoteType = { 'Support' : null } |
  { 'Against' : null };
export interface _SERVICE extends Demo {}
