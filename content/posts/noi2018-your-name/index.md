---
title: "NOI 2018「你的名字」题解"
description: "利用后缀自动机与可持久化线段树维护 endpos 集合，处理区间限制下的不同子串计数。"
date: 2019-08-15T10:18:00+08:00
lastmod: 2022-08-05T12:27:00+08:00
slug: noi2018-your-name
tags:
  - algorithms
  - problem-solution
  - string-algorithms
featured: false
legacy: true
math: true
originalId: 11356317
originalURL: https://www.cnblogs.com/czyarl/p/11356317.html
---

# 题目
[LOJ2720](https://loj.ac/problem/2720)     P.S.loj数据好下。
[LuoguP4770](https://www.luogu.com.cn/problem/P4770)
每次给出两个字符串S和T，询问第一个字符串的有多少不同子串不是第二个字符串的子串。
每一次询问都会给出一个不同的S，而T是一开始输入的一个字符串的子串（输入$[l,r]$来描述）。
$|S|,|T|<=5\times10^5,\sum|S|<=10^6$
# 思路
## 数据结构，思想
* 线段树合并（可持久化）
* 后缀自动机

## 真·思路
* 约定几个说法：endpos表示这个后缀自动机节点表示的子串的结尾位置，len表示这个节点表示的最长子串的长度，link表示后缀链接。
* 首先简化问题：考虑对于每个S串的前缀，求出其最长能与T串匹配多少。比这个短就肯定不行。比这个长度长，就可以利用ParentTree去重。（只弄自己这个节点的长度，把剩下的弄到后缀链接指向的那个节点上）
* 整理一下，我们发现，我们只要把S串放在T的后缀自动机上跑出匹配长度，然后再将匹配长度放到S的后缀自动机上跑出不同子串个数。
* 比如，4号节点len为8，link指向3号，3号的len为4，4号节点的匹配长度为3。就可得知3号的匹配长度也为3。在4号处答案增加4，再在3号处答案增加1。（因为可能还有其他节点指向3，所以不可在4直接统计）
* 然后考虑如何回答多组询问。
* 我们发现问题出在把S放在T上跑匹配长度这一步上。因为你临场建SAM是会T掉的。
* 那么我们考虑利用一开始输入的总串的SAM来实现匹配。
* 当我们匹配到一个节点的时候（匹配了$cnt$位），真正匹配上的长度，是这个节点endpos在[l,r]这段范围内，离l最远的那个endpos到l的距离，与$cnt$取$min$的结果。
* 于是乎，我们就要维护一下endpos集合。这个可以用线段树合并。但是注意一点，我们合并的时候要一直建立新点（可持久化），要不然会破坏以前算好的endpos集合。

## 一点注意
* 我们在算匹配长度的时候，如果当前这个点$[l,r]$中最右的endpos到l的距离，都比他的link的len小的话，我们就应该跳到link上。因为这样可能会收获新的endpos，在更右边的地方。
* ~~沙雕作者lojAC后交Luogu，发现RE。最后证实是一个本不该有返回值的函数，作者写了int，但与此同时，里面没有return，导致耿直洛谷不给过。~~

# 代码
```c
#include<bits/stdc++.h>
#define LL long long
#define MAXN 500000
using namespace std;
template<typename T>void Read(T &cn)
{
	char c;int sig = 1;
	while(!isdigit(c = getchar()))if(c == '-')sig = -1; cn = c-48;
	while(isdigit(c = getchar()))cn = cn*10+c-48; cn*=sig;
}
template<typename T>void Write(T cn)
{
	if(cn<0) {putchar('-'); cn = 0-cn; }
	int wei = 0; T cm = 0; int cx = cn%10; cn/=10;
	while(cn)wei++,cm = cm*10+cn%10,cn/=10;
	while(wei--)putchar(cm%10+48),cm/=10;
	putchar(cx+48);
}
int he[MAXN+1],xu[MAXN*2+1];
struct Seg{
	struct node{
		int ls,rs,da;
		void qing() {ls = rs = da = 0; }
	};
	node t[MAXN*60+1];
	int tlen;
	int ro[MAXN*2+1];
	void build() {tlen = 0; t[0].qing(); }
	void jia(int &cn,int cm,int l,int r)
	{
		if(!cn)t[cn = ++tlen].qing();
		if(l == r) {t[cn].da = cm; return; }
		int zh = (l+r)>>1;
		if(cm <= zh)jia(t[cn].ls,cm,l,zh); else jia(t[cn].rs,cm,zh+1,r);
		t[cn].da = max(t[t[cn].ls].da,t[t[cn].rs].da);
	}
	int cha(int cn,int cm,int l,int r)
	{
		if(!cn)return 0;
		if(r <= cm)return t[cn].da;
		int zh = (l+r)>>1;
		if(cm > zh)return max(cha(t[cn].rs,cm,zh+1,r),t[t[cn].ls].da);
		else return cha(t[cn].ls,cm,l,zh);
	}
	void bing(int &cn,int cm1,int cm2,int l,int r)
	{
		if(!cm1 && !cm2)return;
		if(!cm1) {cn = cm2; return; }
		if(!cm2) {cn = cm1; return; }
		cn = ++tlen;
		t[cn].da = max(t[cm1].da,t[cm2].da);
		if(l == r)return;
		bing(t[cn].ls,t[cm1].ls,t[cm2].ls,l,(l+r)>>1);
		bing(t[cn].rs,t[cm1].rs,t[cm2].rs,((l+r)>>1)+1,r);
	}
}T;
struct SAM{
	struct node{
		int link,len,ch[26];
		int edp,f;
		void qing() {link = len = 0; memset(ch,0,sizeof(ch)); }
	};
	node t[MAXN*2+1];
	int tlen,last;
	void build() {t[tlen = last = 1].qing(); }
	void jia(int cn,int cm)
	{
		int cur = ++tlen;
		t[cur].qing();
		t[cur].edp = cm;
		t[cur].len = t[last].len+1;
		int p = last;
		for(;p && !t[p].ch[cn];p = t[p].link)t[p].ch[cn] = cur;
		if(!p)t[cur].link = 1;
		else{
			int q = t[p].ch[cn];
			if(t[p].len +1 == t[q].len)t[cur].link = q;
			else{
				int cln = ++tlen;
				t[cln] = t[q]; t[cln].edp = 0;
				t[cln].len = t[p].len+1;
				t[cur].link = t[q].link = cln;
				for(;p && t[p].ch[cn] == q;p = t[p].link)t[p].ch[cn] = cln;
			}
		}
		last = cur;
	}
	void pro_edp()
	{
		T.build();
		for(int i = 0;i<=t[last].len;i++)he[i] = 0;
		for(int i = 1;i<=tlen;i++)he[t[i].len]++;
		for(int i = 1;i<=t[last].len;i++)he[i] += he[i-1];
		for(int i = 1;i<=tlen;i++)xu[he[t[i].len]--] = i;
		for(int i = tlen;i>=1;i--)
		{
			if(t[xu[i]].edp)T.jia(T.ro[xu[i]],t[xu[i]].edp,1,t[last].len);
			if(t[xu[i]].link)T.bing(T.ro[t[xu[i]].link],T.ro[t[xu[i]].link],T.ro[xu[i]],1,t[last].len);
		}
	}
	int tongji(int n,int l,int r,int ans[],char c[])
	{
		int dang = 1,xian = 0;
		for(int i = 1;i<=n;i++)
		{
			int lin = t[dang].ch[c[i]-'a'],lin2;
			while(dang != 1 && (!lin || T.cha(T.ro[lin],r,1,t[last].len) < l))dang = t[dang].link,lin = t[dang].ch[c[i]-'a'],xian = min(xian,t[dang].len);
			if(lin && T.cha(T.ro[lin],r,1,t[last].len) >= l)dang = lin,xian++; lin2 = T.cha(T.ro[dang],r,1,t[last].len);
			while(dang != 1 && t[t[dang].link].len >= lin2 - l+1)dang = t[dang].link,xian = t[dang].len,lin2 = T.cha(T.ro[dang],r,1,t[last].len);
			ans[i] = min(xian,lin2-l+1);
		}
	}
	LL jisuan(int a[])
	{
		for(int i = 0;i<=t[last].len;i++)he[i] = 0;
		for(int i = 1;i<=tlen;i++)he[t[i].len]++,t[i].f = 0;
		for(int i = 1;i<=t[last].len;i++)he[i] += he[i-1];
		for(int i = 1;i<=tlen;i++)xu[he[t[i].len]--] = i;
		LL guo = 0;
		for(int i = tlen;i>=1;i--)
		{
			if(t[xu[i]].edp)t[xu[i]].f = max(a[t[xu[i]].edp],t[xu[i]].f);
			t[xu[i]].f = min(t[xu[i]].f,t[xu[i]].len);
			guo = guo + t[xu[i]].len - max(t[xu[i]].f,t[t[xu[i]].link].len);
			t[t[xu[i]].link].f = max(t[t[xu[i]].link].f,t[xu[i]].f);
		}
		return guo;
	}
}S1,S2;
int clen,dlen;
char c[MAXN*2+1],d[MAXN*2+1];
int a[MAXN*2+1];
int n;
void getit(char c[],int &n)
{
	while(!isalpha(c[1] = getchar())); n = 1;
	while(isalpha(c[++n] = getchar())); n--;
}
int main()
{
//	freopen("name1.in","r",stdin);
//	freopen("name1.out","w",stdout);
	getit(c,clen); S1.build();
	for(int i = 1;i<=clen;i++)S1.jia(c[i]-'a',i); S1.pro_edp();
	Read(n);
	while(n--)
	{
		getit(d,dlen); int bx,by; Read(bx); Read(by);
		S1.tongji(dlen,bx,by,a,d);
		S2.build(); for(int i = 1;i<=dlen;i++)S2.jia(d[i]-'a',i);
		Write(S2.jisuan(a)); putchar('\n');
	}
	return 0;
}

```
