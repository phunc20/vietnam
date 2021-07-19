### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ bf67b80e-e3e6-11eb-203d-2965a14e546f
begin
  using Pkg
  # .julia_env/ is in the root dir of this repo
  Pkg.activate("../../../../.julia_env/oft")
  Pkg.add.(["Plots",
            "StatsBase",
            "DataStructures",
  ])
  using PlutoUI
  using Plots
  using StatsBase
  #using TikzPictures
  #using DataStructures: SortedDict
end

# ╔═╡ 81bab1d0-a08e-4809-966c-eff81c21e77b
begin
  pushfirst!(LOAD_PATH, ".")
  using TienLen
end

# ╔═╡ e2fe9812-e3e8-11eb-1c29-a76d35861730
md"""
# Tiến Lên
[Tiến lên](https://en.wikipedia.org/wiki/Ti%E1%BA%BFn_l%C3%AAn#Instant_wins_(vi:_t%E1%BB%9Bi_tr%E1%BA%AFng)) 是越南的撲克牌遊戲, 規則跟臺灣的 [大老二](https://en.wikipedia.org/wiki/Big_two) 大致相似.

不過, 越南坊間有各式各樣不盡相同的小規則, 就連最一般的規則還是跟臺灣習慣的有所出入,
所以對於初來乍到的臺灣人, 如果不仔細弄清楚規則的話, 可能一開始還是會免不了連輸數局.

以下我們就對 tiến lên 做點介紹, 希望能讓讀者產生興趣.
"""

# ╔═╡ 3b4e05c2-e3ec-11eb-0505-8bd038210963
md"""
## 簡單的規則介紹
- 基本上, tiến lên 最少需要兩位玩家, 最多四位.
- 每人發 `13` 張牌, 不管玩家數目多少
- 花色的大小順序 (跟臺灣相當不同) 如下: `♡ > ♢ > ♣ > ♠`, 以越南語的叫法就是 `cơ > rô > chuồn > bích`
- 出牌的順序是由前一局的第一名開始出牌; 第一局的話, 則是由擁有 `3♠` (也就是最小的牌)的人最先出牌.
- 基本上, 前一個人出什麼樣式的牌, 你如果想出牌就得出一樣樣式但比他大的牌
  - 二到四張同數目 (`rank`) 的牌: 可以
  - 順子從三張到十三張: 可以
  - 比較大小通常只比數值最大的牌的大小和花色而已
- 終局第四名要付第一名 ``x`` 塊錢, 第三名要付第二名 ``\frac{x}{2}`` 塊錢. ``x`` 多少自己訂.
- 有個概念叫做 mất vòng, 意思是如果你跳過一次不出牌或是出不了任何牌, 那下一次輪到你時, 除非這一輪所有人都出不了蓋得過牌面上的那張牌, 你會直接被跳過, 被剝奪出牌的機會.
- 有下列這些比較特別的牌:
  - 三個連續的對 (ba đôi thông): 這個牌, 如果你的前一張牌是大老二, 輪到你出牌, 你可以把這六張牌一次出出去, 勝過大老二, 還可以額外多贏錢: 如果你殺的是黑色的老二, 則被你殺的玩家該局結束得多付你 ``\frac{x}{2}`` 塊錢; 紅色的老二的話, 則是 多付 ``x`` 塊錢
  - `三個連續的對 (ba đôi thông) < 四張一樣數字的牌 (tứ quý) < 四個連續的對 (bốn đôi thông)`` 這些都和前面說的一樣, 可以殺老二 (chặt heo). 它們的大小順序如上. 特別的是
    - `四張一樣數字的牌` 和 `四個連續的對` 還可以殺 一對老二
    - 他們之間可以互殺, 錢則是由最後被殺的人付, 每一次以最初的單位往上加一倍.
  - 這些特殊的牌在 mất vòng 的情形下還是可以出.


> **Fun Facts.**
>
> 越南撲克牌的命名乍看/聽之下蠻奇怪的, 但其實是受到法文的影響, 比如說
>
> - `cơ ≈ cœur`
> - `rô = ca-rô ≈ carreau`
> - `bích ≈ pique`

以下我們會做一些機率上的運算, 爲方便說明, 如果不特別明說, 都是假定四個玩家的情形作討論.
"""

