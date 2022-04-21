import type { Principal } from '@dfinity/principal';
export interface LotteryInfo {
  'sum' : bigint,
  'startTime' : Time,
  'lotteryWinner' : string,
  'prize' : bigint,
  'range' : bigint,
}
export type Time = bigint;
export interface _SERVICE {
  'listLotteries' : () => Promise<Array<LotteryInfo>>,
  'listParticipants' : () => Promise<Array<Principal>>,
  'participate' : (arg_0: Principal) => Promise<undefined>,
  'postNewLottery' : (arg_0: bigint, arg_1: bigint, arg_2: bigint) => Promise<
      Time
    >,
  'runLottery' : (arg_0: bigint, arg_1: bigint) => Promise<Array<bigint>>,
}
