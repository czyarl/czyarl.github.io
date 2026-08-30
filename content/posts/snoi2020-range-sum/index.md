---
title: "SNOI 2020「区间和」题解"
description: "从线段树与势能分析出发，整理 SNOI2020 区间和问题的关键维护方式。"
date: 2020-11-25T12:24:00+08:00
lastmod: 2020-11-25T12:27:00+08:00
slug: snoi2020-range-sum
tags:
  - algorithms
  - data-structures
  - problem-solution
featured: true
legacy: true
math: true
originalId: 14035337
originalURL: https://www.cnblogs.com/czyarl/p/14035337.html
---

# 链接

[LOJ3325](https://loj.ac/p/3325)
[LuoguP6792](https://www.luogu.com.cn/problem/P6792)

# 题解

[xyx的题解](https://blog.csdn.net/qq_39972971/article/details/107207992)

~~复读机：~~
* 发现如果要实现区间取max，区间求和，都必须使用吉司机线段树，那这道题就大概率是要在吉司机线段树的基础上魔改而来。
* 如果要求区间最大子段和，一定要记录最大前缀，最大后缀，区间和，最大子段和。
* 我们发现吉司机线段树的第一种情况：modify<node.min，此时显然可以直接退出，第三种情况，modify>=node.min_2nd，直接递归下去显然没有问题。
* 那就要讨论一下第二种情况。我们发现我们这个节点的修改过后的最大前缀的值大概率是原值加上最大前缀中整个区间最小值的个数乘最小值的增量。
  * 什么时候不是？可能存在另外一个前缀，数字和当前没有现在的最大前缀大，但是里面的区间最小值多，一取max就成为新的最大前缀了。最大后缀和最大子段和同理。
  * 怎么办？我们可以对线段树上每个节点记录下来【以他为根的子树中每个点的这三个量】当区间取max最小取到多少的时候会变化。那么如果我们当前的tag大于等于这个阈值，同样参照吉司机线段树的第三种情况递归下去。
  * 为此，我们必须再记录一下每个最大前缀、最大后缀、最大子段和中的区间最小值个数。
* 时间复杂度是什么？
  * 我们额外的操作是不会影响吉司机线段树的复杂度分析的。所以我们只用分析因为阈值而递归两子树的时候的复杂度。
  * 首先分析最大前缀。记势能函数$\varphi$为所有节点的最大前缀长度之和。我们发现每次因为最大前缀改变而下推标记总会使得这个势能函数至少增加1（因为只有区间取max，最长前缀的长度是单调不降的）。$\varphi$每增大1，需要花费$O(\log n)$的时间，$\varphi$最大为$O(n\log n)$，故这里的时间为$O(n\log^2n)$。
  * 最大后缀和最大前缀对称，也为$O(n\log^2n)$。
  * 最大子段和，会发现如果是因为最大前缀和最大后缀而改动的最大子段和，显然复杂度可以和他们一起统计。
  * 如果所有孩子和自己的前缀、后缀都没有变而最大子段和变了，那最多只会变2次。所以复杂度依旧为$O(n\log^2n)$。
  * 综上，时间为$O(n\log^2n)$。
* 这道题的代码难度基本上在update上。

# 代码

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 101000
#define INF 1000000100
using namespace std;
template<typename T> void Read(T &cn)
{
	char c; int sig = 1;
	while(!isdigit(c = getchar())) if(c == '-') sig = 0;
	if(sig) {cn = c-48; while(isdigit(c = getchar())) cn = cn*10+c-48; }
	else    {cn = 48-c; while(isdigit(c = getchar())) cn = cn*10+48-c; }
}
template<typename T> void Write(T cn)
{
	int wei = 0; T cm = 0; int cx = cn%10; cn/=10;
	if(cn < 0 || cx < 0) {putchar('-'); cn = 0-cn; cx = 0-cx; }
	while(cn)cm = cm*10+cn%10,cn/=10,wei++;
	while(wei--)putchar(cm%10+48),cm/=10;
	putchar(cx+48);
}
template<typename T> void WriteL(T cn) {Write(cn); puts(""); }
template<typename T> void WriteS(T cn) {Write(cn); putchar(' '); }
template<typename T> void Max(T &cn, T cm) {cn = cn < cm ? cm : cn; }
template<typename T> void Min(T &cn, T cm) {cn = cn < cm ? cn : cm; }
struct Seg{
	struct qwe{
		LL val; int shu;
		qwe() {val = -INF; shu = 0; }
		qwe(LL cn, int cm) {val = cn; shu = cm; }
		inline friend bool operator <(qwe a, qwe b) {return a.val < b.val; }
		inline friend qwe operator +(qwe a, qwe b) {a.val+=b.val; a.shu+=b.shu; return a; }
		void zeng(int cn) {val = val + 1ll*cn*shu; }
	};
	struct node{
		int xi, cixi;
		qwe he, pre, suf, duan;
		LL p_max, mintime;
		void qing()
		{
			xi = cixi = INF;
			he = pre = suf = duan = qwe(0, 0);
			p_max = -INF; mintime = INF;
		}
		void set(int cn)
		{
			xi = cn; cixi = INF;
			he = pre = suf = duan = qwe(cn, 1);
			p_max = cn; mintime = INF;
		}
		void up_xi(int cn) {if(xi==cn) return; xi = cn; he.shu = pre.shu = suf.shu = duan.shu = 0; }
	};
	node t[MAXN*4+1];
	int n;
	LL suan(qwe xian, qwe nex) {return nex.shu <= xian.shu ? INF : (xian.val-nex.val)/(nex.shu-xian.shu); }
	void update(node &cn, node ls, node rs)
	{
		cn.xi = min(ls.xi, rs.xi);
		cn.cixi = min(ls.cixi, rs.cixi);
		if(ls.xi < rs.xi) Min(cn.cixi, rs.xi);
		if(rs.xi < ls.xi) Min(cn.cixi, ls.xi);
		ls.up_xi(cn.xi);
		rs.up_xi(cn.xi);
		cn.he = ls.he + rs.he;
		cn.duan = max(max(ls.duan, rs.duan), ls.suf+rs.pre);
		cn.pre = max(ls.pre, ls.he+rs.pre);
		cn.suf = max(rs.suf, rs.he+ls.suf);
		cn.mintime = min(min(ls.mintime, rs.mintime), cn.xi+min(suan(cn.pre, ls.he+rs.pre), suan(cn.suf, rs.he+ls.suf)));
		Min(cn.mintime, cn.xi+min(min(suan(cn.duan, ls.duan), suan(cn.duan, rs.duan)), suan(cn.duan, ls.suf+rs.pre)));
	}
	void tui(int cn, int l, int r)
	{
		int ls = cn<<1, rs = ls|1, zh = (l+r)>>1;
		dfs_da(ls, l, zh, t[cn].p_max); dfs_da(rs, zh+1, r, t[cn].p_max);
		t[cn].p_max = -INF;
	}
	void dfs_da(int cn, int l, int r, int cm)
	{
		if(t[cn].xi >= cm) return;
		if(t[cn].cixi > cm && cm < t[cn].mintime) {
			t[cn].he.zeng(cm-t[cn].xi); t[cn].duan.zeng(cm-t[cn].xi);
			t[cn].pre.zeng(cm-t[cn].xi); t[cn].suf.zeng(cm-t[cn].xi);
			t[cn].xi = cm; t[cn].p_max = cm;
			return;
		}
		t[cn].p_max = cm;
		tui(cn, l, r); update(t[cn], t[cn<<1], t[(cn<<1)|1]);
	}
	void build(int cn, int l, int r, int a[])
	{
		t[cn].qing(); if(l == r) {t[cn].set(a[l]); return; }
		int zh = (l+r)>>1; build(cn<<1,l,zh,a); build((cn<<1)|1,zh+1,r,a);
		update(t[cn], t[cn<<1], t[(cn<<1)|1]);
	}
	void gai_da(int cn, int cm, int cl, int cr, int l, int r)
	{
		if(cl <= l && r <= cr) {dfs_da(cn,l,r,cm); return; }
		int zh = (l+r)>>1; tui(cn,l,r);
		if(cl <= zh) gai_da(cn<<1, cm, cl, cr, l, zh);
		if(cr >  zh) gai_da((cn<<1)|1, cm, cl, cr, zh+1, r);
		update(t[cn], t[cn<<1], t[(cn<<1)|1]);
	}
	void qiu(int cn, int cl, int cr, int l, int r, node &ans)
	{
		if(cl <= l && r <= cr) {update(ans, ans, t[cn]); return; }
		int zh = (l+r)>>1; tui(cn, l, r);
		if(cl <= zh) qiu(cn<<1, cl, cr, l, zh, ans);
		if(cr >  zh) qiu((cn<<1)|1, cl, cr, zh+1, r, ans);
	}
	void build(int cn, int a[]) {n = cn; build(1,1,n,a); }
	void gai_da(int cl, int cr, int cm) {gai_da(1,cm,cl,cr,1,n); }
	LL qiu(int cl, int cr) {node guo; guo.qing(); qiu(1,cl,cr,1,n,guo); return guo.duan.val; }
}T;
int n,q;
int a[MAXN+1];
int main()
{
//	freopen("hack1.in","r",stdin);
//	freopen(".out","w",stdout);
	Read(n); Read(q);
	for(int i = 1;i<=n;i++) Read(a[i]);
	T.build(n, a);
	for(int i = 1;i<=q;i++)
	{
		int typ, bl, br, bx; Read(typ); Read(bl); Read(br);
		if(typ == 0) Read(bx), T.gai_da(bl,br,bx);
		if(typ == 1) WriteL(T.qiu(bl,br));
	}
	return 0;
}
```
