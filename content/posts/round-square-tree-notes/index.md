---
title: "圆方树学习笔记"
description: "从仙人掌判定到圆方树建模，整理常见构造方式和若干题目实现。"
date: 2020-06-06T15:53:00+08:00
lastmod: 2020-06-07T18:21:00+08:00
slug: round-square-tree-notes
tags:
  - algorithms
  - data-structures
  - graph-theory
  - notes
featured: false
legacy: true
math: true
originalId: 13055003
originalURL: https://www.cnblogs.com/czyarl/p/13055003.html
---

# 背景

这实在是一个惊人的事情，我马上就要去JSOI了，但是竟然没写过圆方树。事情有点大。

所以，我就来学了一下，发现这玩意儿挺好写的，就是对于代码习惯的要求有点高，一不小心就会写错。

# 参考博客

[粉兔的博客](https://www.cnblogs.com/PinkRabbit/p/10446473.html)

他这里面讲得十分详细。

# 仙人掌的判定

这是无向图的判定。

这个东西，你可以随便找一个ZJOI2017仙人掌交一下看看自己有没有写对。

## 树形dp的做法

* 我们先把dfs树跑出来，然后对于每条非树边连接的两个点的简单路径做一下路径覆盖，如果每条路都最多被覆盖一次，就是没问题的。
* 注意到这是dfs树，所有非树边都是连接祖先和后代的，所以路径覆盖十分方便。

## 魔改tarjan

我本来以为上一个做法只能比较方便地$O(n\log n)$（我没意识到那是dfs树），所以才研究的这个。现在这个基本上没用了。

* 我们记一个环中最早被遍历的点为这个环的根。
* 我们记$g_i$表示$i$点所在的 不是以$i$为根的环 的根。如果没有这样的环，就为0。（比较轻易地发现他只会有一种取值）
* 我们记$fa_i$表示$i$点在dfs树上的父亲。
* 我们给从$i$号点连出去的边分一下类（记目标点为$v$)：
  * 父亲边：$v$被遍历过，且$v$为$i$在dfs树上的父亲。$v=fa_i$
  * 新环边：$v$没有被遍历过，且遍历完之后$dfn[i]\leq low[v]$
  * 旧环边：$v$被遍历过，且$g_v=i$
  * 环内边：$v$没有被遍历过，且遍历完之后$dfn[i] > low[v]$
  * 返祖边：$v$被遍历过，且$v$为$i$在dfs树上的非父亲祖先。$g_v\neq i,fa_i \neq v$
* 性质：（去除重边）
  * 性质1：一个点连出去的边中，环内边和返祖边的总数不会超过1。
  * 性质2：如果有环内边连向$v$，那么$g_i=g_v$。
  * 性质3：如果有返祖边连向$v$，那么$g_i=v$。
* 直接在跑tarjan的时候维护这个就行了。
* 时空复杂度都是$O(n)$的。