# ╔═╡ ce6f4722-e3e8-11eb-0367-6d8491d5c7ab
md"""
## Tới Trắng
這是一手牌在你拿到的同時, 就決定你已經贏了這局, 連一張牌都不需要出.

在我所在的家庭裏, tới trắng 發生在以下這兩種手牌裏:

1. 四張 `2` 都落在自己手裏
2. 13 張手牌的數字都不一樣, i.e. `A`, `2`, `3`, ..., `Q`, `K`. (以下簡稱這個叫 `順子`)
    - 花色不用相同
    - 花色就算相同似乎也沒比較大: 如果有數人同時拿到 `順子`, 似乎就比較誰拿到最大的老二, 僅此而已.
3. 六對(**sáu đôi**), e.g. 一對 `3, 4, 7, 9, J, A`, 共 12 張, 剩下最後一張任意.

**註.** 以上情境有些不會同時發生在同一局的不同玩家手上.

- `(1, 2)` 不會同時發生, 因爲一旦有人拿了全部的 `2`, 就不可能另外有人蒐集到 `13張`了.
- `(2, 3)` 不會同時發生, 理由類似.
- `(1, 1)` 不會同時發生, 理由顯然.
- `(1, 3), (2, 2), (3, 3)` 可以同時發生.
    - `(1, 3)` 同時發生時, `1 > 3`.
    - `(3, 3)` 同時發生時, 大概就看誰的最大的一對比較大吧.
"""

# ╔═╡ ce2c6fd6-e3e8-11eb-1027-7b2798e55261
md"""
**Challenge.** 試着算算看這兩種 tới trắng 的機率分別是多少.

**Solution.**$(HTML("<br>"))
如果我們仔細想想, 會發現對於任何一位玩家, 他手上的手牌都像是從一副嶄新的牌組裏掏出來,
亦即不管他的手牌是怎麼樣子的, 都是
``\frac{1}{\begin{pmatrix} 52 \\ 13 \end{pmatrix}}\,.``

Ok, 如果同意以上的觀點的話, 那我們就有
```math
\mathbb{P}(\texttt{四張 2}) =
\frac{\begin{pmatrix} 52-4 \\ 13-4 \end{pmatrix}}
{\begin{pmatrix} 52 \\ 13 \end{pmatrix}} =
\frac{\frac{48!}{9!\,39!}}{\frac{52!}{13!\,39!}} =
\frac{48!\,13!}{9!\,52!} =
\frac{10\cdot 11\cdot 12\cdot 13}{49\cdot 50\cdot 51\cdot 52} \approx
(\frac{1}{5})^4 =
\frac{1}{625}\,.
```
"""

# ╔═╡ 2354387c-e3f3-11eb-2266-174bd65db60f
Vector(10:13)

# ╔═╡ cdd68328-e3e8-11eb-2e7b-a7ac3e2dffba
begin
  # 真正的機率值應該介在 1 / 4^4 和 1 / 5^4 之間
  四張2 = prod(10:13) / prod(49:52)
  四張2, 1 / 625, 1 / 4^4
end

# ╔═╡ 6da55f80-e3f5-11eb-3030-4f365bb9e780
md"""
```math
\mathbb{P}(\texttt{順子}) =
\frac{4^{13}}
{\begin{pmatrix} 52 \\ 13 \end{pmatrix}} =
\frac{4^{13}}
{\frac{52\cdot 51 \cdot\quad \cdots\quad \cdot(52-12)}
{13\cdot 12\cdot\quad\cdots\quad\cdot 1}} =
\frac{4^{13}}
{\underbrace{4\cdot(4.25)\cdot\quad\cdots\quad\cdot40}_{13\;\text{個}}}\,.
```

我們可以作個粗略的估計:
```math
\mathbb{P}(\texttt{順子}) \approx
\frac{4^{13}}
{4\cdot \quad\cdots\quad \cdot9\cdot 13\cdot 20\cdot 40}
```
"""

# ╔═╡ 076523e0-e3f5-11eb-14d0-73979c18b332
Vector(10:-1:7)

# ╔═╡ f9100ef4-e3f4-11eb-1626-2191ee70471d
順子_ = 4^13 / (prod(52:-1:(52-12)) / prod(13:-1:1))

