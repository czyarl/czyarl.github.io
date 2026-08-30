---
title: "ICPC World Finals 2015「Tile Cutting」题解"
description: "将平行四边形面积计数转化为约数函数卷积，并使用 NTT 求解。"
date: 2020-11-18T14:15:00+08:00
lastmod: 2020-11-18T14:15:00+08:00
slug: icpc-wf-2015-tile-cutting
tags:
  - algorithms
  - combinatorics
  - polynomials
  - problem-solution
featured: false
legacy: true
math: true
originalId: 13999541
originalURL: https://www.cnblogs.com/czyarl/p/13999541.html
---

# 链接

[Codeforces Gym 101239](https://codeforces.com/gym/101239)

# 题解

* 考虑平行四边形的一条对角线把整个矩形分为两个直角梯形。考察其中一个梯形中被选择的面积并将其乘二即为平行四边形面积。
* 记上底a，高分为两段b和c，下底d。
* 发现推出的平行四边形面积为ac+bd。
* 推理发现任意一组正整数a,b,c,d只要满足ac+bd=x就是合法的。
* 记$f(x)$表示面积为x的方案数，记$\sigma(x)$表示x的约数个数。我们有$f(x)=\sum_{i=1}^{x}\sigma(i)\sigma(x-i)$。
* 直接ntt维护即可。

# 代码

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 501000
#define MOD 998244353
#define YG 3
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
const int MAXNTT = MAXN*4+1;
int Mn;
int omg[MAXNTT], inv[MAXNTT], fan[MAXNTT];
LL ksm(LL cn, LL cm) {LL ans = 1; while(cm) ans = ans*(1+(cn-1)*(cm&1))%MOD, cn = cn*cn%MOD, cm>>=1; return ans; }
struct Poly{
	int a[MAXNTT], n;
	void clear() {n = 0; }
	void qing(int cn) {for(int i = n;i<cn;i++) a[i] = 0; }
	void do_ntt(int n, int omg[])
	{
		for(int i = 0;i<n;i++) if(fan[i] > i) swap(a[i], a[fan[i]]);
		for(int i = 2, m = 1;i<=n;i = (m = i)<<1)
		for(int j = 0;j<n;j+=i)
		for(int k = 0;k<m;k++)
		{
			int lin1 = a[j+k], lin2 = 1ll*a[j+k+m]*omg[Mn/i*k]%MOD;
			a[j+k] = (lin1+lin2>=MOD ? lin1+lin2-MOD : lin1+lin2);
			a[j+k+m] = (lin1-lin2<0 ? lin1-lin2+MOD : lin1-lin2);
		}
	}
	void ntt(int cn) {qing(cn); do_ntt(cn, omg); }
	void intt(int cn) {do_ntt(cn, inv); int lin = ksm(cn, MOD-2); for(int i = 0;i<cn;i++) a[i] = 1ll*a[i]*lin%MOD; }
};
int erwei(int cn) {int guo = 0; while(cn) guo++, cn>>=1; return guo; }
void yuchu_omg(int cn)
{
	Mn = 1<<erwei(cn*2);
	omg[0] = inv[0] = 1;
	omg[1] = ksm(YG, MOD/Mn); inv[1] = ksm(omg[1], MOD-2);
	for(int i = 2;i<Mn;i++) omg[i] = 1ll*omg[i-1]*omg[1]%MOD, inv[i] = 1ll*inv[i-1]*inv[1]%MOD;
	fan[0] = 0; int lin = erwei(Mn)-2;
	for(int i = 1;i<Mn;i++) fan[i] = (fan[i>>1]>>1) | ((i&1)<<lin);
}
Poly A;
int ST[MAXN+1][20], erw[MAXN+1];
int ssh[MAXN+1], pri[MAXN+1], xiao[MAXN+1], tuo[MAXN+1], plen;
int q, n;
void get_tuo()
{
	memset(ssh,0,sizeof(ssh)); plen = 0; ssh[1] = 1;
	tuo[1] = 1; tuo[0] = 0;
	for(int i = 2;i<=n;i++)
	{
		if(!ssh[i]) {
			pri[++plen] = i;
			for(LL j = i, k = 2;j<=n;j = j*i, k++) xiao[j] = plen, ssh[j] = 1, tuo[j] = k;
			ssh[i] = 0;
		}
		for(int j = 1;1ll*pri[j]*i<=n && j<xiao[i];j++)
		{
			for(LL k = pri[j]*i, ij = 2;k<=n;k = k*pri[j], ij++) xiao[k] = j, ssh[k] = 1, tuo[k] = tuo[i]*ij;
		}
	}
}
void get_A()
{
	yuchu_omg(n);
	for(int i = 0;i<=n;i++) A.a[i] = tuo[i]; A.n = n+1;
	A.ntt(Mn);
	for(int i = 0;i<Mn;i++) A.a[i] = 1ll*A.a[i]*A.a[i]%MOD;
	A.intt(Mn);
}
int maxs(int cn, int cm) {return A.a[cn] != A.a[cm] ? (A.a[cn] < A.a[cm] ? cm : cn) : min(cn,cm); }
void get_ST()
{
	erw[0] = -1;
	for(int i = 1;i<=n;i++) erw[i] = erw[i>>1]+1;
	for(int i = 1;i<=n;i++) ST[i][0] = i;
	for(int i = 1;i<=erw[n];i++)
	{
		int lin = n-(1<<i)+1;
		for(int j = 1;j<=lin;j++) ST[j][i] = maxs(ST[j][i-1], ST[j+(1<<(i-1))][i-1]);
	}
}
void zuo()
{
	int cl,cr; Read(cl); Read(cr);
	int lin = erw[cr-cl+1];
	int ans = maxs(ST[cl][lin], ST[cr-(1<<lin)+1][lin]);
	WriteS(ans); WriteL(A.a[ans]);
}
int main()
{
//	freopen(".in","r",stdin);
//	freopen(".out","w",stdout);
	n = MAXN; get_tuo(); get_A(); get_ST();
	Read(q); while(q--) zuo();
	return 0;
}
```
