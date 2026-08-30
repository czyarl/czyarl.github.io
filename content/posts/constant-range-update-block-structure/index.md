---
title: "一种支持常数区间修改的分块结构"
description: "一种以多层分块换取常数区间修改、平方根级单点查询的实验性数据结构。"
date: 2021-03-10T23:38:00+08:00
lastmod: 2021-03-12T07:25:00+08:00
slug: constant-range-update-block-structure
tags:
  - algorithms
  - data-structures
  - notes
featured: false
legacy: true
math: true
originalId: 14515009
originalURL: https://www.cnblogs.com/czyarl/p/14515009.html
---

# 一点背景

* 众所周知，分块是个用来平衡复杂度的好东西，他几乎能做到修改询问中一个为区间一个为单点，一个单次复杂度$O(1)$一个单次复杂度为$O(\sqrt{n})$的4种排列组合中任何一种。
* 但是其中有一个盲点：不能很简单地做$O(1)$区间改，$O(\sqrt{n})$单点查，并且区间改不能转化成前缀操作的事情。比如区间修改或者区间取min。
* 这其实没什么问题，因为zkw线段树能做这件事而且跑得很快。
* 但是总是很遗憾不是吗？
* 所以我搞了这个分块算法出来，不过可惜的是这个东西确实没有什么用。以及这就是砍倒了B树并加入了一点暴力。
* 以及欢迎写个数据结构和我的代码打一打。

# 概述

数据结构，支持以下两种操作：
* 区间修改、取min、取max或者其他能快速合并的东西。复杂度$O(1)$。
* 单点查询。复杂度$O(\sqrt{n})$。

空间复杂度$O(n^{\frac{5}{4}})$，预处理时间复杂度$O(n^{\frac{5}{4}})$。

# 做法

其实这个东西的本质是将B树留下来3层，然后叶子节点上跑暴力。

## Blo4

这里实现了一个支持$O(1)$区间改和$O(n^2)$单点查的数据结构。空间复杂度$O(n^2)$。

随便维护一下这个区间内的$\frac{n(n+1)}{2}$种区间的tag。修改的时候直接改对应区间，询问的时候把包含询问点的区间全都遍历一遍。

代码：

```c
struct Blo4{
	int a[MAXSQR4+1][MAXSQR4+1];
	int n;
	void build(int ca[], int l, int r)
	{
		n = r-l+1;
		for(int i = 1;i<=n;i++)
		{
			a[i][i] = ca[l+i-1];
			for(int j = i+1;j<=n;j++) a[i][j] = min(a[i][j-1], ca[l+j-1]);
		}
	}
	void qu_min(int l, int r, int cn) {Min(a[l][r], cn); }
	int query(int cn)
	{
		int ans = a[cn][cn];
		for(int i = 1;i<=cn;i++) for(int j = cn;j<=n;j++) Min(ans, a[i][j]);
		return ans;
	}
};
```

## Blo2


这里实现了一个支持$O(1)$区间改和$O(n)$单点查的数据结构。空间复杂度$O(n^{\frac{3}{2}})$。

具体就是分块。分成$\lceil\sqrt{n}\rceil$块，然后再对每一块记录整块的tag。我们发现此时有$\lceil\sqrt{n}\rceil+1$块，每块长度为$\lfloor\sqrt{n}\rfloor$。

我们对于每个块用一个Blo4维护，然后再对tag开一个Blo4维护。

我们发现一次修改会覆盖一段连续的整块和两边的小块的前缀或者后缀。也就是变成了两个小块的Blo4和一个tag的Blo4的区间改。

查询的时候我们需要查询这个点在小块内的点值和覆盖这个点的tag。这个就是两次Blo4的单点查。

代码：（里面维护了前缀和后缀，这个之后解释）

