#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
#include <stdbool.h>
#include <assert.h>

// 定点转浮点
float decode(unsigned short x)
{
    float value = 0.0f;
    float radix = 128.0f;
    if((x & 0x8000) != 0)
        value -= radix;
    radix *= 0.5f;

    for(int i = 1; i < 16; i++)
    {
        x <<= 1;
        if((x & 0x8000) != 0)
            value += radix;
        radix *= 0.5f;
    }
    return value;
}

// 浮点转定点
unsigned short encode(float x)
{
    bool sign = x < 0;
    unsigned int n = *(unsigned int*)&x;
    int power = ((n >> 23) & 0xff);
    unsigned int significant = (n & 0x7fffff);
    int res;

    if(power == 255)
    {
        printf("ERROR: w out of range\n");
        return 0;
    }
    else if(power == 0)
    {
        return 0;
    }
    else
    {
        power -= 127;
        significant |= 0x800000;
        if(power >= 0)
            significant <<= power;
        else
            significant >>= (-power);
        // 整数 31...23 小数 22...0
        //      30...23 22...15

        res = ((significant >> 15) & 0xffff);
        res = sign ? -res : res;
        return (unsigned short)res;
    }
}

void fft(float complex A[], float complex a[], int n, bool inv)
{
    assert((n & (n-1)) == 0); // n必须是2的方幂

    int i, j, k;
    int m;
    float complex u, t;
    float complex w, wm;
    int l = (int)ceil(log2(n));
    int* rev = (int*)calloc(n, sizeof(int));
    float one_div_n = 1 / (float)n;
    
    rev[0] = 0;
    for(i = 1; i < n; i++)
        rev[i] = (rev[i >> 1] >> 1) | ((i&1) << (l-1));
    for(i = 0; i < n; i++)
        A[i] = a[rev[i]] * (inv ? one_div_n : 1.0f);
    free(rev);

    m = 1;
    for(i = 0; i < l; i++)
    {
        m <<= 1;
        wm = inv ? cexpf(2*M_PI*I/m) : cexpf(-2*M_PI*I/m);
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
}

void print_complex(float complex z)
{
    printf("%f", crealf(z));
    if(cimagf(z) >= 0)
        printf("+%fj", cimagf(z));
    else
        printf("%fj", cimagf(z));
}

int main(void)
{
    int i;
    float complex a1[64];
    float complex a2[64];
    for(i = 0; i < 64; i++)
        a1[i] = cosf(i);
    for(i = 0; i < 64; i++)
        a2[i] = tanhf(i * 0.05f);
    FILE* tb_fft_in = fopen("tb_fft_in.txt", "w");
    fprintf(tb_fft_in, "0\n");
    for(i = 0; i < 64; i++)
        fprintf(tb_fft_in, "%04x %04x\n", encode(crealf(a1[i])), encode(cimagf(a1[i])));
    fprintf(tb_fft_in, "1\n");
    for(i = 0; i < 64; i++)
        fprintf(tb_fft_in, "%04x %04x\n", encode(crealf(a2[i])), encode(cimagf(a2[i])));
    fclose(tb_fft_in);

    float complex A1_c[64];
    float complex A2_c[64];
    float complex A1_v[64];
    float complex A2_v[64];
    fft(A1_c, a1, 64, false);
    fft(A2_c, a2, 64, true);
    FILE* tb_fft_out = fopen("tb_fft_out.txt", "r");
    unsigned int real, imag;
    for(i = 0; i < 64; i++)
    {
        fscanf(tb_fft_out, "%x %x\n", &real, &imag);
        A1_v[i] = decode((unsigned short)real) + decode((unsigned short)imag) * I;
    }
    for(i = 0; i < 64; i++)
    {
        fscanf(tb_fft_out, "%x %x\n", &real, &imag);
        A2_v[i] = decode((unsigned short)real) + decode((unsigned short)imag) * I;
    }
    fclose(tb_fft_out);

    for(i = 0; i < 64; i++)
    {
        print_complex(A1_c[i]);
        printf("\t");
        print_complex(A1_v[i]);
        printf("\n");
    }
    printf("\n");
    for(i = 0; i < 64; i++)
    {
        print_complex(A2_c[i]);
        printf("\t");
        print_complex(A2_v[i]);
        printf("\n");
    }
    printf("\n");
    return 0;
}