# ╔═╡ 4ffd7300-bc5c-4470-a2b8-997d76ce98a5
md"""
(順子) 的機率出乎意料之外的高出 (四張 2) 很多. 這令我們有點好奇, 同花順的機率:
"""

# ╔═╡ a72a674e-e3f7-11eb-14ac-f9526786544d
# Thồng hoa sảng 同花順
同花順_ = 4 / (prod(52:-1:(52-12)) / prod(13:-1:1))

# ╔═╡ c3234b24-20ce-4299-8226-d2715bce29ee
md"""
接着我們算 (六對) 的機率.

其實有一個點我們剛纔沒有討論: (六對) 需要

- 六對不同數字, e.g. `1,1,3,3,7,7,8,8,10,10,Q,Q`?
- 還是六對可以重複數字, e.g. `3,3,3,3,8,8,9,9,J,J,K,K`?

我們兩個機率都會計算, 但是真實玩的時候, 似乎是
> 六對數字可以重複.

"""

# ╔═╡ fe2c0caf-4a95-4aae-add4-ef0727cb8540
md"""
```math
\begin{align}
  \mathbb{P}(\text{六對不重複}) &=
  \frac{
    \begin{pmatrix} 13 \\ 6 \end{pmatrix}
    \cdot
    \begin{pmatrix} 4 \\ 2 \end{pmatrix}^6
    \cdot
    \begin{pmatrix} 7 \\ 1 \end{pmatrix}
    \cdot
    \begin{pmatrix} 4 \\ 1 \end{pmatrix} +

    \begin{pmatrix} 13 \\ 5 \end{pmatrix}
    \cdot
    \begin{pmatrix} 4 \\ 2 \end{pmatrix}^5
    \cdot
    \begin{pmatrix} 8 \\ 1 \end{pmatrix}
    \cdot
    \begin{pmatrix} 4 \\ 3 \end{pmatrix}
  }
  {\begin{pmatrix} 52 \\ 13 \end{pmatrix}} \\

  &=
  \frac{
    \begin{pmatrix} 13 \\ 6 \end{pmatrix}
    \cdot
    6^5
    \cdot
    \left(
      6 \cdot 7 \cdot 4 +
      8 \cdot 4
    \right)
  }
  {\begin{pmatrix} 52 \\ 13 \end{pmatrix}} =

  \frac{
    \begin{pmatrix} 13 \\ 6 \end{pmatrix}
    \cdot
    6^5
    \cdot
    200
  }
  {\begin{pmatrix} 52 \\ 13 \end{pmatrix}}
  \\
  \\

  \mathbb{P}(\text{六對}) &=

  \mathbb{P}(\text{六對不重複}) +


  \frac{
    \begin{pmatrix} 13 \\ 1 \end{pmatrix}
    \begin{pmatrix} 12 \\ 4 \end{pmatrix}
    \begin{pmatrix} 4 \\ 2 \end{pmatrix}^4
    \begin{pmatrix} 8 \\ 1 \end{pmatrix}
    \begin{pmatrix} 4 \\ 1 \end{pmatrix} +

    \begin{pmatrix} 13 \\ 1 \end{pmatrix}
    \begin{pmatrix} 12 \\ 3 \end{pmatrix}
    \begin{pmatrix} 4 \\ 2 \end{pmatrix}^3
    \begin{pmatrix} 9 \\ 1 \end{pmatrix}
    \begin{pmatrix} 4 \\ 3 \end{pmatrix}
  }
{\begin{pmatrix} 52 \\ 13 \end{pmatrix}} \\ &\qquad\qquad\qquad\quad\;\;+

  \frac{
    \begin{pmatrix} 13 \\ 2 \end{pmatrix}
    \begin{pmatrix} 11 \\ 2 \end{pmatrix}
    \begin{pmatrix} 4 \\ 2 \end{pmatrix}^2
    \begin{pmatrix} 9 \\ 1 \end{pmatrix}
    \begin{pmatrix} 4 \\ 1 \end{pmatrix} +

    \begin{pmatrix} 13 \\ 2 \end{pmatrix}
    \begin{pmatrix} 11 \\ 1 \end{pmatrix}
    \begin{pmatrix} 4 \\ 2 \end{pmatrix}
    \begin{pmatrix} 10 \\ 1 \end{pmatrix}
    \begin{pmatrix} 4 \\ 3 \end{pmatrix}
  }
  {\begin{pmatrix} 52 \\ 13 \end{pmatrix}} \\ &\qquad\qquad\qquad\quad\;\;+

  \frac{
    \begin{pmatrix} 13 \\ 3 \end{pmatrix}
    \begin{pmatrix} 10 \\ 1 \end{pmatrix}
    \begin{pmatrix} 4 \\ 1 \end{pmatrix}
  }
  {\begin{pmatrix} 52 \\ 13 \end{pmatrix}}
\end{align}
```

**註.**$(HTML("<br>"))
上面我想到的算法其實有點複雜, 暫時也還沒有想到別的簡潔的算法. 讓我稍微解釋以下上面使用的算法:

- ``\mathbb{P}(\text{六對不重複})\,.`` $(HTML("<br>"))我試着在找出六對以後, 將情形分成兩種. 這也是爲什麼我們看到分子會是兩個項相加的原因.
    01. 最後一張是一張數字完全不同於前面十二張的牌
    02. 最後一張是一張數字相同於前面十二張裏的某張牌
- ``\mathbb{P}(\text{六對})\,.`` $(HTML("<br>"))算法和上述雷同. 值得留意的點或許是, 只存在以下三種情境:
    - 只有 **一個數字** 四張花色全部被選中, 這樣就已經有兩對了. 剩下四對和單張.
    - 有 **兩個數字** 四張花色全部被選中, 這樣就已經有四對了. 剩下兩對和單張.
    - 有 **三個數字** 四張花色全部被選中, 這樣就已經有六對了. 剩下單張.
"""

