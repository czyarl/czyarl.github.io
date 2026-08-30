---
title: "Pollard's rho 学习笔记"
description: "从生日悖论和 Floyd 判环理解 Pollard's rho，并记录实现演进与常见优化。"
date: 2019-10-18T22:53:00+08:00
lastmod: 2021-03-05T16:14:00+08:00
slug: pollards-rho-notes
tags:
  - algorithms
  - number-theory
  - notes
featured: false
legacy: true
math: true
originalId: 11701276
originalURL: https://www.cnblogs.com/czyarl/p/11701276.html
---

开坑时间：2019.10.18周五

完善时间：2019.11.16周六

# 学习原因及其他

没什么原因，就是想学。有可能是因为今天在机房，csl到处问Pollard's rho怎么写，我随即发现自己不会，决定去学习。

# 2019-10-18

## 入门

入门，初步学习：[xyx的博客](https://blog.csdn.net/qq_39972971/article/details/82346390)

初步了解Pollard's rho的过程。认识到它的本质以及大致过程。

* 要分解$N$

* 伪随机生成数列$A=\{a_1,a_2,a_3,...\}$，每一项由前一项用固定方式推得。常用方式为$a_i=f(a_{i-1})=(a_{i-1}^2+C)mod\,N$其中$C$为一不变常数。

* 每次查看$gcd(a_{2i}-a_i,N)$，若不为1，说明此时找到了一个约数$gcd(a_{2i}-a_i,N)$。若此时$gcd\neq N$，说明我们确实找到了一个非平凡约数。但如果$gcd=N$，就没有找下去的必要了。

* 这实际上是找到了循环节。即，如果最终我们有一个因数$P$，那么$a_i\,mod\,P$实际是有循环节的。当$gcd\neq 1$是，我们发现$a_{2i}$与$a_i$实际上就到了循环节上一个相同的位置。

* 如果此时$gcd=N$，就说明$a_{2i}$与$a_i$也到了$mod\,N$循环节上的同一位置。这就说明不行了，我们要换一个$C$。

* 我们假设要经过$Q$步进入循环节，循环节长$R$步，那么$a_{2i}$与$a_{i}$要对应上循环节同一点，所需时间是$O(Q+R)$的。

* 所以这个算法的关键就是期望多少次，$a_i\,mod\,P$会冲突。生日悖论告诉我们是$O(\sqrt{P})$即$O(N^{\frac{1}{4}})$

## 生日悖论

进一步学习：关于生日悖论发现一篇文章：[一篇文章](https://www.docin.com/p-1458794321.html)

这篇文章关于生日悖论讲了一些。可以帮助理解为什么会在很快的时间内成功，但是没有证明期望。

## 关于名字

发现了为什么要叫Pollard's rho：因为循环节这东西长得很像$\rho$

## 关于$a_{2i}-a_i$

这东西实际上就是Floyd的找环算法。

# 2019-10-21

## 代码1

```c
LL PR_zuo(LL cn,LL a)
{
	LL lin1 = 2, lin2 = get_ne(lin1,a,cn), lin3;
	while(1)
	{
		lin3 = gcd((lin2-lin1+cn)%cn, cn);
		if(lin3 != 1) return lin3 == cn ? 0 : lin3;
		lin1 = get_ne(lin1,a,cn); lin2 = get_ne(get_ne(lin2,a,cn),a,cn);
	}
}
LL Pollard_rho(LL cn)
{
	if(cn == 1) return 1;
	if(!(cn&1)) return 2;
	if(Miller_Rabin(cn)) return cn;
	LL a = 4, lin;
	while(1) {if(lin = PR_zuo(cn,a)) return lin; a += 3; }
}
```

这份代码时间复杂度$O(N^{\frac{1}{4}}\alpha(N))$ ，其中$\alpha(N)$表示求$O(N)$大小的两个数的gcd的时间复杂度。

## 代码2

```c
LL PR_zuo(LL cn,LL a)
{
	LL lin1 = 2, lin2 = get_ne(lin1,a,cn), lin3;
	int B = 100;
	while(1)
	{
		LL lin = 1, lin4 = lin1, lin5 = lin2;
		for(int i = 1;i<=B;i++)
		{
			lin = ksc(lin,(lin5-lin4+cn)%cn,cn);
			lin4 = get_ne(lin4,a,cn); lin5 = get_ne(get_ne(lin5,a,cn),a,cn);
		}
		lin3 = gcd(lin,cn);
		if(lin3 != 1) {if(lin3 != cn) return lin3; break; }
		lin1 = lin4; lin2 = lin5;
	}
	while(1)
	{
		lin3 = gcd((lin2-lin1+cn)%cn, cn);
		if(lin3 != 1) return lin3 == cn ? 0 : lin3;
		lin1 = get_ne(lin1,a,cn); lin2 = get_ne(get_ne(lin2,a,cn),a,cn);
	}
}
LL Pollard_rho(LL cn)
{
	if(cn == 1) return 1;
	if(!(cn&1)) return 2;
	if(Miller_Rabin(cn)) return cn;
	LL a = 4, lin;
	while(1) {if(lin = PR_zuo(cn,a)) return lin; a += 3; }
}
```

这份代码是$O(N^{\frac{1}{4}}+\frac{N^{\frac{1}{4}}}{B}\alpha(N)+B\alpha(N))$，$B$是一个选定的常数。

但是我这一份慢得很，不知道为什么。正在努力卡常。

# 2019-10-27

一个最新进展：我发现$a$初值选得好，会让程序效率有一定的提升（大概20%）

13是一个不错的选择。

# 2019-11-16

今天CSP复赛Day1，下午不太想写题，所以就开始卡常。

1. 快速乘不要用倍增，直接用__int128(没有c++11，手写也比倍增快。)
2. 取模要科学，不要动不动取模。那份优化版（就是加了$B$）的，就是因为这两件事才特别慢的。
3. 快速乘就是（哔——）（哔——），一开始取模写错了，就很难受。直接让我死循环。


## 代码——终极版

```c
#include<bits/stdc++.h>
#define LL long long
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
const int MAXPRI = 6;
const int pri[] = {2,61,3,13,17,23};
//inline LL ksc(LL cn,LL cm,LL MOD) {cn%=MOD; cm%=MOD; LL ans = 0; while(cm) ans = ans + ((cm&1) ? cn : 0), cn = cn+cn, cm>>=1, ans = ((ans>=MOD)?(ans-MOD):ans), cn = ((cn>=MOD)?(cn-MOD):cn); return ans; }
inline LL ksc(__int128 cn,__int128 cm,LL MOD) {return cn*cm%MOD; }
LL ksm(LL cn,LL cm,LL MOD) {LL ans = 1; while(cm) ans = ksc(ans,1+(cn-1)*(cm&1),MOD), cn = ksc(cn,cn,MOD), cm>>=1; return ans; }
LL gcd(LL cn,LL cm) {return cm ? gcd(cm,cn%cm) : cn; }
int MR_jian(LL cn, int cm, LL a, LL N)
{
	a = ksm(a, cn, N);
	if(a == 1 || a == N-1) return 1;
	while(cm--)
	{
		a = ksc(a,a,N);
		if(a == 0 || a == 1) return 0;
		if(a == N-1) return 1;
	}
	return 0;
}
int Miller_Rabin(LL cn)
{
	if(cn == 2) return 1;
	if(cn == 0 || cn == 1 || (!(cn&1))) return 0;
	LL wei = 0, cm = cn-1, cx;
	while(!(cm&1)) wei++, cm>>=1;
	for(int i = 0;i<MAXPRI;i++) if(pri[i] == cn) return 1;
	for(int i = 0;i<MAXPRI;i++) if(!MR_jian(cm,wei,pri[i],cn)) return 0;
	return 1;
}
inline LL get_ne(LL cn,LL N,LL a) {return (ksc(cn,cn,N) + a)%N; }
LL Pollard_rho(LL cn)
{
	if(!(cn&1)) return 2;
	LL a = 13;
	int b = 100;
	while(1)
	{
		LL lin1 = 2, lin2 = get_ne(lin1,cn,a);
		while(1)
		{
			LL bx = lin1, by = lin2;
			LL lei = 1;
			for(int i = 1;i<=b;i++) lei = ksc(lei,bx-by+cn,cn), bx = get_ne(bx,cn,a), by = get_ne(get_ne(by,cn,a),cn,a);
			LL lin = gcd(lei,cn);
			if(lin != 1){
				for(int i = 1;i<=b;i++)
				{
					lin = gcd(lin1-lin2+cn,cn);
					if(lin == cn) break;
					if(lin != 1) return lin;
					lin1 = get_ne(lin1,cn,a); lin2 = get_ne(get_ne(lin2,cn,a),cn,a);
				}
				break;
			}
			lin1 = bx; lin2 = by;
		}
		a += 23;
	}
}
LL n,t;
int shi1,shi2,kai;
LL get_zuida(LL cn)
{
	if(Miller_Rabin(cn)) return cn;
	LL cm = Pollard_rho(cn);
	return max(get_zuida(cm), get_zuida(cn/cm));
}
void zuo()
{
	Read(n);
	if(Miller_Rabin(n)) {puts("Prime"); return; }
	Write(get_zuida(n)); puts("");
}
int main() {Read(t); while(t--) zuo(); return 0; }

```