```c
struct Blo2{
	Blo4 a[MAXSQR4+2];
	int pre[MAXSQR2+1], suf[MAXSQR2+1], blo[MAXSQR2+1], tou[MAXSQR2+1], wei[MAXSQR2+1];
	int tmp[MAXSQR4+1];
	int n, Sqr, alen;
	void build(int ca[], int l, int r)
	{
		n = r-l+1; Sqr = sqrt(n);
		for(int i = 1;i<=n;i++) pre[i] = suf[i] = INF;
		for(int i = 1;i<=n;)
		{
			int j = min(n, i+Sqr-1); alen++;
			tou[alen] = i; wei[alen] = j;
			for(int ij = i;ij<=j;ij++) blo[ij] = alen;
			a[alen].build(ca, l+i-1, l+j-1);
			tmp[alen] = INF;
			i = j+1;
		}
		++alen; a[alen].build(tmp, 1, alen-1);
	}
	void qu_min_suf(int l, int cn) {Min(suf[l], cn); }
	void qu_min_pre(int r, int cn) {Min(pre[r], cn); }
	void qu_min(int l, int r, int cn)
	{
		if(blo[l] == blo[r]) a[blo[l]].qu_min(l-tou[blo[l]]+1, r-tou[blo[l]]+1, cn);
		else {
			a[blo[l]].qu_min(l-tou[blo[l]]+1, wei[blo[l]]-tou[blo[l]]+1, cn);
			a[alen].qu_min(blo[l]+1, blo[r]-1, cn);
			a[blo[r]].qu_min(1, r-tou[blo[r]]+1, cn);
		}
	}
	int query(int cn)
	{
		int ans = min(a[alen].query(blo[cn]), a[blo[cn]].query(cn-tou[blo[cn]]+1));
		for(int i = cn;i<=n;i++) Min(ans, pre[i]);
		for(int i = 1;i<=cn;i++) Min(ans, suf[i]);
		return ans;
	}
};
```

## Blo1

这里实现了一个支持$O(1)$区间改和$O(n^{\frac{1}{2}})$单点查的数据结构。空间复杂度$O(n^{\frac{5}{4}})$。

就是类似Blo2的弄一下，除了Blo2中的维护开的是Blo4，而现在我开的是Blo2，其他完全相同。

你会发现这不就是B树吗？

代码

```c
struct Blo1{
	Blo2 a[MAXSQR2+2];
	int blo[MAXSQR1+1], tou[MAXSQR1+1], wei[MAXSQR1+1];
	int pre[MAXSQR1+1], suf[MAXSQR1+1];
	int n, Sqr, alen;
	void build(int ca[], int l, int r)
	{
		n = r-l+1; Sqr = sqrt(n);
		for(int i = 1;i<=n;i++) pre[i] = suf[i] = INF;
		for(int i = 1;i<=n;)
		{
			int j = min(n, i+Sqr-1); alen++;
			tou[alen] = i; wei[alen] = j;
			for(int ij = i;ij<=j;ij++) blo[ij] = alen;
			a[alen].build(ca, l+i-1, l+j-1);
			tmp[alen] = INF;
			i = j+1;
		}
		++alen; a[alen].build(tmp, 1, alen-1);
	}
	void qu_min(int l, int r, int cn)
	{
		if(blo[l] == blo[r]) a[blo[l]].qu_min(l-tou[blo[l]]+1, r-tou[blo[l]]+1, cn);
		else {
			Min(suf[l], cn); Min(pre[r], cn);
			if(blo[l] < blo[r]-1) a[alen].qu_min(blo[l]+1, blo[r]-1, cn);
		}
	}
	int query(int cn)
	{
		int ans = min(a[alen].query(blo[cn]), a[blo[cn]].query(cn-tou[blo[cn]]+1));
		for(int i = wei[blo[cn]];i>=cn;i--) Min(ans, pre[i]);
		for(int i = tou[blo[cn]];i<=cn;i++) Min(ans, suf[i]);
		return ans;
	}
};
```

## 常数优化

我们注意到这里的$O(1)$快有一个log了。事实上这里的$O(1)$是跑不过zkw线段树的。（在$n=6250000$下）

如果就照着我上文所说来维护，事情会变成$O(1)$在最坏情况下成为$3\times 3=9$次Blo4的区间修改。很离谱。而且会访问大量数组。不太行。

怎么办，我们发现Blo1改动Blo2的时候实际上只有一个是真正的区间改，还有两个是前后缀改动。我们可以特殊维护一下前后缀。这样虽然会导致回答的时候变慢（也没有变慢多少），但是显著提升了算法速度。

进一步，我们发现Blo4太鸡肋了，我们可以将其维护进Blo2当中（就不用跳来跳去了），这样子就更快了一点。

## 最终的代码