# ╔═╡ d8ac100f-0ea1-4ed4-949d-23adc12ff13d
function choose(n, k)
  #return prod(n:-1:n-k+1) / prod(1:k)
  #return prod([(n-k+i)/i for i in 1:k])
  return prod([(n-i+1)/i for i in 1:k])
end

# ╔═╡ 97cbb746-d1df-419d-9878-6cb3fa40d46a
# (?) Should these be equal? Or one of them is better?
prod([(52-i+1)/i for i in 1:13]) == prod([(52-13+i)/i for i in 1:13])

# ╔═╡ e72e1ab8-f5e3-434a-8bb5-3f6a2759e6c9
# A quick unit test for choose(): Pascal triangle
with_terminal() do
  for n in 2:6
    println([choose(n,k) for k in 0:n])
  end
end

# ╔═╡ 8c503032-dc96-40eb-b15b-4b7e17582878
typeof(prod(1:10))

# ╔═╡ fa032329-f986-4981-b19e-38d597788b08
md"""
**註.**$(HTML("<br>"))
上面第一個 implementation (i.e. `choose` 函數的第一行) 看似
**天真無邪**. $(HTML("<br>"))
實際上, 卻是一個重大的 bug 來源.

原因是
> 分子或分母裏的 `prod()` 的 return type 是 `Int64`.
>
> 但是 `prod()` 很容易就超過 `Int64` 的上限, 造成 return value 繞一圈回到負值 (俗稱 overflow), 最後計算的結果就錯誤了.
"""

# ╔═╡ a28716b9-a5b5-42ea-a1c6-9bfb28afcd6a
md"""
舉例來說, 如果我們用這個錯誤的 implementation 來算 ``\;\mathbb{P}(\text{四張 2})\;`` 的話, 我們會得到:

(還記得 $\quad\mathbb{P}(\texttt{四張 2}) =
\frac{\begin{pmatrix} 48 \\ 9 \end{pmatrix}}
{\begin{pmatrix} 52 \\ 13 \end{pmatrix}}\quad$ 嗎?)
"""

# ╔═╡ 3aa85ef5-70b3-4b1a-a9f0-90621aece45e
function choose_wrong(n, k)
  return prod(n:-1:n-k+1) / prod(1:k)
end

# ╔═╡ 98590253-95ec-4c43-9fc2-9fbc74a7e9c9
choose_wrong(48, 9) / choose_wrong(52, 13)

# ╔═╡ c15ef6a8-ae04-448d-8aae-9142c6bf9d20
md"""
我們得到 **大於 ``1`` 的機率**``\;``!! 這顯然出錯了.

讓我們仔細檢查看看是哪裏出錯的:
"""

