### FFT与多项式乘法
#### 多项式乘法
定义严格大于$\deg A(x)$的正整数$n$是$A(x)$的次数界，比如$n-1$次多项式的一个次数界是$n$，而$n-1$不是
多项式$A(x)=\sum_{i=0}^{n-1}{a_ix^i}$和$B(x)=\sum_{i=0}^{n-1}{b_ix^i}$的乘法
```math
C(x)=A(x)B(x) = \sum_{i=0}^{2n-1}{\sum_{j+k=i}{a_jb_kx^i}}
```
在计算机中用系数数组的方式表示一个多项式，如果使用上面的公式，求解两个次数界为$n$的多项式乘法的时间复杂度是$\Theta(n^2)$
因为$n$个点可以确定一个$n-1$次多项式，对于多项式乘法$A(x)$和$B(x)$，如果先求出它们在$n$个点的取值，再把结果相乘，得到$C(x)$的点表示，再通过插值来计算它的系数。虽然如果随机选取$n$个点，然后把$A(x)$和$B(x)$对应的点的取值相乘，然后使用拉格朗日插值公式
```math
C(x) = \sum_{i=0}^{n-1}{y_i\frac{\prod_{j \neq i}{(x-x_j)}}{\prod_{j \neq i}(x_i-x_j)}}
```
算法复杂度仍然是$\Theta(n^2)$，但是可以利用复数的一些性质，选取一些特定的点，可以把复杂度下降至$\Theta(n \lg n)$

---

#### 关于复数的一些结论
设$\omega_n$是**主n次单位根**$e^{\frac{2 \pi i}{n}}$
##### 消去引理
```math
\omega_{dn}^{dj} = \omega_{n}^j
```
证明：
```math
\omega_{dn}^{dj} = \left(e^{\frac{2 \pi i}{dn}}\right)^{dj} = e^{\frac{2 \pi i}{n}j} = \omega_n^j
```
##### 折半引理
如果$n>0$是偶数，那么$n$个$n$次单位根的平方的集合就是$n/2$个$n/2$次单位根的集合，即
```math
\left\{\left(\omega_n^k\right)^2 | k=0,1,\cdots,n-1\right\} = \left\{\left(\omega_{n/2}^k\right)^2 | k=0,1,\cdots,n/2-1\right\}
```
证明：因为
```math
\left(\omega_n^{k+n/2}\right)^2 = \omega_n^{2k} = \omega_{n/2}^{k}
```
所以$\omega_n^{k+n/2}$的平方结果与$\omega_n^{k}$相同
##### 求和引理
如果$n \nmid k$，则
```math
\sum_{j=0}^{n-1}{\omega_n^{kj}} = 0
```
证明：因为
```math
\sum_{j=0}^{n-1}{\omega_n^{kj}} = \frac{1-\omega_n^{kn}}{1-\omega_n^k} = 0
```
当$1-\omega_n^k \neq 0$时，上式左端为$0$

---

#### 离散傅里叶变换DFT
##### 定义
设多项式$A(x) = a_0 + a_1x + \cdots + a_{n-1}x^{n-1} = \sum_{i=0}^{n-1}{a_ix^i}$，离散傅里叶变换
是
```math
A(x)=\sum_{i=0}^{n-1}{a_ix^i} \mapsto \left(\sum_{i=0}^{n-1}{a_iw_n^{ki}}\right)_{1 \times n} = \left(A(\omega_n^k)\right)_{1 \times n}
```
写成矩阵形式
```math
\begin{pmatrix}
1 & 1 & 1 & \cdots & 1 \\
1 & \omega_n^1 & \omega_n^2 & \cdots & \omega_n^{n-1} \\
1 & \omega_n^2 & \omega_n^4 & \cdots & \omega_n^{2(n-1)} \\
1 & \omega_n^3 & \omega_n^6 & \cdots & \omega_n^{3(n-1)} \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
1 & \omega_n^{n-1} & \omega_n^{2(n-1)} & \cdots & \omega_n^{(n-1)(n-1)} \\
\end{pmatrix}
\begin{pmatrix}
a_0 \\
a_1 \\
a_2 \\
a_3 \\
\vdots \\
a_{n-1} \\
\end{pmatrix}
=
\begin{pmatrix}
y_0 \\
y_1 \\
y_2 \\
y_3 \\
\vdots \\
y_{n-1} \\
\end{pmatrix}
```
DFT可以看作把多项式的系数变换成了多项式一些特点的取值
对于两个次数界是$n$的多项式$A(x)$和$B(x)$，先对它们进行DFT，得到两个向量$\left(A(\omega_n^k)\right)_{1 \times n}$和$\left(B(\omega_n^k)\right)_{1 \times n}$，让它们的分量对应相乘，得到$\left(C(\omega_n^k)\right)_{1 \times n}$，然后进行逆DFT，就可以得到$C(x)$的系数表示

