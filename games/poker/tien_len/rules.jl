### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ bf67b80e-e3e6-11eb-203d-2965a14e546f
begin
  using Pkg
  # .julia_env/ is in the root dir of this repo
  Pkg.activate("../../../../.julia_env/oft")
  Pkg.add("PlutoUI")
  #using Cards
  #using TikzPictures
end

# ╔═╡ e2fe9812-e3e8-11eb-1c29-a76d35861730
md"""
# Tiến Lên
**Tiến lên** 是越南的撲克牌遊戲, 規則跟臺灣的 **大老二** 大致相似.

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


以下我們會做一些機率上的運算, 爲方便說明, 如果不特別明說, 都是假定四個玩家的情形作討論.
"""

# ╔═╡ ce6f4722-e3e8-11eb-0367-6d8491d5c7ab
md"""
## Tới Trắng
這是一手牌在你拿到的同時, 就決定你已經贏了這局, 連一張牌都不需要出.

在我所在的家庭裏, tới trắng 發生在以下這兩種手牌裏:

1. 四張 `2` 都落在自己手裏
2. 13 張手牌的數字都不一樣, i.e. `A`, `2`, `3`, ..., `Q`, `K`. (以下簡稱這個叫 `13張`)
    - 花色不用相同
    - 花色就算相同似乎也沒比較大: 如果有數人同時拿到 `13張`, 似乎就比較誰拿到最大的老二, 僅此而已.
3. 六對(**sáu đôi**), e.g. 一對 `3, 4, 7, 9, J, A`, 共 12 張.

**註.** 上述兩種情境不會同時發生, 因爲一旦有人拿了全部的 `2`, 就不可能另外有人蒐集到 `13張`了.
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
\frac{\begin{pmatrix} 52-4 \\ 9 \end{pmatrix}}
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
# 真正的機率值應該介在 1 / 4^4 和 1 / 5^4 之間
prod(10:13) / prod(49:52), 1 / 625, 1 / 4^4

# ╔═╡ 6da55f80-e3f5-11eb-3030-4f365bb9e780
md"""
```math
\mathbb{P}(\texttt{13 張}) =
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
\mathbb{P}(\texttt{13 張}) \approx
\frac{4^{13}}
{4\cdot \quad\cdots\quad \cdot9\cdot 13\cdot 20\cdot 40}
```
"""

# ╔═╡ 076523e0-e3f5-11eb-14d0-73979c18b332
Vector(10:-1:7)

# ╔═╡ f9100ef4-e3f4-11eb-1626-2191ee70471d
4^13 / (prod(52:-1:(52-12)) / prod(13:-1:1))

# ╔═╡ a72a674e-e3f7-11eb-14ac-f9526786544d
# Thồng hoa sảng 同花順
4 / (prod(52:-1:(52-12)) / prod(13:-1:1))

# ╔═╡ Cell order:
# ╠═bf67b80e-e3e6-11eb-203d-2965a14e546f
# ╟─e2fe9812-e3e8-11eb-1c29-a76d35861730
# ╟─3b4e05c2-e3ec-11eb-0505-8bd038210963
# ╟─ce6f4722-e3e8-11eb-0367-6d8491d5c7ab
# ╠═ce2c6fd6-e3e8-11eb-1027-7b2798e55261
# ╠═2354387c-e3f3-11eb-2266-174bd65db60f
# ╠═cdd68328-e3e8-11eb-2e7b-a7ac3e2dffba
# ╟─6da55f80-e3f5-11eb-3030-4f365bb9e780
# ╠═076523e0-e3f5-11eb-14d0-73979c18b332
# ╠═f9100ef4-e3f4-11eb-1626-2191ee70471d
# ╠═a72a674e-e3f7-11eb-14ac-f9526786544d