# ╔═╡ 10a2e952-5ceb-448e-b79e-e7dc422870e3
choose_wrong(48, 9), choose_wrong(52, 13)

# ╔═╡ e61e56a3-2f3d-42b5-8f7a-a6e12aa1013c
md"""
既然我們懷疑 overflow, 那我們就得要舉證 overflow 確實有發生.
"""

# ╔═╡ ca012485-fe78-4d6b-af4a-c9bcd9949948
typemax(Int64), typemin(Int64), 2^63 - 1

# ╔═╡ 0d95b3cd-4ed6-4138-9d5b-e57b64c695e0
prod(52:-1:52-12), prod(big(52):-1:big(52-12))

# ╔═╡ e42d96d7-2592-4369-9e54-66556f030acd
prod(1:13), prod(big(1):big(13))

# ╔═╡ d4f12300-a6d2-4938-a476-1d9c23d86805
prod(48:-1:49-8), prod(big(48):-1:big(49-8))

# ╔═╡ 83219d9d-7628-436b-b858-8ba324c0cfdd
md"""
看上去這個樣子, 對於 ``\mathbb{P}(\text{四張 2})`` 的計算, 只有 ``52 \cdot 51 \cdot \;\cdots\; \cdot 40`` 被 overflow 而已.

讓我們試着用數值方法檢查 `prod(52:-1:52-12)` 是否真的是 `prod(big(52):-1:big(52-12))`
循環回來的那個數.
"""

# ╔═╡ 700d4846-70bc-46e8-99a9-a111ab5ea760
two64 = big(2)^64  # Note that big(2^64) is no good because it equals big(0)

# ╔═╡ 215a3d40-b740-4331-b98c-e9eb120ed83b
two63 = two64 ÷ 2

# ╔═╡ 96b79d90-353d-4461-8027-b1698202b7b9
begin
  prod_52_til_40 = prod(big(52):-1:big(52-12)) % two64
  if prod_52_til_40 >= two63
    prod_52_til_40 -= two63
  end
  prod_52_til_40 == prod(52:-1:(52-12))
end

# ╔═╡ 0cc82603-dbda-475c-a0ba-39afefc94c0d
md"""
所以, 的確, `prod(52:-1:52-12)` 是 `prod(big(52):-1:big(52-12))` overflow
循環回來的那個數.

上面我們使用數值方法證明 overflow. 這裏我們再試着用數學看看估計不估計得出一致的結果.

```math
\underbrace{52\cdot 51\cdot \;\cdots\; \cdot 41 \cdot 40}_{13\;\text{個}}\, \ge
40^{13} \ge
32^{13} =
(2^{5})^{13} =
2^{65} \gt
2^{63}
```

這個簡略的估計使我們看到確實 overflow 有發生.

在 `choose` 的第二個 implementation 裏, 我們利用常規的方法迴避了這個 overflow 的麻煩
> 我們把戰場拉到 `Float64` 裏, 比較不容易 overflow, 而且我們讓除法能夠儘早發生, 把數字變小讓精準度提升 (因爲 floating-point numbers 數字越小越密集).
"""

# ╔═╡ 3da9bdab-1ef9-43dc-89db-c17c4f23af85
typeof(choose(52,13))

# ╔═╡ 796a1def-f815-4824-a96c-12ed194e8274
typemax(Float64), prevfloat(typemax(Float64)), typemax(Int64), typemax(UInt64)

# ╔═╡ a458e909-4af7-42fb-9bfb-e588b348f4fc
md"""
讓我們繼續對於 ``\mathbb{P}(\text{六對(不重複)})`` 的計算.

因爲上面計算出來的表示式數字有點醜,
所以我們仰賴於電腦來告訴我們結果是多少:
"""

# ╔═╡ 4e8bc40d-4d66-4f40-916e-ffd7f97fcfa4
六對不重複 = (choose(13, 6) * 6^5 * 200) / choose(52, 13)

# ╔═╡ 99e83361-ffb3-44bf-8d44-b6c3df96f716
begin
  denom1 = 13*choose(12,4)*(6^4)*8*4 + 13*choose(12,3)*(6^3)*9*4
  denom2 = choose(13,2)*choose(11,2)*(6^4)*9*4 + choose(13,2)*choose(11,1)*(6)*10*4
  denom3 = choose(13,3)*10*4
  # Note that the following two computations give the same result
  六對 = 六對不重複 + (denom1 + denom2 + denom3) / choose(52, 13)
  #六對 = 六對不重複 + denom1/choose(52, 13) + denom2/choose(52, 13) + denom3/choose(52, 13)