##### 逆DFT
只要求出DFT的矩阵的逆
设DFT的矩阵是$P_n = \left(\omega_n^{ij} \right)_{n \times n}$，行和列从$0$开始计数
则逆DFT的矩阵是$P_n^{-1} = \left(\frac{1}{n}\omega_n^{-ij} \right)_{n \times n}$，因为
```math
P_nP_n^{-1}(j;j^\prime) = \sum_{k=0}^{n-1}{\omega_n^{jk}\frac{1}{n}\omega_n^{-kj^\prime}} = \frac{1}{n}\sum_{k=0}^{n-1}{\omega_n^{(j-j^\prime)k}} = \delta_{jj^\prime}
```
当$j-j^\prime \neq 0$时，右端为$0$
因此，逆DFT的公式是
```math
a_i = \frac{1}{n}\sum_{k=0}^{n-1}{y_k\omega_{n}^{-ik}}
```

#### $\Theta(n \lg n)$时间复杂的DFT实现(FFT)
假设$n$是2的方幂
```math
A(x) = a_0 + a_1x + a_2x^2 + \cdots + a_{n-1}x^{n-1}
```
分别提取$A(x)$的奇、偶下标项
```math
\begin{aligned}
A^{[0]}(x) = a_0 + a_2x + \cdots + a_{n-2}x^{n/2-1} \\
A^{[1]}(x) = a_1 + a_3x + \cdots + a_{n-1}x^{n/2-1}
\end{aligned}
```
则有
```math
A(x) = A^{[0]}(x^2) + xA^{[1]}(x^2)
```
用$\omega_n^{k+n/2}$和$\omega_n^{k}$分别代入
```math
\begin{aligned}
A(\omega_n^{k}) = A^{[0]}(\omega_{n/2}^k) + \omega_n^{k}A^{[1]}(\omega_{n/2}^k) \\
A(\omega_n^{k+n/2}) = A^{[0]}(\omega_{n/2}^k) - \omega_n^{k}A^{[1]}(\omega_{n/2}^k)
\end{aligned}
```
于是问题分解成了两个子问题$A^{[0]}(\omega_{n/2}^k)$和$A^{[1]}(\omega_{n/2}^k)$，以上的运算又称为**蝴蝶操作**。
原问题：求次数界为$n$的多项式$A(x)$在$\omega_n^0,\omega_n^1,\cdots,\omega_n^{n-1}$的取值
分而治之：
1. 求次数界为$n/2$的多项式$A^{[0]}(x)$和$A^{[1]}(x)$在点$\omega_{n/2}^0,\omega_{n/2}^1,\cdots,\omega_{n/2}^{n/2-1}$的取值
2. 用上述的蝴蝶操作，计算出$A(x)$在$w_n^0,w_n^{n/2};w_n^1,w_n^{1+n/2};\cdots;w_n^{n/2-1},w_n^{n-1}$上的取值

##### 伪代码
```FSharp
let rec RecursiveFFT (a) = 
    let n = Array.length a
    if n = 1 then
        a
    else
        let a0 = Array.map (fun i -> a.[i]) [|0 .. 2 .. n-2|]
        let a1 = Array.map (fun i -> a.[i]) [|1 .. 2 .. n-1|]
        let y0 = RecursiveFFT(a0)
        let y1 = RecursiveFFT(a1)
        let y = Array.create n 0
        let mutable w = 1.0
        let wn = exp (2*Math.PI*I/n)
        for k = 0 to n/2 - 1 do
            y.[k] <- y0.[k] + w*y1.[k]
            y.[k+n/2] <- y0.[k] - w*y1.[k]
            w <- w*wn
        y
```
只要把伪代码中的`wn = exp (2*Math.PI*I/n)`换成`wn = exp (-2*Math.PI*I/n)`，并把最终结果除以n就得到逆DFT的代码

---

#### FFT的迭代实现
以8点FFT为例，观察FFT的子问题树
![fft-tree](./fft.png)

