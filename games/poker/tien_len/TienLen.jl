module TienLen

export Suit, Card, Hand, ♣, ♢, ♡, ♠, .., deal, points

import Base: *, |, &

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
"""
julia> Char(0x2663)
'♣': Unicode U+2663 (category So: Symbol, other)

julia> Char(0x2662)
'♢': Unicode U+2662 (category So: Symbol, other)

julia> Char(0x2661)
'♡': Unicode U+2661 (category So: Symbol, other)

julia> Char(0x2660)
'♠': Unicode U+2660 (category So: Symbol, other)
"""
char(s::Suit) =
  if s.i == 0
    Char(0x2660)
  elseif s.i == 1
    Char(0x2663)
  elseif s.i == 2
    Char(0x2662)
  elseif s.i == 3
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
Encode a playing card as a 6-bit integer (low bits of a `UInt8`):

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
#    0 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
#    return Card(((i << 4) % UInt8) | (r % UInt8))
#end
function Card(r::Integer, i::Integer)
    0 ≤ r ≤ 15 || throw(ArgumentError("invalid card rank: $r"))
    return Card(((r << 2) % UInt8) | (i % UInt8))

    #1 ≤ r ≤ 13 || throw(ArgumentError("invalid card rank: $r"))
    #if r == 1
    #  r = 14
    #elseif r == 2
    #  r = 15
    #end
    #return Card(((i << 4) % UInt8) | (r % UInt8))
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
    if 1 ≤ r ≤ 14
        r == 10 && print(io, '1')
        print(io, "1234567890JQKA"[r])
    else
        print(io, '\U1f0cf')
    end
    print(io, suit(c))
end

*(r::Integer, s::Suit) = Card(r, s)

for s in "♣♢♡♠", (r,f) in zip(11:14, "JQKA")
    ss, sc = Symbol(s), Symbol("$f$s")
    @eval (export $sc; const $sc = Card($r,$ss))
end

#function Base.isless(card1::Card, card2::Card)
#  rank1 = rank(card1)
#  rank2 = rank(card2)
#  if rank1 == rank2
#    return suit(card1).i < suit(card2).i
#  else
#    return rank1 < rank2
#  end
#end
function Base.isless(card1::Card, card2::Card)
  card1.value < card2.value
end

"""
Represent a hand (set) of cards using a `UInt64` bit set.
"""
struct Hand <: AbstractSet{Card}
  cards::UInt64
  Hand(cards::UInt64) = new(cards)
end

bit(c::Card) = one(UInt64) << c.value
bits(s::Suit) = UInt64(0xffff) << 16(s.i)

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
Base.length(h::Hand) = count_ones(h.cards)
Base.isempty(h::Hand) = h.cards == 0
Base.lastindex(h::Hand) = length(h)

function Base.iterate(h::Hand, s::UInt8 = trailing_zeros(h.cards) % UInt8)
    (h.cards >>> s) == 0 && return nothing
    c = Card(s); s += true
    c, s + trailing_zeros(h.cards >>> s) % UInt8
end

function Base.unsafe_getindex(h::Hand, i::UInt8)
    card, s = 0x0, 0x5
    while true
        mask = 0xffff_ffff_ffff_ffff >> (0x40 - (0x1<<s) - card)
        card += UInt8(i > count_ones(h.cards & mask) % UInt8) << s
        s > 0 || break
        s -= 0x1
    end
    return Card(card)
end
Base.unsafe_getindex(h::Hand, i::Integer) = Base.unsafe_getindex(h, i % UInt8)

function Base.getindex(h::Hand, i::Integer)
    @boundscheck 1 ≤ i ≤ length(h) || throw(BoundsError(h,i))
    return Base.unsafe_getindex(h, i)
end

function Base.show(io::IO, hand::Hand)
    if isempty(hand) || !get(io, :compact, false)
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
                elseif 1 ≤ r ≤ 14
                    print(io, "1234567890JQKA"[r])
                else
                    print(io, '\U1f0cf')
                end
            end
        end
    end
end

a::Hand | b::Hand = Hand(a.cards | b.cards)
a::Hand | c::Card = Hand(a.cards | bit(c))
c::Card | h::Hand = h | c

a::Hand & b::Hand = Hand(a.cards & b.cards)
h::Hand & s::Suit = Hand(h.cards & bits(s))
s::Suit & h::Hand = h & s

Base.intersect(s::Suit, h::Hand) = h & s
Base.intersect(h::Hand, s::Suit) = intersect(s::Suit, h::Hand) 

*(rr::OrdinalRange{<:Integer}, s::Suit) = Hand(Card(r,s) for r in rr)
..(r::Integer, c::Card) = (r:rank(c))*suit(c)
..(a::Card, b::Card) = suit(a) == suit(b) ? rank(a)..b :
    throw(ArgumentError("card ranges need matching suits: $a vs $b"))

const deck = Hand(Card(r,s) for s in suits for r = 2:14)

Base.empty(::Type{Hand}) = Hand(zero(UInt64))

@eval Base.rand(::Type{Hand}) = Hand($(deck.cards) & rand(UInt64))

function deal!(counts::Vector{<:Integer}, hands::AbstractArray{Hand}, offset::Int=0)
    for rank = 2:14, suit = 0:3
        while true
            hand = rand(1:4)
            if counts[hand] > 0
                counts[hand] -= 1
                hands[offset + hand] |= Card(rank, suit)
                break
            end
        end
    end
    return hands
end

deal() = deal!(fill(13, 4), fill(empty(Hand), 4))

function deal(n::Int)
    counts = fill(0x0, 4)
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

end # Cards