end

# ╔═╡ c3103a5d-8e84-4de9-a2ab-e07e41b8dd41
md"""
## Double Check
因爲 overflow 的憂慮, 我們最好重新檢查前面的機率, 確認沒有算錯.
"""

# ╔═╡ a6e87695-b910-4df5-8be1-98ba0ecf90e4
typeof(4^(13)), 2^(64) == 4^(32)

# ╔═╡ 5899fd98-d4eb-453e-91cf-dce215381909
md"""
順子 和 同花順 其實都因爲 overflow 的關係算錯了:
"""

# ╔═╡ 630302dc-5b99-4388-aca4-65d5edda9fbf
順子 = 4^(13) / choose(52,13)

# ╔═╡ 70b8f18b-df61-47d9-a731-733c9a09cbd0
順子, 順子_

# ╔═╡ 104b7a95-f88c-470f-9a17-f11eda3c2e97
同花順 = 4 / choose(52,13)

# ╔═╡ 95c66329-c6a8-4852-bfe3-c6cabd3a08fa
同花順, 同花順_

# ╔═╡ 87496f61-4838-4b17-a2d7-4217e33798a0
四張2

# ╔═╡ 59375cf1-4f82-423e-82cb-f53304431ea3
choose(48, 9) / choose(52, 13)  # double check 四張2

# ╔═╡ e5498409-f170-4fa9-b599-b0c5a6bc0c4b
prod((10+i)/(49+i) for i in 0:3)  # double check 四張2

# ╔═╡ 39aede8d-c83d-4211-a2f0-67da45919e99
sort(collect(Dict(
  "四張2" => 四張2,
  "順子" => 順子,
  "六對" => 六對,
)), by=pair->pair[2])

# ╔═╡ 8f212e10-524b-4c0b-864e-f15b3d12eb2e
md"""
所以理論上, 機率的排序爲
> ``\mathbb{P}(\text{順子}) < \mathbb{P}(\text{四張 2}) < \mathbb{P}(\text{六對}) \,.``
"""

# ╔═╡ e12e91ff-862d-49bf-a6b8-a4ced154ced4
md"""
## Simulation
接着我們改寫 Stephan Karpinski 的 [`Cards.jl`](https://github.com/StefanKarpinski/Cards.jl)
來做 simulation. (改寫後的 Julia script 放在 `./TienLen.jl`)
"""

# ╔═╡ 6489cb93-65dc-4436-8416-b99e3a3df45d
md"""
`n_sessions = ` $(@bind n_sessions Slider(10:10:10_000_000;
show_value=true, default=10))
"""

# ╔═╡ 30bacf09-b2ff-4f40-a4c6-20099b997aab
#有順子(hand1)typeof(n_sessions), typemax(Int64) # ≈ 10^(18)

# ╔═╡ f5b96e84-2ce6-4b6c-b49c-0a4745a8db2a
begin
  print_first_k = 7
  stat_cards = Dict()
  for card in TienLen.deck
    stat_cards[card] = 0
  end
  #appeared_cards = Set()
  with_terminal() do
    n_四張2, n_六對, n_順子 = 0, 0, 0
    println("First few results:")
    for k in 1:n_sessions
      hand = deal()[1]
      if k <= print_first_k
        println("(k = $k) hand = $hand")
      end
      if 有四張(hand, 2)
        n_四張2 += 1
      end
      if 有六對(hand)
        n_六對 += 1
      end
      if 有順子(hand)
        n_順子 += 1
      end
      for card in hand
        #stat_cards[card] = get(stat_cards, card, 0) + 1
        stat_cards[card] = get(stat_cards, card, 0) + 1
        #push!(appeared_cards, card)
      end
    end
    stat_tới_trắng = Dict(
      "n_四張2" => n_四張2,
      "n_六對" => n_六對,
      "n_順子" => n_順子,
      "n_sessions" => n_sessions,
    )
    proba = Dict(
      "P(四張2)" => n_四張2 / n_sessions,
      "P(順子)" => n_順子 / n_sessions,
      "P(六對)" => n_六對 / n_sessions,
    )
    println("\nproba =\n$proba")
    println("\nstat_tới_trắng =\n$stat_tới_trắng")
    # for (k, v) in stat_cards
    #   stat_cards[k] /= n_sessions
    # end
    # println("\nstat_cards =\n$stat_cards")
  end
