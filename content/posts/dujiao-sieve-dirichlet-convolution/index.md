---
title: "【学习笔记】【数论】杜教筛及狄利克雷卷积及一些怪东西"
description: "杜教筛、狄利克雷卷积与常见积性函数的一份旧学习笔记。"
date: 2019-09-21T21:56:00+08:00
lastmod: 2021-07-17T13:53:00+08:00
slug: dujiao-sieve-dirichlet-convolution
tags:
  - algorithms
  - number-theory
  - tutorial
featured: true
legacy: true
math: true
originalId: 11565041
originalURL: https://www.cnblogs.com/czyarl/p/11565041.html
---

其实比较建议大家去OI-wiki看这个。我这篇里面没什么多出的内容。可能杜教筛会更多一点。

这篇博客越看越没用，散了吧。

# 目录（假的，没有链接）
- 狄利克雷卷积基础知识
  * 数论函数
  * 狄利克雷卷积定义
  * 狄利克雷卷积性质
  * 常用卷积

- 卷积计算方法
  * 最暴力的暴力
  * 稍好的暴力
  * 优美的暴力

- 莫比乌斯反演（待填坑）

- 杜教筛
  * 经典杜教筛
  * 杜教筛应用
    - 杜教筛应用一
    - 杜教筛应用二
  * 杜教筛总结

# 背景

本人即将去CTS&APIO2019，由于一些特殊原因，发现自己数论突然变得很菜。

就决定在去的前一天，翻出来以前的数论学习资料看一看。翻到了czgj的校内狄利克雷卷积课件，发现其中提到了的任意数列$f(n)$和$g(n)$的狄利克雷卷积$(f*g)(n)$（从1到n，每一项都求出来）的$O(nlogn)$求法。然而我没有反应过来。

后来仔细想了想，发现了一个$O(nH(n))$的做法。很开心。

这里$H(n)$表示调和级数的第$n$项。$H(n)\approx ln(n)$。具体后文有介绍。

~~但是不知道他的log的底数是不是e。不管了，我的还算快的。~~

本文会提到一点狄利克雷卷积的基础知识，一个暴力的卷积及反演计算方法，以及一个显而易见，却十分优秀的快速卷积方法。
以及常用的三种杜教筛。

~~想写杜教筛，但是有点懒，还没写完。~~

update2019.7.9：现在写完杜教筛了，但是没写莫比乌斯反演

update2021.2.10：我有了关于狄利克雷卷积计算的新灵感，预计（没写完）增加一小部分。这部分反而应该是最独创的了吧（苦笑

# 狄利克雷卷积基础知识

为了记录一下我对于狄利克雷卷积的理解，也帮助大家复习一下，先介绍点基础知识。

## 数论函数

狄利克雷卷积是定义在数论函数上的，它是一个处理数论相关问题的有效工具。因此，为了对新人友善一点，也方便我日后复习，就在这里把数论函数相关也提一下。

### 定义

#### 数论函数

> 在数论上，算术函数（或称数论函数）指定义域为正整数、陪域为复数的函数，每个算术函数都可视为复数的序列。

通俗地说，数论函数与普通函数基本一样，只是涉及的取值是在正整数范围内而已。

#### 积性函数

对于一个数论函数$f(n)$，若$\forall(a,b)=1,f(ab)=f(a)f(b)$，我们就称$f$为积性函数。

就是说，如果a和b互质，那么对于积性函数$f(n)$，总有$f(ab)=f(a)f(b)$。

特别地，对于每一个积性函数，都有$f(1)=1$。