我们可以自底向上地解决问题，对于一个长度为$n$的问题，如果它的两个子问题已经解决，可以通过$n/2$次的蝴蝶操作来得到原问题的结果
我们用$y^{(i)}$表示在子问题树的第$i$层的解，对于问题$fft(a_0,a_4)$，已知子问题$fft(a_0)$和$fft(a_4)$的解$y_0^{(3)}$和$y_4^{(3)}$，那么可以通过一次蝴蝶操作，得到$fft(a_0,a_4)$的解$(y_0^{(2)},y_4^{(2)})$
```math
\left\{\begin{aligned}
    y_0^{(2)} = y_0^{(3)} + \omega_2^0 y_4^{(3)} \\
    y_4^{(2)} = y_0^{(3)} - \omega_2^0 y_4^{(3)} \\
\end{aligned}\right.
```
对于问题$fft(a_0,a_2,a_4,a_6)$，如果已知$(y_0^{(2)},y_4^{(2)})=fft(a_0,a_4)$和$(y_2^{(2)},y_6^{(2)})=fft(a_2,a_6)$，再经过两个蝴蝶操作，得到$fft(a_0,a_2,a_4,a_6)$的解$(y_0^{(1)},y_2^{(1)},y_4^{(1)},y_6^{(1)})$
```math
\begin{aligned}
\left\{\begin{aligned}
y_0^{(1)} = y_0^{(2)} + \omega_4^0 y_2^{(2)} \\
y_4^{(1)} = y_0^{(2)} - \omega_4^0 y_2^{(2)}
\end{aligned}\right. ,\quad
\left\{\begin{aligned}
y_2^{(1)} = y_4^{(2)} + \omega_4^1 y_6^{(2)} \\
y_6^{(1)} = y_4^{(2)} - \omega_4^1 y_6^{(2)}
\end{aligned}\right.
\end{aligned}
```
对于问题$fft(a_0,a_1,a_2,a_3,a_4,a_5,a_6,a_7)$，已知$(y_0^{(1)},y_2^{(1)},y_4^{(1)},y_6^{(1)})=fft(a_0,a_2,a_4,a_6)$和$(y_1^{(1)},y_3^{(1)},y_5^{(1)},y_7^{(1)})=fft(a_1,a_3,a_5,a_7)$，再经过4个蝴蝶操作，得到最终解
```math
\begin{aligned}
\left\{\begin{aligned}
y_0^{(0)} = y_0^{(1)} + \omega_8^0 y_1^{(1)} \\
y_4^{(0)} = y_0^{(1)} - \omega_8^0 y_1^{(1)}
\end{aligned}\right. ,\quad
\left\{\begin{aligned}
y_1^{(0)} = y_2^{(1)} + \omega_8^1 y_3^{(1)} \\
y_5^{(0)} = y_2^{(1)} - \omega_8^1 y_3^{(1)}
\end{aligned}\right. \\
\left\{\begin{aligned}
y_2^{(0)} = y_4^{(1)} + \omega_8^2 y_5^{(1)} \\
y_6^{(0)} = y_4^{(1)} - \omega_8^2 y_5^{(1)}
\end{aligned}\right. ,\quad
\left\{\begin{aligned}
y_3^{(0)} = y_6^{(1)} + \omega_8^3 y_7^{(1)} \\
y_7^{(0)} = y_6^{(1)} - \omega_8^3 y_7^{(1)}
\end{aligned}\right.
\end{aligned}
```

##### 位逆序
只要数组$a$的排列满足子问题树的叶子的排序，就有办法自下而上解决问题
次数界$n=2^l$，子问题树的叶子的下标其实对应了位逆序排列，即把一个数字写成$l$个二进制数的形式，然后再把这些数逆序，比如
```math
7 = {1100}_{(2)} \mapsto {0011}_{(2)} = 3
```
0-7的位逆序
| 数字    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| ------- | - | - | - | - | - | - | - | - |
| 二进制  |000|001|010|011|100|101|110|111|
| 位逆序  |000|100|010|110|001|101|011|111|
观察得到位逆序的首位取决于数字奇偶性，先对数字的前$2$位进行逆序，这可以通过先把数字右移一位，然后求逆序，然后再右移一位，最后通过奇偶性来确定首位
```math
011 \xmapsto{>>1} 001 \xmapsto{rev} 100 \xmapsto{>>1} 010 \xmapsto{odd} 110
```
伪代码就是`rev[i] = rev[i>>1]>>1 | ((i&1) << (l-1))`

##### 代码实现
观察子问题树，从底层开始，逐层向上求解
先按照位逆序把输入数组$a$重新排序，对于每一层，对其中的每一个子问题进行所有的蝴蝶操作
```FSharp
for s = 1 to lgn do
    m = 2^s
    for k = 0 to n-1 by m do
        // 把两个长度为m/2子问题的结果
        // A[k, k+1, ..., k+m/2-1]和A[k+m/2, k+m/2+1, ..., k+m-1]
        // 通过m/2个蝴蝶操作合并到长度为m的子问题的结果A[k,k+1,...,k+m-1]
        for j = 0 to m/2-1 do
            // 蝴蝶操作
            s = A[k + j] // A^[0]
            t = wm * A[k + j + m/2] // w_m*A^[1]
            A[k + j] = s + t
            A[k + j + m/2] = s - t
```

##### C代码
```C
void FFT(float complex A[], float complex a[], int n)
{
    int* rev = (int*)calloc(n, sizeof(int));
    int l = (int)ceil(log2(n));
    int i, j, k;
    int m;
    float complex u, t;
    float complex w, wm;
    
    rev[0] = 0;
    for(i = 1; i < n; i++)
        rev[i] = (rev[i >> 1] >> 1) | ((i&1) << (l-1));
    for(i = 0; i < n; i++)
        A[i] = a[rev[i]];

    m = 1;
    for(i = 0; i < l; i++)
    {
        m <<= 1;
        wm = cexpf(2*M_PI*I/m);
        w = 1.0f;
        for(k = 0; k < m/2; k++)
        {
            for(j = 0; j < n; j += m)
            {
                u = A[j + k];
                t = w*A[j + k + m/2];
                A[j + k] = u + t;
                A[j + k + m/2] = u - t;
            }
            w = w*wm;
        }
    }
    free(rev);
}
```