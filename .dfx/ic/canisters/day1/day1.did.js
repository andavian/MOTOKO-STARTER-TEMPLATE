export const idlFactory = ({ IDL }) => {
  const Calculator = IDL.Service({
    'add' : IDL.Func([IDL.Float64], [IDL.Float64], []),
    'div' : IDL.Func([IDL.Float64], [IDL.Float64], []),
    'floor' : IDL.Func([], [IDL.Int], []),
    'mul' : IDL.Func([IDL.Float64], [IDL.Float64], []),
    'power' : IDL.Func([IDL.Float64], [IDL.Float64], []),
    'reset' : IDL.Func([], [], []),
    'see' : IDL.Func([], [IDL.Float64], ['query']),
    'sqrt' : IDL.Func([], [IDL.Float64], ['query']),
    'sub' : IDL.Func([IDL.Float64], [IDL.Float64], []),
  });
  return Calculator;
};
export const init = ({ IDL }) => { return []; };
