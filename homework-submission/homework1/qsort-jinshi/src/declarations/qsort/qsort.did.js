export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
    'qsort' : IDL.Func([IDL.Vec(IDL.Int)], [IDL.Vec(IDL.Int)], []),
    'qsort_print' : IDL.Func([IDL.Vec(IDL.Int)], [], ['oneway']),
  });
};
export const init = ({ IDL }) => { return []; };