这份代码为了解决输入过大的问题，在代码中根据输入的随机种子生成询问。

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 6250100
#define MAXSQR1 6250100
#define MAXSQR2 2510
#define MAXSQR4 50
#define INF 1010000000
using namespace std;
template<typename T> void Read(T &cn)
{
	char c; int sig = 1;
	while(!isdigit(c = getchar())) if(c == '-') sig = 0;
	if(sig) {cn = c-48; while(isdigit(c = getchar())) cn = cn*10-48+c; }
	else    {cn = 48-c; while(isdigit(c = getchar())) cn = cn*10+48-c; }
}
template<typename T> void Write(T cn)
{
	T cm = 0; int cx = cn%10, wei = 0; cn = cn/10;
	if(cn < 0 || cx < 0) {putchar('-'); cn = -cn; cx = -cx; }
	while(cn) wei++, cm = cm*10+cn%10, cn = cn/10;
	while(wei--) putchar(cm%10+48), cm = cm/10;
	putchar(cx+48);
}
template<typename T> void WriteS(T cn) {Write(cn); putchar(' '); }
template<typename T> void WriteL(T cn) {Write(cn); puts(""); }
namespace getNum{
	unsigned lst;
	int q1, q2, A, n;
	void pre(int cn, int cq1, int cq2, int seed, int cA) {q1 = cq1, q2 = cq2, lst = seed, A = cA, n = cn; }
	unsigned get_r(unsigned cn) {lst ^= lst<<7; lst ^= lst>>3; lst ^= lst<<13; return lst%cn; }
	int get_n(int l, int r) {return l + get_r(r-l+1); }
	void get_val(int &val) {val = get_n(1, A); }
	void get_ne(int &typ, int &pos, int &l, int &r, int &val)
	{
		typ = get_n(1, q1+q2)<=q1 ? 1 : 2;
		if(typ == 1) q1--, l = get_n(1,n), r = get_n(l, n), val = get_n(1, A);
		if(typ == 2) q2--, pos = get_n(1,n);
	}
}
template<typename T> inline void Max(T &cn, T cm) {cn = cn < cm ? cm : cn; }
template<typename T> inline void Min(T &cn, T cm) {cn = cn < cm ? cn : cm; }
struct Blo2{
	int a[MAXSQR2+1][MAXSQR4+1];
	int b[MAXSQR4+1][MAXSQR4+1];
	unsigned char blo[MAXSQR2+1], hao[MAXSQR2+1];
	int tou[MAXSQR2+1], wei[MAXSQR2+1];
	int pre[MAXSQR2+1], suf[MAXSQR2+1];
	int n, Sqr, alen;
	void build(int ca[], int l, int r)
	{
		n = r-l+1; Sqr = sqrt(n);
		for(int i = 1;i<=n;i++) pre[i] = suf[i] = INF;
		for(int i = 1;i<=n;)
		{
			int j = min(n, i+Sqr-1); alen++;
			tou[alen] = i; wei[alen] = j;
			for(int ij = i;ij<=j;ij++) blo[ij] = alen, hao[ij] = ij-i+1;
			for(int ij = i;ij<=j;ij++)
			{
				a[ij][ij-i+1] = ca[ij];
				for(int ik = ij+1;ik<=j;ik++) a[ij][ik-i+1] = min(a[ij][ik-i], ca[ik]);
			}
			i = j+1;
		}
		++alen;
		for(int i = 1;i<=alen-1;i++) for(int j = i;j<=alen-1;j++) b[i][j] = INF;
	}
	void qu_min(int l, int r, int cn)
	{
		(blo[l] != blo[r]) ? Min(suf[l], cn), Min(b[blo[l]+1][blo[r]-1], cn), Min(pre[r], cn) : Min(a[l][hao[r]], cn);
//		if(blo[l] == blo[r]) Min(a[l][hao[r]], cn);
//		else {
//			Min(suf[l], cn);
//			Min(b[blo[l]+1][blo[r]-1], cn);
//			Min(pre[r], cn);
//		}
	}
	int query(int cn)
	{
		int ans = INF, cpos = blo[cn], clen = wei[cpos]-tou[cpos]+1;
		for(int i = 1;i<=cpos;i++) for(int j = cpos;j<=alen-1;j++) Min(ans, b[i][j]);
		for(int i = tou[cpos];i<=cn;i++) for(int j = hao[cn];j<=clen;j++) Min(ans, a[i][j]);
		for(int i = wei[cpos];i>=cn;i--) Min(ans, pre[i]);
		for(int i = tou[cpos];i<=cn;i++) Min(ans, suf[i]);
		return ans;
	}
};
struct Blo1{
	Blo2 a[MAXSQR2+2];
	unsigned short blo[MAXSQR1+1];
	int tou[MAXSQR1+1], wei[MAXSQR1+1];
	int pre[MAXSQR1+1], suf[MAXSQR1+1];
	int n, Sqr, alen;
	int tmp[MAXSQR2+1];
	void build(int ca[], int l, int r)
	{
		n = r-l+1; Sqr = sqrt(n);
		for(int i = 1;i<=n;i++) pre[i] = suf[i] = INF;
		for(int i = 1;i<=n;)
		{
			int j = min(n, i+Sqr-1); alen++;
			tou[alen] = i; wei[alen] = j;
			for(int ij = i;ij<=j;ij++) blo[ij] = alen;
			a[alen].build(ca, l+i-1, l+j-1);
			tmp[alen] = INF;
			i = j+1;
		}
		++alen; a[alen].build(tmp, 1, alen-1);
	}
	void qu_min(int l, int r, int cn)
	{
		if(blo[l] == blo[r]) a[blo[l]].qu_min(l-tou[blo[l]]+1, r-tou[blo[l]]+1, cn);
		else {
			Min(suf[l], cn), Min(pre[r], cn);
			if(blo[l] < blo[r]-1) a[alen].qu_min(blo[l]+1, blo[r]-1, cn);
		}
	}
	int query(int cn)
	{
		int ans = min(a[alen].query(blo[cn]), a[blo[cn]].query(cn-tou[blo[cn]]+1));
		for(int i = wei[blo[cn]];i>=cn;i--) Min(ans, pre[i]);
		for(int i = tou[blo[cn]];i<=cn;i++) Min(ans, suf[i]);
		return ans;
	}
};
Blo1 T;
int n, q1, q2, Seed, A;
int a[MAXN+1];
int main()
{
	cerr<<(sizeof(T))/1024.0/1024.0<<endl;
	freopen("block.in","r",stdin);
	freopen("block.out","w",stdout);
	Read(n); Read(q1); Read(q2); Read(A); Read(Seed);
	getNum::pre(n, q1, q2, Seed, A);
	for(int i = 1;i<=n;i++) getNum::get_val(a[i]);
	T.build(a, 1, n);
	LL ans = 0;
	LL lei = 0;
	for(int i = 1;i<=q1+q2;i++)
	{
		if(i % 1000000 == 0) cerr<<i<<endl;
		int btyp, bx, bl, br, bpos;
		getNum::get_ne(btyp, bpos, bl, br, bx);
		if(btyp == 1) T.qu_min(bl, br, bx);
		int kai = clock();
		if(btyp == 2) ans = ans ^ (1ll*T.query(bpos)*i);
		lei = lei + clock()-kai;
	}
	WriteL(ans);
	cerr<<lei<<endl;
	return 0;
}
```

# 执行时间测试

## 简单的比较

使用上文中的最终代码，输入为

```txt
6250000 40000000 10000 1000000000 998244353
```

在我的个人笔记本（拯救者R720-15IKBN）上，使用mingw编译，开O2：

| type     | Memory(data structure only) | time | data structure time |
|----------|-----------------------------|------|---------------------|
| zkw      | 95.36MB                     | 9.9s | 8343ms              |
| block_1  | 1566.17MB                   | 12.9s| 10630ms             |
| block_2  | 1467.68MB                   | 7.12s| 5043ms              |
| pcf_1    | 1690.54MB                   | 5.95s| 4736ms              |

其中block_1是没有加我常数优化那一节中的内容的程序，block_2是加了之后的程序，pcf_1是GreenDuck写的。

注意到zkw的额外时间相当短，这是因为我没有在数据结构使用时间中计算预处理的时间。

还不错。

更详细的分析就先鸽了。

以及，所以，我觉得这个算法如果想要在竞赛中有用，必须等计算机快个几倍才行。就是个理论上的算法罢了。

## 离谱的分析

我们经过简单估算，发现数组长度要到$2^{24}$的数量级，这个算法才会和zkw的实际效率有显著差异（意为无论如何实现都能与zkw较好的实现有相近的效率，并且较好的实现可以做到使用时间为zkw的一半以内）。但是那时他将使用4GB的空间，有点离谱。

## 其他方式

我们可以开一个k叉树，取$k=n^{\frac{1}{3}}$，我们就将一次修改变成了1次长度为$n^{\frac{1}{3}}$的数组上的区间改和4个长度为$n^{\frac{1}{3}}$个数组上的前缀后缀改。这个东西我们可以用修改$O(1)$，查询$O(n)$的ST表来实现，复杂度为修改$O(1)$，查询$O(n^{\frac{1}{3}}\log n)$，空间$O(n\log n)$。

不过这个东西我估计他常数也不会太小。但是不难写，也许是一个卡常的思路吧。

~~我不想写了。~~
