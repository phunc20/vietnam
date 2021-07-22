module TienLen

export Suit, Card, Hand, ♣, ♢, ♡, ♠, .., deal, deal_, points, suit, 有四張, 有六對, 有順子, 有六對_, 有順子_, deck

import Base: *, |, &
using Random

"""
Encode a suit as a 2-bit value (low bits of a `UInt8`):

- 0 = ♠ (bích)
- 1 = ♣ (chuồn)
- 2 = ♢ (rô)
- 3 = ♡ (cơ)

The suits have global constant bindings: `♠`, `♣`, `♢`, `♡`.
"""
struct Suit
  i::UInt8
  Suit(j::Integer) = 0 ≤ j ≤ 3 ? new(j) :
    throw(ArgumentError("invalid suit number: $j"))
end

#char(s::Suit) = Char(0x2663-s.i)
char(s::Suit) =
  if s.i == 0
  # ♠
  Char(0x2660)
  elseif s.i == 1
  # ♣
  Char(0x2663)
  elseif s.i == 2
  # ♢
  Char(0x2662)
  elseif s.i == 3
  # ♡
  Char(0x2661)
  end
Base.string(s::Suit) = string(char(s))
Base.show(io::IO, s::Suit) = print(io, char(s))

const ♠ = Suit(0)
const ♣ = Suit(1)
const ♢ = Suit(2)
const ♡ = Suit(3)

#const suits = [♣, ♢, ♡, ♠]
const suits = [♠, ♣, ♢, ♡]

"""
Encode a playing card as a 6-bit integer (high bits of a `UInt8`):
I have changed the high/low-bit position because I want Cards to
have an easy to compare btw them.

- low bits represent rank from 0 to 15
- high bits represent suit (♣, ♢, ♡ or ♠)

Ranks are assigned as follows:

- numbered cards (2 to 10) have rank equal to their number
- jacks, queens and kings have ranks 11, 12 and 13
- there are low and high aces with ranks 1 and 14
- there are low and high jokers with ranks 0 and 15

This allows any of the standard orderings of cards ranks to be
achieved simply by choosing which aces or which jokers to use.
There are a total of 64 possible card values with this scheme,
represented by `UInt8` values `0x00` through `0x3f`.
"""
struct Card
  value::UInt8
end

#function Card(r::Integer, i::Integer)
#  0 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
#  return Card(((i << 4) % UInt8) | (r % UInt8))
#end
function Card(r::Integer, i::Integer)
  #0 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
  #return Card(((r << 2) % UInt8) | (i % UInt8))

  1 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
  if r == 1
    r = 14
  elseif r == 2
    r = 15
  end
  return Card(((r << 2) % UInt8) | (i % UInt8))
end
Card(r::Integer, s::Suit) = Card(r, s.i)

##suit(c::Card) = Suit((0x30 & c.value) >>> 4)
#suit(c::Card) = Suit(c.value >>> 4)
##rank(c::Card) = (c.value & 0x0f) % Int8
#rank(c::Card) = (c.value & 0x0f)


#suit(c::Card) = Suit(((c.value & 0x03)) % Int8)
suit(c::Card) = Suit(c.value & 0x03)
#suit(c::Card) = Suit(c.value & 0x04)
rank(c::Card) = c.value >>> 2

function Base.show(io::IO, c::Card)
  r = rank(c)
  if 1 ≤ r ≤ 15
    r == 10 && print(io, '1')
    print(io, "ab34567890JQKA2"[r])
  #else
    #print(io, '\U1f0cf')
    #print(io, 'B')
  end
  print(io, suit(c))
end

*(r::Integer, s::Suit) = Card(r, s)

for s in "♣♢♡♠", (r,f) in zip(11:14, "JQKA")
  ss, sc = Symbol(s), Symbol("$f$s")
  @eval (export $sc; const $sc = Card($r,$ss))
end
# Did you notice that we did not export cards like 2♢ or 7♡, but only JQKA?
# The trick Karpinski did here was the defintion above:
#   *(r::Integer, s::Suit) = Card(r, s)
# 7♡ will be understood by Julia as 7 times ♡, so he just defines what that means.