代码参见[ZJOI2017仙人掌](https://www.cnblogs.com/czyarl/p/13061106.html)

# 做了几道题

没写博客的我就贴一下代码。

[LuoguP5236 【模板】静态仙人掌](https://www.luogu.com.cn/problem/P5236)

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 20000
using namespace std;
template<typename T>void Read(T &cn)
{
	char c;int sig = 1;
	while(!isdigit(c = getchar()))if(c == '-')sig = -1; cn = c-48;
	while(isdigit(c = getchar()))cn = cn*10+c-48; cn*=sig;
}
template<typename T>void Write(T cn)
{
	if(cn < 0) {putchar('-'); cn = 0-cn; }
	int wei = 0; T cm = 0; int cx = cn%10; cn/=10;
	while(cn)cm = cm*10+cn%10,cn/=10,wei++;
	while(wei--)putchar(cm%10+48),cm/=10;
	putchar(cx+48);
}
template<typename T>void Min(T &cn, T cm) {cn = cn < cm ? cn : cm; }
struct Tree{
	struct qwe{
		int a,b,ne,w;
		void mk(int cn, int cm, int cx, int cy) {a = cn; b = cm; ne = cx; w = cy; }
	};
	qwe a[MAXN*4+1];
	int alen;
	int head[MAXN*2+1];
	void lian(int cn, int cm, int cx) {a[++alen].mk(cn, cm, head[cn], cx); head[cn] = alen; }
	void lian_d(int cn, int cm, int cx) {lian(cn, cm, cx); lian(cm, cn, cx); }
	void build() {alen = 0; memset(head,0,sizeof(head)); }
}T1, T2;
int n, m, yan, q;
int dfn[MAXN+1], low[MAXN+1], zhan[MAXN+1], zlen, shi;
int jus[MAXN+1];

int juf[MAXN*2+1], bian[MAXN*2+1], fa[MAXN*2+1];
int shen[MAXN*2+1], shen2[MAXN*2+1]; //shen for jump; shen2 for cal
int ST_f[MAXN*2+1][22], ST[MAXN*2+1][22];
int qi[MAXN*2+1], lef[MAXN*2+1], lie[MAXN*4+1];
int erw[MAXN*4+1];
int erwei(int cn) {int guo = -1; while(cn) guo++, cn>>=1; return guo; }
int tarjan(int cn, int ba)
{
	int guo = 0;
	dfn[cn] = low[cn] = ++shi; zhan[++zlen] = cn;
	for(int i = T1.head[cn];i;i = T1.a[i].ne)
	{
		int y = T1.a[i].b;
		if(y == ba) continue;
		if(dfn[y]) Min(low[cn], dfn[y]), guo = T1.a[i].w;
		else {
			int lin = zlen; jus[y] = T1.a[i].w;
			int lin2 = tarjan(y, cn); Min(low[cn], low[y]);
			if(low[y] >= dfn[cn]) {
				yan++; int ge = 0;
				for(int j = lin+1;j<=zlen;j++) T2.lian_d(yan, zhan[j], 0), ge += jus[zhan[j]], bian[zhan[j]] = ge, fa[zhan[j]] = yan;
				if(lin+1 == zlen) ge += T1.a[i].w; else ge += lin2;
				T2.lian_d(yan, cn, 0); bian[yan] = ge; fa[yan] = cn; zlen = lin;
			}
			else guo = lin2;
		}
	}
	return guo;
}
void dfs1(int cn)
{
	lie[qi[cn] = ++shi] = cn;
	for(int i = T2.head[cn];i;i = T2.a[i].ne)
	{
		int y = T2.a[i].b;
		if(y == fa[cn]) continue;
		shen[y] = shen[cn]+1;
		shen2[y] = shen2[cn] + juf[y];
		dfs1(y);
		lie[++shi] = cn;
	}
	lef[cn] = shi;
}
int xiao(int cn, int cm) {return shen[cn] < shen[cm] ? cn : cm; }
void mk_ST(int cn)
{
	for(int i = 1;i<=cn;i++) erw[i] = erwei(i);
	for(int i = 1;i<=yan;i++) ST_f[i][0] = fa[i];
	for(int i = 1;i<=erw[yan];i++) for(int j = 1;j<=yan;j++) ST_f[j][i] = ST_f[ST_f[j][i-1]][i-1];
	for(int i = 1;i<=cn;i++) ST[i][0] = lie[i];
	for(int i = 1;i<=erw[cn];i++)
	{
		int lin = cn - (1<<i)+1;
		for(int j = 1;j<=lin;j++) ST[j][i] = xiao(ST[j][i-1], ST[j+(1<<(i-1))][i-1]);
	}
}
int qiu_lca(int cn, int cm)
{
	cn = qi[cn]; cm = qi[cm];
	if(cn > cm) swap(cn, cm); int lin = erw[cm-cn+1];
	return xiao(ST[cn][lin], ST[cm-(1<<lin)+1][lin]);
}
int tiao(int cn, int cm) {for(int i = erw[yan];i>=0;i--) if(cm&(1<<i)) cn = ST_f[cn][i]; return cn; }
int qiu_jl(int cn, int cm)
{
	int lin = qiu_lca(cn, cm);
	if(lin <= n) return shen2[cn]+shen2[cm]-2*shen2[lin];
	int cx = tiao(cn, shen[cn]-shen[lin]-1), cy = tiao(cm, shen[cm]-shen[lin]-1);
	return min(shen2[cn]+shen2[cm]-2*shen2[lin], shen2[cn]+shen2[cm]-shen2[cx]-shen2[cy]+abs(bian[cx]- bian[cy]));
}
int main()
{
	Read(n); Read(m); Read(q); T1.build(); T2.build();
	for(int i = 1;i<=m;i++) {int bx,by,bz; Read(bx); Read(by); Read(bz); T1.lian_d(bx,by,bz); }

	shi = zlen = 0; yan = n; memset(fa,0,sizeof(fa));
	for(int i = 1;i<=n;i++) if(!dfn[i]) tarjan(i, 0);
	for(int i = 1;i<=n;i++) if(fa[i]) juf[i] = min(bian[i], bian[fa[i]]-bian[i]);
	for(int i = n+1;i<=yan;i++) juf[i] = 0;
	shi = 0; memset(shen,0,sizeof(shen));
	for(int i = 1;i<=yan;i++) if(!qi[i]) dfs1(i);
	mk_ST(shi);
	for(int i = 1;i<=q;i++)
	{
		int bx,by; Read(bx); Read(by);
		Write(qiu_jl(bx, by)); puts("");
	}
	return 0;
}
```

[LOJ 2587 铁人两项](https://loj.ac/problem/2587)

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 100100
using namespace std;
template<typename T>void Read(T &cn)
{
	char c; int sig = 1;
	while(!isdigit(c = getchar())) if(c == '-') sig = -1; cn = c-48;
	while(isdigit(c = getchar())) cn = cn*10+c-48; cn*=sig;
}
template<typename T>void Write(T cn)
{
	if(cn < 0) {putchar('-'); cn = 0-cn; }
	int wei = 0; T cm = 0; int cx = cn%10; cn/=10;
	while(cn) wei++, cm = cm*10+cn%10, cn/=10;
	while(wei--) putchar(cm%10+48), cm /= 10;
	putchar(cx+48);
}
template<typename T>void Max(T &cn, T cm) {cn = cn < cm ? cm : cn; }
template<typename T>void Min(T &cn, T cm) {cn = cn < cm ? cn : cm; }
struct Tree{
	struct qwe{
		int a,b,ne;
		void mk(int cn, int cm, int cx) {a = cn; b = cm; ne = cx; }
	};
	qwe a[MAXN*4+1];
	int alen;
	int head[MAXN*2+1];
	void build() {alen = 0; memset(head,0,sizeof(head)); }
	void lian(int cn, int cm) {a[++alen].mk(cn, cm, head[cn]); head[cn] = alen; }
	void lian_d(int cn, int cm) {lian(cn, cm); lian(cm, cn);}
}T1, T2;
int n, m, yan;
int dfn[MAXN+1], low[MAXN+1], shi;
int zhan[MAXN+1], zlen;
int siz[MAXN*2+1], zhi[MAXN*2+1];
int zong;
LL ans;
void tarjan(int cn)
{
	zong++;
	zhan[++zlen] = cn;
	dfn[cn] = low[cn] = ++shi;
	for(int i = T1.head[cn];i;i = T1.a[i].ne)
	{
		int y = T1.a[i].b;
		if(dfn[y]) Min(low[cn], dfn[y]);
		else {
			int lin = zlen;
			tarjan(y);
			Min(low[cn], low[y]);
			if(low[y] >= dfn[cn]) {
//				printf("cn = %d y = %d\n",cn,y);
				yan++; int ge = 0;
				while(zlen != lin) zhi[zhan[zlen]] = -1, ge++, T2.lian_d(yan, zhan[zlen]), zlen--;
				T2.lian_d(yan, cn); zhi[cn] = -1; ge++;
//				printf("yan = %d ge = %d\n",yan,ge);
				zhi[yan] = ge;
			}
		}
	}
}
void dfs(int cn, int fa)
{
	if(zhi[cn] < 0) siz[cn] = 1; else siz[cn] = 0;
	LL ge = 0;
	for(int i = T2.head[cn];i;i = T2.a[i].ne)
	{
		int y = T2.a[i].b;
		if(y == fa) continue;
		dfs(y, cn);
		ge = ge + 2ll*siz[y]*siz[cn];
		siz[cn] += siz[y];
	}
	ge = ge + 2ll*(zong-siz[cn])*siz[cn];
//	printf("tj dfs : cn = %d fa = %d ge = %lld zhi = %d\n",cn,fa,ge,zhi[cn]);
	ans = ans + ge*zhi[cn];
}
void tongji(int cn) {siz[0] = 0; dfs(cn, 0); }
int main()
{
//	freopen(".in","r",stdin);
//	freopen(".out","w",stdout);
	Read(n); Read(m);
	T1.build(); T2.build();
	for(int i = 1;i<=m;i++) {int bx, by; Read(bx); Read(by); T1.lian_d(bx, by); }
	yan = n; shi = 0; ans = 0; for(int i = 1;i<=n;i++) if(!dfn[i]) zong = 0, tarjan(i), tongji(i);
	Write(ans); puts("");
	return 0;
}
```

[某校内训练题——圆方树行列式](https://www.cnblogs.com/czyarl/protected/p/13045525.html)

[ZJOI2017仙人掌](https://www.cnblogs.com/czyarl/p/13061106.html)

[HAOI2016地图](https://www.cnblogs.com/czyarl/p/13061274.html)

剩下的题，也没什么劲了。