#### 完全积性函数
我们观察到，积性函数的定义里，$a$和$b$互质这个东西，一看就很烦。
如果对于数论函数$f(n)$，有$\forall a,b\quad f(ab)=f(a)f(b)$，则我们称$f(n)$为完全积性函数。
### 栗子
这只是几个常用栗子，更多栗子，请珂学上网，前往wiki（我写本文的时候刚到墙外）[某墙外网站_Multiplicative_function](https://en.wikipedia.org/wiki/Multiplicative_function)
#### 单位函数
$\epsilon(n)=\begin{cases}1&n=1\\0&n\ne1\end{cases}$
这是完全积性函数。
#### 幂函数
$id_k(n)=n^k$
$id_0(n)=1(n)=n^0=1$
$id_1(n)=id(n)=n$
都是完全积性函数。
#### 除数函数
$\sigma_k(n)=\sum\limits_{d\mid n}d^k$，即$n$的所有约数的$k$次方的和。
$\sigma_0(n)=d(n)=\sum\limits_{d\mid n}1$，即$n$的约数个数。
$\sigma_1(n)=\sigma(n)=\sum\limits_{d\mid n}d$，即$n$的约数和。
这是积性函数，但不是完全积性函数。
#### 欧拉函数
##### 定义式
$\varphi(n)=\sum\limits_{i=1}^{n-1}[(i,n)=1]$，即$1$到$(n-1)$中，与$n$互质的数的个数。
是个积性函数。
##### 另一个公式
$\varphi(n)=n\prod\limits_{p\mid n,p\,is\,a\,prime}(1-\frac{1}{p})$
这里$p$即为$n$的所有质因子。

证明：考虑对于$\varphi(n)$，其中$n=p^k$且$p$为质数，我们有$\varphi(n)=n-\frac{n}{p}=n(1-\frac{1}{p})$（所有的数，减去有 $p$作为质因子的数）。

由于$\varphi(n)$为积性函数，设$n=p_1^{k_1}p_2^{k_2}\cdots p_m^{k_m}$，（就是质因数分解）
（我不用$\prod$是因为个人觉得这种证明，还是展开来写更清晰）

我们有：
$$\begin{aligned}\varphi(n)=&\varphi(p_1^{k_1})\varphi(p_2^{k_2})\cdots \varphi(p_m^{k_m})\\=&\left(p_1^{k_1}p_2^{k_2}\cdots p_m^{k_m}\right)\left((1-\frac{1}{p_1})(1-\frac{1}{p_2})\cdots(1-\frac{1}{p_m})\right)\\=&n\prod\limits_{p\mid n,p\,is\,a\,prime}(1-\frac{1}{p})\end{aligned}$$

得证。
#### 莫比乌斯函数
设$n=p_1^{q_1}p_2^{q_2}p_3^{q_3}\cdots p_k^{q_k}$，其中$p$为$n$的质因子。
$\mu(n)=\begin{cases}1&n=1\\0&(\max\limits_{i=1}^{k}q_k)\geqslant2\\(-1)^k&otherwise\end{cases}$
这是积性函数。
## 狄利克雷卷积定义
对于两个数论函数$f(n),g(n)$，定义他们的狄利克雷卷积为
$h(n)=(f*g)(n)=\sum\limits_{d\mid n}f(d)g(\frac{n}{d})=\sum\limits_{ab=n}f(a)g(b)$

p.s.注意到$\sum\limits_{ab=n}f(a)g(b)$这个式子，它和一般的卷积$\sum\limits_{a+b=n}f(a)g(b)$长得非常像。
## 狄利克雷卷积基础性质
可以看到，有了这些性质，我们似乎就可以将其视为一个群了。
这些性质也使得我们在做题时更加方便。
### 交换律
$(f*g)(n)=(g*f)(n)$

证明：如果用$\sum\limits_{ab=n}f(a)g(b)$这个式子，就是显然的。
### 结合律
$(f*g)*h=f*(g*h)$

证明：考虑展开，~~易证~~。算了，我还是写一下吧。
$$\begin{aligned}((f*g)*h)(n)&=\sum\limits_{d_1d_2=n}(f*g)(d_1)\,h(d_2)\\&=\sum\limits_{d_1d_2=n}\left(\sum\limits_{d_3d_4=d_1}f(d_3)g(d_4)\right)h(d_2)\\&=\sum\limits_{d_3d_4d_2=n}f(d_3)g(d_4)h(d_2)\\&=\sum\limits_{d_1d_2d_3=n}f(d_1)g(d_2)h(d_3)\end{aligned}$$
那么，$f*(g*h)$也可以化成这种形式。

推论1：若是$(f_1*f_2*f_3*\cdots*f_k)(n)$，就可直接表示为$\sum\limits_{d_1d_2d_3\cdots d_k=n}f_1(d_1)f_2(d_2)f_3(d_3)\cdots f_k(d_k)$

推论2：我们可以对狄利克雷卷积进行类似快速幂的操作。~~姑且称之为快速卷吧。~~
### 对加法的分配律
$(f+g)*h=f*h+g*h$

证明：展开即可。
$$\begin{aligned}((f+g)*h)(n)&=\sum\limits_{ab=n}(f+g)(a)\,h(b)\\&=\sum\limits_{ab=n}\left(f(a)h(b)+g(a)h(b)\right)\\&=\sum\limits_{ab=n}f(a)h(b)+\sum\limits_{ab=n}g(a)h(b)\\&=f*h+g*h\end{aligned}$$
### 存在单位元
$f*\epsilon=\epsilon*f=f$

证明：考虑单位函数$\epsilon$的定义，这就是显然的。
### 关于积性
若$f,g$为积性函数，则$f*g$依旧为积性函数。

证明：
考虑，我们要证$(f*g)(n)=(f*g)(a)\,(f*g)(b)\quad\forall(a,b)=1,ab=n$。

对于左式：
$\begin{aligned}(f*g)(n)&=\sum\limits_{d\mid n}f(d)g(\frac{n}{d})\end{aligned}$
对于右式：
$\begin{aligned}(f*g)(a)(f*g)(b)&=\sum\limits_{d_1\mid a}f(d_1)g(\frac{a}{d_1})\sum\limits_{d_2\mid b}f(d_2)g(\frac{b}{d_2})&(1.1)\\&=\sum\limits_{d_1\mid a,d_2\mid b}f(d_1)f(d_2)g(\frac{a}{d_1})g(\frac{b}{d_2})&(1.2)\\&=\sum\limits_{d_1\mid a,d_2\mid b}f(d_1d_2)g(\frac{ab}{d_1d_2})&(1.3)\\&=\sum\limits_{d\mid n}f(d)g(\frac{n}{d})&(1.4)\end{aligned}$

注意到(1.2)可以化到(1.3)的原因是：$a$和$b$互质，所以$d_1$和$d_2$、$\frac{a}{d_1}$和$\frac{b}{d_2}$互质；而$f$和$g$又都是积性的。

## 常用卷积
- $\varphi*1=id$
即$\sum_{d|n}\varphi(d)=n$
我们可以在$[1,n]$这些数和枚举$n$的每一个约数$d$时，累加起的每一个与$d$互质的数中间建立一一对应关系。
  * $i$可以对应到在算与$\frac{n}{(n,i)}$互质的数时，累加起来的$\frac{i}{(n,i)}$
  * 在算与$n$的约数$d$互质的数的时候累加起的$j$，可对应到$j\cdot\frac{n}{d}$

- $\mu*1=\epsilon$
首先，当$n=1$时，显然成立
当$n>1$时，因为$\mu$和$1$都是积性函数，因此$\mu*1$也是积性函数。
同时，当$n$质因数分解后，有质因数的次数大于1，$\mu(n)$就会等于0。
所以我们只用证明当$n$为质数时，$\sum_{d|n}\mu(d)=0$就行了。
$\sum_{d|n}\mu(d)=\mu(1)+\mu(n)=1+(-1)^1=0$

- $id*1=\sigma\qquad1*1=d$（$id_k*1=\sigma_k$）
根据定义，显然成立

- 其他
比如$\varphi*d=\varphi*1*1=id*1=\sigma$

# 卷积计算方法
我可能会混用$f(i)$这种偏向函数的表述方式和$f_i$这种偏向数列的表述方式。他们是相同的含义，看得懂就好。~~好吧，我基本上没有这么用~~
我们先做出约定：现在我们给定序列$f_i$和$g_i$，下标从$1$到$n$。
现在，我们要求序列$h_i$，下标从$1$到$n$。其中$h(n)=\sum\limits_{d\mid n}f(d)g(\frac{n}{d})$
## 最暴力的暴力
我们考虑，可以直接对于每一个$i$，枚举所有小于$i$的正整数$j$，并判断$j$是否为$i$的约数。
如果是，就将他的贡献$f(j)g(\frac{i}{j})$加到$h(i)$上。

这个暴力一看就很丑，很明显，时间是$O(n^2)$的，很没用。我们考虑优化。
## 稍好的暴力
有一个从初学判单个素数时，就知道的结论：一个正整数$n$，只会有$O(\sqrt{n})$个约数。并且，约数几乎是成对出现的（除了完全平方数）。因此，每一对中较小的那个总是小于$\sqrt{n}$的。

我们大可对于每个$i$，只枚举1到$\sqrt{i}$这几个数，遇到一个约数$j$，就把这一对约数的贡献$f(j)g(\frac{i}{j})+f(\frac{i}{j})g(j)$加到$h(i)$上面（注意考虑当$j=\sqrt{i}$时，就只用加一个了）。

这样虽然还是很丑，但是已经做到了$O(n\sqrt{n})$的复杂度了。
## 优美的暴力
### 做法
我们考虑换一个方向，不从$i$去找能贡献$h(i)$，而是从$j$去找，$j$是哪些$i$的约数。
具体地，我们只要每一次加上$j$，就可以了。算贡献的时候，式子与最暴力的暴力相同。
### 复杂度分析
粗略一看，这个的时间很不对。好像，都要到$O(n^2)$了。但是，真的是这样的吗？
我们考虑，对于每一个$j$，在每一回都加上$j$的过程中，只用做$\left\lceil\frac{n}{j}\right\rceil$次。
因此，它的总时间复杂度就是：
$$\begin{aligned}\sum\limits_{i=1}^{n}\left\lceil\frac{n}{i}\right\rceil&\leqslant\sum\limits_{i=1}^{n}\left(\frac{n}{i}+1\right)\\&=n+n\sum\limits_{i=1}^{n}\frac{1}{i}\\&=n+nH(n)\end{aligned}$$
其中$H(n)$表示调和级数的第$n$项。

tip.调和级数
$H(n)=\sum\limits_{i=1}^{n}\frac{1}{i}=ln(n)+\gamma+\epsilon_n$
其中，$\gamma$表示欧拉-马歇罗尼常数，约为0.577，$\epsilon_n$约为$\frac{1}{2n}$。可以看到，这两者在OI数据范围下皆可忽略。
因此，$H(n)\approx ln\,n$。

这个方法已经十分优秀了，是$O(nH(n))$的。
### 一个毫无用处的讨论
话说我在想到这个算法之后，欣喜万分。
但是，我随即又口胡出了一个优化，而且，好像，加上这个优化后，会更快。

做法是这样的：
考虑到稍好的暴力，我们发现我们只要做前$\sqrt{n}$个。
那么这里，我们同样只用做前$\sqrt{n}$个。
具体的，就是在统计$j$作为约数的过程中，从$j^2$开始统计，以避免重复。
并使用稍好的暴力的式子进行计算贡献。

用类似之前的方法，复杂度分析出来，是这样的：$O(nH(\sqrt{n}))$
欸，好激动啊。
但是，对数里的那个根号，好像，只会让结果除以二欸。
然后我们再看，发现其实他的常数是又大了2的。
所以，我的这个优化并没有什么用。

这是可以理解的，因为对于原来的方法和现在的，他的每一步都没有浪费，每一遍循环都能恰好找到合法的转移。所以说，这个优化唯一的作用，大概就是类似循环展开的吧，而且只有2层。
### 最后的讨论
经过前面一个毫无用处的讨论，我决定再好好审视一下现在这个算法。
我发现，现在已经可以做到每一次的循环全部起到作用，不会再有循环到了一个$a$和$b$，却发现这是不合法的或者此前已经算过了。
也就是说，如果还是一个一个地从$f,g$算到$h$，是不会再有比这个更快的算法了。
那么，唯一的突破方案，就只有用类似杜教筛或者min25筛那样的方法，把一些信息并在一起了吧。
这个算法复杂度是$O(nH(n))$的，而且常数较小。已经挺接近O(n)了。
起码，五六百万还是可以轻松跑过的。

而且，我最后提出的那一个毫无用处的讨论，其实还是有点用的。
那样会好写一点，能少几个if语句。
### 代码
这个代码就是我依据我那个毫无意义的讨论得出的算法写出来的。
```c
#include<bits/stdc++.h>
#define LL long long
#define MOD 998244353
#define MAXN 5000000
using namespace std;
template<typename T>void Read(T &cn)
{
	char c;int sig = 1;
	while(!isdigit(c = getchar()))if(c == '-')sig = -1;cn = c-48;
	while(isdigit(c = getchar()))cn = cn*10+c-48;cn*=sig;
}
template<typename T>void Write(T cn)
{
	if(!cn){putchar('0');return;}
	if(cn<0){putchar('-');cn = 0-cn;}
	int wei = 0;T cm = 0;int cx = cn%10;cn=cn/10;
	while(cn)wei++,cm = cm*10+cn%10,cn=cn/10;
	while(wei--)putchar(cm%10+48),cm=cm/10;
	putchar(cx+48);
}
LL f[MAXN+1],g[MAXN+1],h[MAXN+1];
int n;
template<typename T>void getit(T a[],int n)
{
	for(int i = 1;i<=n;i++)Read(a[i]);
}
template<typename T>void ran_getit(T a[],int n)
{
	for(int i = 1;i<=n;i++)a[i] = i;
}
template<typename T>void outit(T a[],int n)
{
	for(int i = 1;i<=n;i++)
	{
		Write(a[i]);putchar(' ');
	}
	putchar('\n');
}
void juan_ji(LL f[],LL g[],LL h[],int n)
{
	memset(h,0,sizeof(h[0])*(n+1));
	int Sqr = sqrt(n);
	for(int i = 1;i<=Sqr;i++)
	{
		h[i*i] = (h[i*i] + f[i]*g[i]%MOD)%MOD;
		for(int j = i+1;j*i<=n;j++)
		{
			h[i*j] = (h[i*j] + f[i]*g[j]%MOD + f[j]*g[i]%MOD)%MOD;
		}
	}
}
int main()
{
	Read(n);
	getit(f,n);
	getit(g,n);
	juan_ji(f,g,h,n);
	outit(h,n);
	return 0;
}

```

## 狄利克雷前缀和

就是求 $F=G*1$ 。

咋求呢？直接看成高位前缀和就行了。复杂度是$O(n\ln \ln n)$。核心原因是$n$以内的素数有$O(\frac{n}{\ln n})$个。

好写得不得了。

## 例题
此处就给出一道题（来自czgj的那个课件）
给出一个序列$f(1)$到$f(n)$和$k$，定义$f_k(n)=\sum\limits_{d_1d_2\cdots d_k=n}f(d_1)f(d_2)\cdots f(d_n)$
求$f_k(1),f_k(2)\cdots f_k(n)$。

解：不难发现，这就是$f$序列$k$次卷积后的结果。那么，我们可以直接利用快速幂的方法以及上文介绍的卷积方法，就可以做到$O(nH(n)log_2k)$的复杂度，很好了。

## 结语
关于这个算法的思考告诉我了一件事——任何一个，哪怕是很辣鸡的算法，也都要定下心来，好好分析。或许，就有非常奇妙的事情发生。（莫名鸡汤）

# 莫比乌斯反演（待填坑）

* 此坑太大，先放着不填。
* 其实本质就是$\epsilon=\mu*1$
* 比如$\sum_{i=1}^n[\gcd(i,m)=1]=\sum_{i=1}^n\sum_{d|\gcd(i,m)}\mu(d)=\sum_{d|m}\mu(d)\lfloor\frac{n}{d}\rfloor$

# 杜教筛

杜教筛是个好东西，它是一种特殊的求和方法，而其中的关键就是狄利克雷卷积。
可以这么说，杜教筛是目前OI界，最成熟的算法层面的狄利克雷卷积的应用吧。
~~但是我还是太弱的，并没有非常好地掌握狄利克雷卷积的知识，所以，先把坑放在这儿。~~

$update2019.07.08:$ 我学成归来，开始填坑了。

$update2019.09.22:$ 我发现分类出了bug，其实我原称的“第二种杜教筛”和“第三种杜教筛”，都是经典的应用特例，故现在改称“杜教筛应用一”“杜教筛应用二”。你不高兴看大可以不看。

## 约定
我们约定$f(i),g(i),h(i)$为三个数论函数，可能是给定的或者自己找的。
$F(i),G(i),H(i)$分别为$f(i),g(i),h(i)$的前缀和。（栗子：$F(i)=\sum\limits_{i=1}^{n}f(i)$）
要求的东西统一称作$S(n)$。

## 经典杜教筛
### 描述
给定一个数论函数$f(i)$，求$S(n)=F(i)=\sum\limits_{i=1}^{n}f(i)$
### 推导
假设我们能找到两个数论函数$g(n),h(n)$，使得$h(n)=\sum\limits_{d|n}g(d)f(\frac{n}{d})$
那么
$$\begin{aligned}H(n)&=\sum\limits_{i=1}^{n}h(i)&(2.1)\\&=\sum\limits_{i=1}^{n}\sum\limits_{d|i}g(d)f\left(\frac{i}{d}\right)&(2.2)\\&=\sum\limits_{i=1}^{n}g(i)\sum\limits_{ij\leqslant n}f(j)&(2.3)\\&=\sum\limits_{i=1}^{n}g(i)F\left(\frac{n}{i}\right)&(2.4)\\&=g(1)F(n)+\sum\limits_{i=2}^{n}g(i)F\left(\left\lfloor\frac{n}{i}\right\rfloor\right)&(2.5)\end{aligned}$$
（$(2.2)$到$(2.3)$是最妙的地方，考虑对于每一个$g(i)$，我们会把它和哪些$f(i)$相乘）
（$(2.2)$到$(2.4)$这一类的变换在下文中会出现多次，之后就不写全了）

所以
$g(1)F(n)=H(n)-\sum\limits_{i=2}^{n}g(i)F(\left\lfloor\frac{n}{i}\right\rfloor)\qquad(2.6)$

我们假设你找到了一个很好的函数$g(n)$，使得$H(n),G(n)$都可以快速计算。我们就可以递归地去计算$F(n)$了。

注意到对于$n$，$\left\lfloor\frac{n}{i}\right\rfloor$只会有$O(\sqrt{n})$种取值，所以$(2.6)$中的那个$\sum_{i=2}^{n}g(i)F(\left\lfloor\frac{n}{i}\right\rfloor)$是可以$O(\sqrt{n})$算的。

具体来说，对于每一种$\left\lfloor\frac{n}{i}\right\rfloor$的取值（假设从$i_1$到$i_2$，$\left\lfloor\frac{n}{i}\right\rfloor$是同一个值），都是$F(\left\lfloor\frac{n}{i}\right\rfloor)\sum_{i_1}^{i_2} g(i)$的形式。而$\sum_{i_1}^{i_2} g(i)$是可以利用$G$快速求的。

进一步优化，我们可以利用线性筛预处理$1$到$n^{\frac{2}{3}}$的$f(i)$值，如果询问到已经预处理出来的$F$值，就可以不用往下递归了（至于为什么是$n^{\frac{2}{3}}$，在底下的复杂度分析里有讲）。

### 时间复杂度
（我们假设$H$和$G$都可以$O(1)$求）
先分析$(2.6)$式（就是先不预处理前$n^{\frac{2}{3}}$个）

我们发现，如果要求$F(n)$，那我们要求出所有的$F(\left\lfloor\frac{n}{i}\right\rfloor)$，这会有$O(\sqrt{n})$种取值。这$O(\sqrt{n})$个值，如果我们要求出来，看起来是还要用其他$F$值的。但是，感性理解一下，你会发现你就只会用到这$O(\sqrt{n})$个值了。
只要证明对于$\left\lfloor\frac{n}{i}\right\rfloor$，所有的$\left\lfloor\frac{\left\lfloor\frac{n}{i}\right\rfloor}{j}\right\rfloor$都与$\left\lfloor\frac{n}{ij}\right\rfloor$相等就行了。
你可以感性理解这件事，也可以证明一下。

在这里我给出我的证明：
设$n=q*ij+r(r<ij)$，很明显，$\left\lfloor\frac{n}{ij}\right\rfloor=q$
代入，化简，可以发现：$\left\lfloor\frac{n}{i}\right\rfloor=q*j+\left\lfloor\frac{r}{i}\right\rfloor$
则$\left\lfloor\frac{\left\lfloor\frac{n}{i}\right\rfloor}{j}\right\rfloor=q+\left\lfloor\frac{\left\lfloor\frac{r}{i}\right\rfloor}{j}\right\rfloor=q$
证讫。

那么，我们对于这些取值，分别算贡献即可。随便算一波，大概会视你的姿势水平高低，得到一个$n^{\frac{5}{6}}$之类的式子，而且你深知这个上界大大夸大了。不过这不重要，因为这种不预处理前缀的写法不是杜教筛的通常写法，他太慢了。

那接下来讲讲预处理前缀的分析。
我们设求前$z$个的值（这里设一下，是为了说明为什么预处理前$n^{\frac{2}{3}}$个是最优的）
那么复杂度有两部分，一部分是预处理，是$O(z)$的。
另一部分，是求没有预处理出来的那些$F$的复杂度。我们假设每一次都重新算一遍，这样会得到上限。
$$\begin{aligned}&\sum\limits_{i=2}^{\frac{n}{z}}\sqrt{\frac{n}{i}}\qquad&(3.1)\\\leqslant&\sum\limits_{i=1}^{\frac{n}{z}}\sqrt{\frac{n}{i}}&(3.2)\\=&\sqrt{n}\sum\limits_{i=1}^{\frac{n}{z}}i^{-\frac{1}{2}}&(3.3)\\\leqslant&2\sqrt{n}\cdot \left(\frac{n}{z}\right)^{\frac{1}{2}}&(3.4)\\=&2\cdot\frac{n}{\sqrt{z}}&(3.5)\end{aligned}$$
注意到$(3.3)$到$(3.4)$用了一步积分。
那复杂度为$O(z+n\cdot z^{-\frac{1}{2}})$，显然，$z$取$n^{\frac{2}{3}}$时最优。为$O(n^{\frac{2}{3}})$
事实上，在这个$z$的取值下，$1\cdots \frac{n}{z}$每一个$\left\lfloor\frac{n}{i}\right\rfloor$的值都不同，所以这个时间复杂度很对。
在实际使用的时候，你可以视两部分的常数差异而微调$z$的取值。

### 代码
是这道题：[Luogu P4213 【模板】杜教筛（Sum）](https://www.luogu.org/problemnew/show/P4213)
注意两处（我第一遍写的时候没有处理好）：

- 一定要记忆化起来，可以用unordered_map，或者直接用（总数的n）/（当前这个数cn）作为下标存起来，但是map会t到怀疑人生
- 因为这是多组询问，预处理可以适当多一点。（当然，你也可以根据输入的n去算要预处理多少）

```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 3000000
#define INF 2100000000
#define MAXM 2000
using namespace std;
template<typename T>void Read(T &cn)
{
	char c;int sig = 1;
	while(!isdigit(c = getchar()))if(c == '-')sig = -1;cn = c-48;
	while(isdigit(c = getchar()))cn = cn*10+c-48;cn*=sig;
}
template<typename T>void Write(T cn)
{
	if(!cn){putchar('0');return;}
	if(cn<0){putchar('-');cn = 0-cn;}
	int wei = 0;T cm = 0;int cx = cn%10;cn=cn/10;
	while(cn)wei++,cm = cm*10+cn%10,cn=cn/10;
	while(wei--)putchar(cm%10+48),cm=cm/10;
	putchar(cx+48);
}
int n,t;
int f1[MAXN+1],f2[MAXN+1],F2[MAXN+1];
LL F1[MAXN+1];
int pri[MAXN+1],ssh[MAXN+1],xiao[MAXN+1],plen;
LL M1[MAXM+1];
int M2[MAXM+1];
void yuchu(int cn)
{
	memset(ssh,0,sizeof(ssh)); plen = 0; ssh[1] = 1;
	f1[1] = f2[1] = 1;
	for(int i = 2;i<=cn;i++)
	{
		if(!ssh[i]){
			pri[++plen] = i;
			xiao[i] = plen;
			f1[i] = i-1; f2[i] = -1;
			for(int j = i;1ll*i*j<=cn;j=j*i)xiao[i*j] = plen,ssh[i*j] = 1,f1[i*j] = i*j-j,f2[i*j] = 0;
		}
		for(int j = 1;j<xiao[i] && 1ll*pri[j]*i<=cn;j++)
		{
			for(int k = pri[j];1ll*k*i<=cn;k = k*pri[j])xiao[k*i] = j,ssh[k*i] = 1,f1[k*i] = f1[k]*f1[i],f2[k*i] = f2[k]*f2[i];
		}
	}
	F1[0] = F2[0] = 0;
	for(int i = 1;i<=cn;i++)F1[i] = F1[i-1]+f1[i],F2[i] = F2[i-1]+f2[i];
}
LL djs1(int cn)
{
	if(cn <= MAXN)return F1[cn];
	if(M1[n/cn] != -INF)return M1[n/cn];
	LL guo = 1ll*cn*(cn+1)/2;
	for(int l = 2,r;l<=cn;l = r+1)
	{
		r = cn/(cn/l);
		guo = guo - (r-l+1) * djs1(cn/l);
	}
	return M1[n/cn] = guo;
}
LL djs2(int cn)
{
	if(cn <= MAXN)return F2[cn];
	if(M2[n/cn] != -INF)return M2[n/cn];
	int guo = 1;
	for(int l = 2,r;l<=cn;l = r+1)
	{
		r = cn/(cn/l);
		guo = guo - (r-l+1)* djs2(cn/l);
	}
	return M2[n/cn] = guo;
}
int main()
{
	yuchu(MAXN);
	Read(t);
	while(t--)
	{
		Read(n);
		for(int i = 0;i<=n/MAXN;i++)M1[i] = -INF,M2[i] = -INF;
		Write(djs1(n)); putchar(' '); Write(djs2(n)); putchar('\n');
	}
	return 0;
}
```

然后，这边还有一种写法，好像要快一点

```c
LL djs1(int cn)
{
	if(cn <= MAXN)return F1[cn];
	if(M1[n/cn] != -INF)return M1[n/cn];
	LL guo = 1ll*cn*(cn+1)/2,lin = floor(sqrt(cn));
	for(int i = 1;i<=lin;i++)guo = guo - djs1(i)*(cn/i - cn/(i+1));
	lin = cn/(lin+1);
	for(int i = 2;i<=lin;i++)guo = guo - djs1(cn/i);
	return M1[n/cn] = guo;
}
```
## 杜教筛应用
### 杜教筛应用一
#### 描述
求$S(n)=\sum\limits_{i=1}^{n}f(i)g(i)$
通常有$g$为完全积性函数
#### 推导
首先说一句，事实上你可以把$f(i)g(i)$看成一个新函数$f'(i)$，然后用经典方法找到一个对应的$g'(i)$求和。
这里单独列出来讨论，是为了一般性地思考这个问题。
##### 经典推导（雾
我们以一个特殊的例子来说明，以此来体现这到底是个什么过程

求：$S(n)=\sum\limits_{i=1}^{n}\varphi(i)i$

没什么头绪，因为我们不知道应该卷什么。
那我们先试一试吧。
设$f(n)=n\cdot\varphi(n),h(n)=f*g$
$$\begin{aligned}h(n)=&\sum\limits_{d|n}f(d)g(\frac{n}{d})\\=&\sum\limits_{d|n}\varphi(d)\cdot d\cdot g(\frac{n}{d})\end{aligned}$$
我们发现，$g$如果取$id$函数（$id(n)=n$）就会血赚。
就有$h(n)=\sum_{d|n}\varphi(d)n=n^2$
则$H(n)=\sum_{i=1}^n i^2=\frac{n(n+1)(2n+1)}{6}$
套用前文所述即可。
##### 一般性推导
我们设$f'(n)=f(n)g(n),h(n)=\sum\limits_{d|n}f(d)g(d)g'(\frac{n}{d})$
此时，我们很想把$g'$直接定为$g$，然后把$g(d)g'(\frac{n}{d})$直接并为$g(n)$。
什么时候能这么做？
当$g$为完全积性函数的时候。
因此我们才有了一开始描述中的那个条件：$g$为完全积性函数。

所以，$H(n)=\sum\limits_{i=1}^{n}g(i)\sum\limits_{d|i}f(d)=\sum\limits_{i=1}^{n}g(i)\cdot(f*1)(i)$
（这个式子是为了快速求$H(n)$推的，显然，他需要$f$有很好的性质）

同时，$H(n)=\sum\limits_{i=1}^{n}h(i)=\sum\limits_{i=1}^{n}\sum\limits_{d|i}f'(d)g(\frac{i}{d})=\sum\limits_{i=1}^{n}g(i)S(\left\lfloor\frac{n}{i}\right\rfloor)$
我们就有$S(n)=H(n)-\sum\limits_{i=2}^{n}g(i)S(\left\lfloor\frac{n}{i}\right\rfloor)$
就可以求了。

我们还可以发现，$h(n)=(f*1)(n)\cdot g(n)$这样就比较好看了。

然后，仿佛这个东西只能求一下$f(n)=\varphi(n),g(n)=n^d$

$update:$ 其实带 $\epsilon$的也是能求的。
### 杜教筛应用二
#### 描述
求$S(n)=\sum\limits_{i=1}^{n}(f*g)(i)$
#### 推导
这一种好像就比较厉害了（并没有）。

先扯一种特殊情况：
我们相当于在经典杜教筛里能快速求$F,G$，想利用这两个求出$H$。
那就可以直接$S(n)=\sum\limits_{i=1}^{n}\sum\limits_{d|i}f(d)g(\frac{i}{d})=\sum\limits_{i=1}^{n}f(i)G(\left\lfloor\frac{n}{i}\right\rfloor)$，在$O(\sqrt{n})$的时间内求出。
但是这太受限了。

首先，我们设$h(n)=(f*1)(n)$。
我们可以推出来这样一个式子：
$$\begin{aligned}&\sum_{i=1}^{n}S\left(\left\lfloor\frac{n}{i}\right\rfloor\right)\qquad&(4.1)\\=&\sum_{i=1}^{n}\sum_{d|i}(f*g)(d)&(4.2)\\=&\sum_{i=1}^{n}\sum_{d_1|i}\sum_{d_2|d_1}g(d_2)f\left(\frac{d_1}{d_2}\right)&(4.3)\\=&\sum_{i=1}^{n}\sum_{d_2|i}g(d_2)\sum_{d_3|\frac{i}{d_2}}f(d_3)&(4.4)\\=&\sum_{i=1}^{n}\sum_{d|i}g(d)\cdot(f*1)\left(\frac{i}{d}\right)&(4.5)\\=&\sum_{i=1}^{n}g(i)H\left(\left\lfloor\frac{n}{i}\right\rfloor\right)&(4.6)\end{aligned}$$
这就很杜教筛了。
继续往下：
$$\begin{aligned}\sum_{i=1}^{n}S\left(\left\lfloor\frac{n}{i}\right\rfloor\right)&=\sum_{i=1}^{n}g(i)H\left(\left\lfloor\frac{n}{i}\right\rfloor\right)\\S(n)&=\sum_{i=1}^{n}g(i)H\left(\left\lfloor\frac{n}{i}\right\rfloor\right)-\sum_{i=2}^{n}S\left(\left\lfloor\frac{n}{i}\right\rfloor\right)\end{aligned}$$
这样，如果$H,G$都是能快速求出的，$S(n)$就能在$O(n^{\frac{2}{3}})$的复杂度内求出。

你可能会觉得，这还是没什么用。但是这就可以搞$f$为$\varphi$了。（尽管这也是可以用经典杜教筛做的，用$S(n)=\sum_{i=1}^{n}g(i)F\left(\left\lfloor\frac{n}{i}\right\rfloor\right)$一边弄$F$一边弄$S$）

## 杜教筛总结

你也许已经看出来这两个应用的本质了：应用一就是卷上了$g$，应用二就是卷上了$1$。
而这一通操作的理由，都是为了计算出$H(n)$。

我之所以还没有删掉他们，就是因为这算是比较好的两个应用实例，公式推到一半，熟练的话就可以直接看出来这样就行了，不用继续去试了。

综上所述，杜教筛的要义就是：
* 你想求前缀和
* 你把求前缀和的东西整个看成一个函数$f$，二话不说，先卷起来
* 你开始琢磨$H$和$G$怎么求会比较简单。

这件事情就给一些杜教筛套min25的毒瘤留下了迫害幼小儿童的机会。

# 结语
卷积的这一块内容，乍一看，好像是需要强大的记忆力和见多识广。能不能做出来那道题，全靠运气
~~（想找到那个奇妙的函数，就好像，要找到爱情（雾））。~~
~~但是，我还是坚持自己从文化课带出来的一点点经验。理解，感受到其中的精妙，感受到想出这个东西的人为什么会这么想，才是王道。~~