#function Base.isless(card1::Card, card2::Card)
#  rank1 = rank(card1)
#  rank2 = rank(card2)
#  if rank1 == rank2
#  return suit(card1).i < suit(card2).i
#  else
#  return rank1 < rank2
#  end
#end
function Base.isless(card1::Card, card2::Card)
  card1.value < card2.value
end

## In order to do: bar(xtick=Card's)
#function Base.isless(x::Float64, card::Card)
#  x < card.value
#end
#function Base.isless(card::Card, x::Float64)
#  card.value < x
#end
#function Base.Float64(card::Card)
#  Float64(card.value)
#end

"""
Represent a hand (set) of cards using a `UInt64` bit set.

There are 4 suits and 16 ranks, so UInt64 should be enough
to represent all cards.

註釋.
以下的 code 可能最好前後前後反覆索引, 不然不容易讀懂,
因爲前面的 code 時常會用到後面定義的東西.

大致的概念是作者打算節省訊息量, 只把手牌存在一個 UInt64
裏, 然後作者重新特製定義了如何 loop 過一副手牌, 這些都得
要寫 code 來 customize.
"""
struct Hand <: AbstractSet{Card}
  cards::UInt64
  Hand(cards::UInt64) = new(cards)
end

bit(c::Card) = one(UInt64) << c.value
# Note.
#   one(UInt64) equals 0x0000_0000_0000_0001
#   c.value is in [0, 2⁶-1]
#   The return value's binary repr is always all 0's with only one 1

#bits(s::Suit) = UInt64(0xffff) << 16(s.i)
# Note.
#   16(k) in Julia simply equals 16*k. 16k is the same.
#   相當於十六個 1 每次往左移動十六格, 或十六的倍數格
#   這是原本 Karpinski 的設計. 我們改動了 rank 和 suit 的順序:
#   spades   = 2⁰ (1 + 2⁴ + 2⁸ + ... + 2⁶⁰)
#   clubs    = 2¹ (1 + 2⁴ + 2⁸ + ... + 2⁶⁰)
#   diamonds = 2² (1 + 2⁴ + 2⁸ + ... + 2⁶⁰)
#   hearts   = 2³ (1 + 2⁴ + 2⁸ + ... + 2⁶⁰)
const geometric_16 = ((UInt128(2)^(64) - 1) ÷ 15) % UInt64
bits(s::Suit) = geometric_16 * 2^(s.i)

# We build a similar method for the rank
bitr(r::Integer) = begin
  1 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
  if r == 1
    r = 14
  elseif r == 2
    r = 15
  end
  return UInt64(0b1111) << (4*r)
end

# From the next function, we can see that Karpinski's original design logic was
# each bit is like a flag for each card, 1 => exists, 0 => not exist
# So that Hand(0xffff_ffff_ffff_ffff) has all 64 cards in one hand, and Hand(UInt64(0)) has no card
function Hand(cards)
  hand = Hand(zero(UInt64))
  for card in cards
    card isa Card || throw(ArgumentError("not a card: $repr(card)"))
    i = bit(card)
    hand.cards & i == 0 || throw(ArgumentError("duplicate cards are not supported"))
    hand = Hand(hand.cards | i)
  end
  return hand
end

Base.in(c::Card, h::Hand) = (bit(c) & h.cards) != 0
#Base.in(r::UInt8, h::Hand) = any([in(Card(r, s), h) for s in suits])
Base.in(r::Integer, h::Hand) = any([in(Card(r, s), h) for s in suits])

Base.length(h::Hand) = count_ones(h.cards)
Base.isempty(h::Hand) = h.cards == 0
Base.lastindex(h::Hand) = length(h)