end

# ╔═╡ 35946182-14a6-40f0-8404-7eba0b94f96c
begin
stat_sorted_cards = sort(stat_cards)
bar(#[(k.value, v) for (k, v) in stat_cards],
    [(k.value, v) for (k, v) in stat_sorted_cards],
    alpha=0.5,
    size=(1000, 400),
    leg=false,
    bg=:black,
    xrotation=60,
    #xticks=collect(keys(stat_cards)),
    xticks=(12:1:63, [k for (k, v) in stat_sorted_cards]),
    #xticks=(12:1:63, [Card(k) for k in UInt8():typemax(UInt8)]),
    #xticks=["$k" for k in keys(stat_cards)],
    #xlabel="outcome",
    #ylabel="number of rolls",
    xlim=(12-2, 63+1),
)
hline!([n_sessions / 52 * 13], ls=:dash, lw=3, c=:red)
end

# ╔═╡ b9a8cd8b-11af-40f8-8506-706d63f04b36
stat_cards

# ╔═╡ e0d5924a-9a74-4f7a-a9eb-7483171c6f5c


# ╔═╡ 4b17be21-1bda-47d6-80b1-fa0bee2dd3b0


# ╔═╡ 8076b3b2-1bfc-4a48-9e9d-5a0275659d88


# ╔═╡ a4b81f4b-0b86-450b-9d9e-b9cce46ebf17


# ╔═╡ aced68c3-549b-46ee-9ba2-9f67188f9900


# ╔═╡ 2867514e-11e3-4616-8f67-9cd5f7adfb22


# ╔═╡ 5de54789-c29e-4521-8907-5833b140d2ba
md"""
## Some Utility Funcitons
"""

# ╔═╡ 442d8802-870f-456c-9532-e5a1c3211377
function annotate_spec(hand::Hand)
  size = 36
  pos=:center
  spec = []
  for card in hand
    if TienLen.suit(card) in (♢, ♡)
      color=:red
    else
      color=:black
    end
    push!(spec, ("$card", size, color, pos))
  end
  return spec
end

# ╔═╡ 58d35617-b383-4e2e-8705-083d92c5785d
# http://docs.juliaplots.org/latest/generated/gr/#gr-ref20
let
  h1, h2, _, _ = deal()
  #Plots.default(size=(2000, 1000))
  annotation = annotate_spec(h1)
  plot(1:13, 0.5*ones(13), bg=:white,
       size=(2500, 500),
       legend=false,
  )
  plot!(1:13, 1.5*ones(13), linewidth=10)
  plot!(1:13, 2.5*ones(13), linewidth=10)
  annotate!([(i, 1, annotation[i]) for i in 1:13])
  annotate!([(i, 2, annotation[i]) for i in 1:13])
end

