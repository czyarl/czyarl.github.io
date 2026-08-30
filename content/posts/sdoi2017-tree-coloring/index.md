---
title: "SDOI 2017「树点涂色」题解"
description: "把颜色段转化为父子差分，用 LCT 与线段树维护根路径染色及查询。"
date: 2020-10-23T08:29:00+08:00
lastmod: 2020-10-23T08:29:00+08:00
slug: sdoi2017-tree-coloring
tags:
  - algorithms
  - data-structures
  - problem-solution
featured: false
legacy: true
math: true
originalId: 13862052
originalURL: https://www.cnblogs.com/czyarl/p/13862052.html
---

# 链接

[LOJ2001](https://loj.ac/problem/2001)
[LuoguP3703](https://www.luogu.com.cn/problem/P3703)

# 题解

* 考虑每次修改都是从一个点到根的路径上修改，并且是染上一种全新的颜色，这意味着每一条路径上的相同颜色的点是连在一起的。
* 我们受到启发，可以记录$a_i$表示每个点和父亲颜色是否相同，相同为0，不同为1。（我们认为$a_{root}=1$）。我们可以发现一个点到根的路径的颜色数就是他到根的路径的每个点的$a_i$之和。
* 我们已经可以做两种询问了，现在需要快速修改。
* 我们发现可以用类似LCT的过程来处理操作1。即，我们把一个点和他自己颜色相同的孩子视作重儿子，每次操作相当于把这个点到根的路径上要修改的点以前的重儿子断掉，并连上新的。
* 我们可以直接用阉割版LCT来维护，也可以用树链剖分。
* 注意到我们的LCT的access是有改动的：我们要改的实际上是splay的根深度恰好多一的那个点，他不一定是根root的右儿子，我们需要用一个类似findroot的操作：从右儿子开始，使劲往左跳，跳不动意味着我们到了目标节点tar。会有人认为这个过程使得复杂度不对，但是实际上你可以先splay(tar)保证复杂度，再splay(root)保证正确性。只是实际上保证复杂度了之后常数会变大，反而变慢了。

# 代码

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 100100
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
void jia(int, int);
struct LCT{
	struct node{
		int ch[2], fa;
		void build() {ch[0] = ch[1] = fa = 0; }
	};
	node t[MAXN+1];
	int n;
	int isro(int cn) {return t[t[cn].fa].ch[0] != cn && t[t[cn].fa].ch[1] != cn; }
	void rotate(int cn)
	{
		int fa = t[cn].fa, zu = t[fa].fa, ch1 = t[fa].ch[1] == cn, ch2 = t[zu].ch[1] == fa, hai = t[cn].ch[ch1^1];
		if(!isro(fa)) t[zu].ch[ch2] = cn; t[cn].fa = zu;
		t[cn].ch[ch1^1] = fa; t[fa].fa = cn;
		t[fa].ch[ch1] = hai; t[hai].fa = fa;
	}
	void splay(int cn) {while(!isro(cn)) {if(!isro(t[cn].fa)) rotate(t[cn].fa); rotate(cn); } }
	void access(int cn)
	{
		for(int i = 0;cn;cn = t[i = cn].fa)
		{
			splay(cn);
			int lin = t[cn].ch[1];
			if(lin) {
				while(t[lin].ch[0]) lin = t[lin].ch[0];
				splay(lin); splay(cn);
				jia(lin, 1);
			}
			lin = (t[cn].ch[1] = i);
			if(lin) {
				while(t[lin].ch[0]) lin = t[lin].ch[0];
				splay(lin); splay(cn);
				jia(lin, -1);
			}
		}
	}
	void build(int cn, int a[]) {n = cn; for(int i = 1;i<=cn;i++) t[i].build(), t[i].fa = a[i]; t[0].build(); }
}T;
struct Seg{
	struct node{
		int p, da;
		void qing() {p = da = 0; }
		void zeng(int cn) {p += cn; da += cn; }
	};
	node t[MAXN*4+1];
	int n;
	void build(int cn, int l, int r)
	{
		t[cn].qing(); if(l == r) return;
		int zh = (l+r)>>1; build(cn<<1,l,zh); build((cn<<1)|1,zh+1,r);
	}
	void jia(int cn, int cl, int cr, int cm, int l, int r)
	{
		if(cl <= l && r <= cr) {t[cn].zeng(cm); return; }
		tui(cn); int zh = (l+r)>>1;
		if(cl <= zh) jia(cn<<1,cl,cr,cm,l,zh);
		if(cr >  zh) jia((cn<<1)|1,cl,cr,cm,zh+1,r);
		update(cn);
	}
	int qiu(int cn, int cl, int cr, int l, int r)
	{
		if(cl <= l && r <= cr) return t[cn].da;
		int zh = (l+r)>>1, guo = 0; tui(cn);
		if(cl <= zh) guo = qiu(cn<<1,cl,cr,l,zh);
		if(cr >  zh) Max(guo, qiu((cn<<1)|1,cl,cr,zh+1,r));
		return guo;
	}
	void tui(int cn) {t[cn<<1].zeng(t[cn].p); t[(cn<<1)|1].zeng(t[cn].p); t[cn].p = 0; }
	void update(int cn) {t[cn].da = max(t[cn<<1].da, t[(cn<<1)|1].da); }
	void jia(int cl, int cr, int cm) {jia(1,cl,cr,cm,1,n); }
	int qiu(int cl, int cr) {return qiu(1,cl,cr,1,n); }
	int qiu(int cn) {return qiu(1,cn,cn,1,n); }
	void build(int cn) {n = cn; build(1,1,n); }
}S;
struct qwe{
	int a,b,ne;
	void mk(int cn, int cm, int cx) {a = cn; b = cm; ne = cx; }
};
qwe a[MAXN*2+1];
int alen;
int head[MAXN+1];
int n, q;
namespace Get_lca{
	int dfn[MAXN+1], lie[MAXN*2+1], shi;
	int shen[MAXN+1];
	int ST[MAXN*2+1][20], erw[MAXN*2+1];
	int mins(int cn, int cm) {return shen[cn] < shen[cm] ? cn : cm; }
	void dfs(int cn, int fa)
	{
		lie[dfn[cn] = ++shi] = cn;
		for(int i = head[cn];i;i = a[i].ne)
		{
			int y = a[i].b;
			if(y == fa) continue;
			shen[y] = shen[cn]+1;
			dfs(y, cn); lie[++shi] = cn;
		}
	}
	void mk_ST(int cn)
	{
		erw[0] = -1;
		for(int i = 1;i<=cn;i++) erw[i] = erw[i>>1]+1;
		for(int i = 1;i<=cn;i++) ST[i][0] = lie[i];
		for(int i = 1;i<=erw[cn];i++)
		{
			int lin = cn-(1<<i)+1;
			for(int j = 1;j<=lin;j++) ST[j][i] = mins(ST[j][i-1], ST[j+(1<<(i-1))][i-1]);
		}
	}
	int qiu_lca(int cn, int cm)
	{
		cn = dfn[cn]; cm = dfn[cm];
		if(cn > cm) swap(cn, cm); int lin = erw[cm-cn+1];
		return mins(ST[cn][lin], ST[cm-(1<<lin)+1][lin]);
	}
	void yuchu() {shi = 0; shen[0] = shen[1] = 0; dfs(1, 0); mk_ST(shi); }
};
using Get_lca::qiu_lca;
int dfn[MAXN+1], lef[MAXN+1], fa[MAXN+1], shi;
void jia(int cn, int cm) {S.jia(dfn[cn], lef[cn], cm); }
void get_dfn(int cn)
{
	dfn[cn] = ++shi;
	for(int i = head[cn];i;i = a[i].ne) if(a[i].b != fa[cn]) fa[a[i].b] = cn, get_dfn(a[i].b);
	lef[cn] = shi;
}
void lian(int cn, int cm) {a[++alen].mk(cn,cm,head[cn]); head[cn] = alen; }
int main()
{
//	freopen("paint1.in","r",stdin);
//	freopen("paint.out","w",stdout);
	Read(n); Read(q);
	alen = 0; memset(head,0,sizeof(head));
	for(int i = 2;i<=n;i++) {int bx,by; Read(bx); Read(by); lian(bx,by); lian(by,bx); }
	shi = 0; fa[1] = 0; get_dfn(1); Get_lca::yuchu();
	T.build(n, fa); S.build(n);
	for(int i = 1;i<=n;i++) jia(i, 1);
	for(int i = 1;i<=q;i++)
	{
		int btyp, bx, by; Read(btyp);
		if(btyp == 1) {Read(bx); T.access(bx); }
		if(btyp == 2) {Read(bx); Read(by); WriteL(S.qiu(dfn[bx]) + S.qiu(dfn[by]) - 2*S.qiu(dfn[qiu_lca(bx,by)])+1); }
		if(btyp == 3) {Read(bx); WriteL(S.qiu(dfn[bx], lef[bx])); }
	}
	return 0;
}
```