# https://docs.julialang.org/en/v1/manual/interfaces/
# Julia's Base.iterate is somewhat analogous to Python's generator
function Base.iterate(h::Hand, s::UInt8 = trailing_zeros(h.cards) % UInt8)
  # by def, s in [0, 64]. Indeed,
  # trailing_zeros(typemax(UInt64)) equals 0
  # trailing_zeros(zero(UInt64)) equals 64
  (h.cards >>> s) == 0 && return nothing
  c = Card(s); s += true
  # s += 1 converts s to Int64
  # s += true has the same value as s += 1 but stay in UInt8
  c, s + trailing_zeros(h.cards >>> s) % UInt8
end

function Base.unsafe_getindex(h::Hand, i::UInt8)
  # initialize
  value, s = 0x0, 0x5  # of type UInt8
  # We see that the next loop always runs 5 times, where 5 equals s
  while true
    mask = 0xffff_ffff_ffff_ffff >> (0x40 - (0x1<<s) - value)
    value += UInt8(i > count_ones(h.cards & mask) % UInt8) << s
    s > 0 || break
    s -= 0x1
  end
  return Card(value)
end
Base.unsafe_getindex(h::Hand, i::Integer) = Base.unsafe_getindex(h, i % UInt8)

function Base.getindex(h::Hand, i::Integer)
  # https://docs.julialang.org/en/v1/devdocs/boundscheck/
  @boundscheck 1 ≤ i ≤ length(h) || throw(BoundsError(h,i))
  return Base.unsafe_getindex(h, i)
end

function Base.show(io::IO, hand::Hand)
  if isempty(hand) || !get(io, :compact, false)
    # (?) Why empty hand we still loop thru and print?
    print(io, "Hand([")
    for card in hand
      print(io, card)
      (bit(card) << 1) ≤ hand.cards && print(io, ", ")
    end
    print(io, "])")
  else
    for suit in suits
      s = hand & suit
      isempty(s) && continue
      show(io, suit)
      for card in s
        r = rank(card)
        if r == 10
          print(io, '\u2491')
        elseif 1 ≤ r ≤ 15
          print(io, "1234567890JQKA2"[r])
        else
          print(io, '\U1f0cf')
        end
      end
    end
  end
end

# | infix operator is like adding two hands, or btw one card to a hand
# or, to put it more simply, it's the **union** (of two hands) or (of one hand and a suit)
a::Hand | b::Hand = Hand(a.cards | b.cards)
a::Hand | c::Card = Hand(a.cards | bit(c))
c::Card | h::Hand = h | c

# & infix operator is like restricting to common cards btw two hands, or btw one hand and a suit
# or, to put it more simply, it's the **intersection** (of two hands) or (of one hand and a suit)
a::Hand & b::Hand = Hand(a.cards & b.cards)
h::Hand & s::Suit = Hand(h.cards & bits(s))
s::Suit & h::Hand = h & s
h::Hand & r::Integer = Hand(h.cards & bitr(r))
r::Integer & h::Hand = h & r

# Karpinski purposefully omitted the definition of intersection of hands,
# because no need to do so -- Hand's are sets, which already have a method for intersection.
Base.intersect(h::Hand, r::Integer) = h & r
Base.intersect(r::Integer, h::Hand) = r & h
Base.intersect(s::Suit, h::Hand) = h & s
Base.intersect(h::Hand, s::Suit) = intersect(s::Suit, h::Hand)

*(rr::OrdinalRange{<:Integer}, s::Suit) = Hand(Card(r,s) for r in rr)
..(r::Integer, c::Card) = (r:rank(c))*suit(c)
..(a::Card, b::Card) = suit(a) == suit(b) ? rank(a)..b :
  throw(ArgumentError("card ranges need matching suits: $a vs $b"))

#const deck = Hand(Card(r,s) for s in suits for r = 2:14)
const deck = Hand(Card(r,s) for s in suits for r = 1:13)

Base.empty(::Type{Hand}) = Hand(zero(UInt64))