# ╔═╡ Cell order:
# ╠═bf67b80e-e3e6-11eb-203d-2965a14e546f
# ╟─e2fe9812-e3e8-11eb-1c29-a76d35861730
# ╟─3b4e05c2-e3ec-11eb-0505-8bd038210963
# ╟─ce6f4722-e3e8-11eb-0367-6d8491d5c7ab
# ╟─ce2c6fd6-e3e8-11eb-1027-7b2798e55261
# ╠═2354387c-e3f3-11eb-2266-174bd65db60f
# ╠═cdd68328-e3e8-11eb-2e7b-a7ac3e2dffba
# ╟─6da55f80-e3f5-11eb-3030-4f365bb9e780
# ╠═076523e0-e3f5-11eb-14d0-73979c18b332
# ╠═f9100ef4-e3f4-11eb-1626-2191ee70471d
# ╟─4ffd7300-bc5c-4470-a2b8-997d76ce98a5
# ╠═a72a674e-e3f7-11eb-14ac-f9526786544d
# ╟─c3234b24-20ce-4299-8226-d2715bce29ee
# ╟─fe2c0caf-4a95-4aae-add4-ef0727cb8540
# ╠═d8ac100f-0ea1-4ed4-949d-23adc12ff13d
# ╠═97cbb746-d1df-419d-9878-6cb3fa40d46a
# ╠═e72e1ab8-f5e3-434a-8bb5-3f6a2759e6c9
# ╠═8c503032-dc96-40eb-b15b-4b7e17582878
# ╟─fa032329-f986-4981-b19e-38d597788b08
# ╟─a28716b9-a5b5-42ea-a1c6-9bfb28afcd6a
# ╠═3aa85ef5-70b3-4b1a-a9f0-90621aece45e
# ╠═98590253-95ec-4c43-9fc2-9fbc74a7e9c9
# ╟─c15ef6a8-ae04-448d-8aae-9142c6bf9d20
# ╠═10a2e952-5ceb-448e-b79e-e7dc422870e3
# ╟─e61e56a3-2f3d-42b5-8f7a-a6e12aa1013c
# ╠═ca012485-fe78-4d6b-af4a-c9bcd9949948
# ╠═0d95b3cd-4ed6-4138-9d5b-e57b64c695e0
# ╠═e42d96d7-2592-4369-9e54-66556f030acd
# ╠═d4f12300-a6d2-4938-a476-1d9c23d86805
# ╟─83219d9d-7628-436b-b858-8ba324c0cfdd
# ╠═700d4846-70bc-46e8-99a9-a111ab5ea760
# ╠═215a3d40-b740-4331-b98c-e9eb120ed83b
# ╠═96b79d90-353d-4461-8027-b1698202b7b9
# ╟─0cc82603-dbda-475c-a0ba-39afefc94c0d
# ╠═3da9bdab-1ef9-43dc-89db-c17c4f23af85
# ╠═796a1def-f815-4824-a96c-12ed194e8274
# ╟─a458e909-4af7-42fb-9bfb-e588b348f4fc
# ╠═4e8bc40d-4d66-4f40-916e-ffd7f97fcfa4
# ╠═99e83361-ffb3-44bf-8d44-b6c3df96f716
# ╟─c3103a5d-8e84-4de9-a2ab-e07e41b8dd41
# ╠═a6e87695-b910-4df5-8be1-98ba0ecf90e4
# ╟─5899fd98-d4eb-453e-91cf-dce215381909
# ╠═630302dc-5b99-4388-aca4-65d5edda9fbf
# ╠═70b8f18b-df61-47d9-a731-733c9a09cbd0
# ╠═104b7a95-f88c-470f-9a17-f11eda3c2e97
# ╠═95c66329-c6a8-4852-bfe3-c6cabd3a08fa
# ╠═87496f61-4838-4b17-a2d7-4217e33798a0
# ╠═59375cf1-4f82-423e-82cb-f53304431ea3
# ╠═e5498409-f170-4fa9-b599-b0c5a6bc0c4b
# ╠═39aede8d-c83d-4211-a2f0-67da45919e99
# ╟─8f212e10-524b-4c0b-864e-f15b3d12eb2e
# ╟─e12e91ff-862d-49bf-a6b8-a4ced154ced4
# ╠═81bab1d0-a08e-4809-966c-eff81c21e77b
# ╟─6489cb93-65dc-4436-8416-b99e3a3df45d
# ╠═30bacf09-b2ff-4f40-a4c6-20099b997aab
# ╟─f5b96e84-2ce6-4b6c-b49c-0a4745a8db2a
# ╟─35946182-14a6-40f0-8404-7eba0b94f96c
# ╠═b9a8cd8b-11af-40f8-8506-706d63f04b36
# ╠═e0d5924a-9a74-4f7a-a9eb-7483171c6f5c
# ╠═4b17be21-1bda-47d6-80b1-fa0bee2dd3b0
# ╠═8076b3b2-1bfc-4a48-9e9d-5a0275659d88
# ╠═a4b81f4b-0b86-450b-9d9e-b9cce46ebf17
# ╠═58d35617-b383-4e2e-8705-083d92c5785d
# ╠═aced68c3-549b-46ee-9ba2-9f67188f9900
# ╠═2867514e-11e3-4616-8f67-9cd5f7adfb22
# ╟─5de54789-c29e-4521-8907-5833b140d2ba
# ╠═442d8802-870f-456c-9532-e5a1c3211377
