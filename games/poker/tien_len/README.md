

## A Few Tricks to Use `Cards.jl`
- Easy way to initialize/specify a hand: `hand1 = Hand([1♡, 2♡, 2♢, 2♣, 2♠])`
- Random hand `Hand(rand(UInt64))`: Random number of cards, random cards
  - `length(Hand(rand(UInt64)))`
- A hand of all 64 cards: `Hand(typemax(UInt64))` or `Hand(0xffff_ffff_ffff_ffff)`
- `TienLen.empty` How to use?
  - `hand_empty = TienLen.empty(Hand)`
  - `hand_4♠ = empty(Hand) | 4♠`