@eval Base.rand(::Type{Hand}) = Hand($(deck.cards) & rand(UInt64))
# Note that we've altered Karpinski's original code, making uniform random on UInt64
# slightly unsuitable. We need a little adaptation.
#@eval Base.rand(::Type{Hand}) = Hand($(deck.cards) & rand((one(UInt64) << 12):typemax(UInt64)))
#@eval Base.rand(::Type{Hand}) = Hand(rand((one(UInt64) << 12):typemax(UInt64)))

function deal!(counts::Vector{<:Integer}, hands::AbstractArray{Hand}, offset::Int=0; karpinski::Bool=true)
  """
  args
    counts
      records the number of cards left to be distributed to each hand, e.g.
      fill(13, 4) means that there are 4 hands, each hand still waiting for another 13 cards to arrive.
    hands
      is an array of Hand's. This function is inplace
    offset
      allows to deal cards to a portion of the players, instead of to every player.
    karpinski
      If true, use Karpinski's original way of dealing cards; if false, use phunc20's way.
      Basically, karpinski's way is to deal the cards in the order of A♡, A♢, A♣, A♠, 2♡, 2♢, 2♣, 2♠, etc.
      while phunc20's way is to shuffle the cards and just distribute to players 1,2,3,4, periodically.

  return
    hands: Karpinski still have this method return hands because of the next-up method deal() defined in terms
           of the current method. Cf. below.
  """
  if karpinski
    #for suit = 0:3, rank = 1:13
    for rank = 1:13, suit = 0:3
      while true
        hand = rand(1:4)
        if counts[hand] > 0
          counts[hand] -= 1
          hands[offset + hand] |= Card(rank, suit)
          break
        end
      end
    end
  else
    for ((rank, suit), hand) in zip(shuffle(collect(Iterators.product(1:13, 0:3))), Iterators.cycle(1:4))
      hands[offset + hand] |= Card(rank, suit)
    end
  end
  return hands
end

deal_() = deal!(fill(13, 4), fill(empty(Hand), 4))
deal() = deal!(fill(13, 4), fill(empty(Hand), 4), karpinski=false)

function deal(n::Int)
  # counts equals a 4-element Array{UInt8,1} of 0x0's
  counts = fill(0x0, 4)
  # 4 x n Hands
  hands = fill(empty(Hand), 4, n)
  for i = 1:n
    deal!(fill!(counts, 13), hands, 4(i-1))
  end
  return permutedims(hands)
end

function points(hand::Hand)
  p = 0
  for rank = 11:14, suit = 0:3
    card = Card(rank, suit)
    p += (rank-10)*(card in hand)
  end
  return p
end

function 有四張(h::Hand, r::Integer=2)
  1 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
  return length(r ∩ h) == 4
end

function 有六對(h::Hand)
  n_pairs = 0
  for (j, r) in enumerate(shuffle(3:15))
    if length(r ∩ h) == 4
      n_pairs += 2
    elseif length(r ∩ h) >= 2
      n_pairs += 1
    end
    # To collect six pairs, we should at least loop thru three diff ranks
    if j >= 3 && n_pairs >= 6
      return true
    end
  end
  return false
end

## 2nd implementation for the same check as 有六對
function 有六對_(h::Hand)
  n_pairs = 0
  # Random.shuffle
  #for r in shuffle(3:15)
  for r in 3:15
    if length(r ∩ h) == 4
      n_pairs += 2
    elseif length(r ∩ h) >= 2
      n_pairs += 1
    end
    # To collect six pairs, we should at least loop thru three diff ranks
    if r >= 5 && n_pairs >= 6
      return true
    end
  end
  return false
end

function 有順子(h::Hand)
  for r in 3:15
    #r_4suits = Hand(UInt64(0b1111) << (4*r))
    r_4suits = UInt64(0b1111) << (4*r)
    # e.g. when r equals 3, r_4suits is the UInt64
    # containing all four 3♠♣♢♡
    if h.cards & r_4suits == 0
      return false
    end
  end
  return true
end

## 2nd implementation for the same check as 有順子
function 有順子_(h::Hand)
  ranks = Set()
  for card in h
    push!(ranks, rank(card))
  end
  return length(ranks) == 13
end

end # TienLen
