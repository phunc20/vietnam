

## A Few Tricks to Use `Cards.jl`
- `Hand(rand(UInt64))`
  - `length(Hand(rand(UInt64)))`
- `Hand(typemax(UInt64))` or `Hand(0xffff_ffff_ffff_ffff)`
- `TienLen.empty` How to use?
  - `hand_empty = TienLen.empty(Hand)`
  - `hand_4♠ = empty(Hand) | 4♠`
