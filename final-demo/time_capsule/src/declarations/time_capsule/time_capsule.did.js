export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const CreateCapsuleArgs = IDL.Record({
    'to' : IDL.Opt(IDL.Principal),
    'unlockTime' : Time,
    'content' : IDL.Text,
  });
  const CreateCapsuleResponse = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : IDL.Text,
  });
  const CapsuleResponse = IDL.Record({
    'id' : IDL.Nat,
    'to' : IDL.Opt(IDL.Principal),
    'creator' : IDL.Principal,
    'unlockTime' : Time,
    'content' : IDL.Opt(IDL.Text),
    'sealedTime' : Time,
  });
  const GetCapsuleResponse = IDL.Variant({
    'ok' : CapsuleResponse,
    'err' : IDL.Text,
  });
  return IDL.Service({
    'createCapsule' : IDL.Func(
        [CreateCapsuleArgs],
        [CreateCapsuleResponse],
        [],
      ),
    'getAllCapsules' : IDL.Func([], [IDL.Vec(CapsuleResponse)], ['query']),
    'getCapsule' : IDL.Func([IDL.Nat], [GetCapsuleResponse], ['query']),
    'getUserCapsules' : IDL.Func([], [IDL.Vec(CapsuleResponse)], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
