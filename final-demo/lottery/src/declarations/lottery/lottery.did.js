export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const LotteryInfo = IDL.Record({
    'sum' : IDL.Nat,
    'startTime' : Time,
    'lotteryWinner' : IDL.Text,
    'prize' : IDL.Nat,
    'range' : IDL.Nat,
  });
  return IDL.Service({
    'listLotteries' : IDL.Func([], [IDL.Vec(LotteryInfo)], ['query']),
    'listParticipants' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'participate' : IDL.Func([IDL.Principal], [IDL.Principal], []),
    'postNewLottery' : IDL.Func([IDL.Nat, IDL.Nat, IDL.Nat], [Time], []),
    'runFullLottery' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'runLottery' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Vec(IDL.Nat)], []),
  });
};
export const init = ({ IDL }) => { return []; };
