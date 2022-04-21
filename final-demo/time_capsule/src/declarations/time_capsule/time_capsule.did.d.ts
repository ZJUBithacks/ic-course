import type { Principal } from '@dfinity/principal';
export interface CapsuleResponse {
  'id' : bigint,
  'to' : [] | [Principal],
  'creator' : Principal,
  'unlockTime' : Time,
  'content' : [] | [string],
  'sealedTime' : Time,
}
export interface CreateCapsuleArgs {
  'to' : [] | [Principal],
  'unlockTime' : Time,
  'content' : string,
}
export type CreateCapsuleResponse = { 'ok' : bigint } |
  { 'err' : string };
export type GetCapsuleResponse = { 'ok' : CapsuleResponse } |
  { 'err' : string };
export type Time = bigint;
export interface _SERVICE {
  'createCapsule' : (arg_0: CreateCapsuleArgs) => Promise<
      CreateCapsuleResponse
    >,
  'getAllCapsules' : () => Promise<Array<CapsuleResponse>>,
  'getCapsule' : (arg_0: bigint) => Promise<GetCapsuleResponse>,
  'getUserCapsules' : () => Promise<Array<CapsuleResponse>>,
}
