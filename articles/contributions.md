# Contributions to percent change of chain-linked volume measures

``` r

library(chainlink)
```

Chain-linked volume measures are not additive, so that the contribution
of a component to the growth of the total cannot be read from the growth
of the components.
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)
computes exact contributions: they add up to the growth of the total (up
to the inconsistencies of the data, see below).

## Principle

Let $`x_{i,t}`$ be the chain volume measure (in monetary terms) of the
component $`i`$ in period $`t`$, $`z_t`$ the one of the total, and
$`y(t)`$ the year of the period $`t`$. Within a year $`y`$, the chain
volume measure of the total is exactly the sum of the chain volume
measures of the components, valued at the relative prices
$`\rho_{i,y-1}`$ of the previous year:
``` math
z_t = \sum_i \rho_{i,y(t)-1}\, x_{i,t}.
```
The relative price $`\rho_{i,y}`$ is the implicit price of the component
$`i`$ over the implicit price of the total:

- annual overlap (`method = "ao"`), with the annual sums $`cp_{i,y}`$,
  $`x_{i,y}`$, $`cp_y`$ and $`z_y`$ of the current prices and of the
  chain volume measures:
  ``` math
  \rho_{i,y} = \frac{cp_{i,y} / x_{i,y}}{cp_y / z_y};
  ```
- one-quarter overlap (`method = "oqo"`): the same ratio computed on the
  overlap period (the last quarter, or the last month, of year $`y`$),
  the current prices being valued at the average prices of the year
  ([`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)).

The contribution of the component $`i`$ to the growth between a period
$`s`$ and a period $`t`$ (previous period, same period of the previous
year, or previous year) is
``` math
C_{i,t} = 100 \left[\frac{(x_{i,t} - x_{i,s})\,\rho_{i,y(t)-1}}{z_s}
+ \left(\frac{x_{i,s}}{z_s} - a_{i,y(t)-1}\right)
\left(\rho_{i,y(t)-1} - \rho_{i,y(s)-1}\right)\right]
```
where $`a_{i,y}`$ is the share of the component in the total:
$`a_{i,y} = x_{i,y} / z_y`$ (annual sums) for the annual overlap, and
the same share on the overlap period for the one-quarter overlap.
Summing over $`i`$ gives $`\sum_i C_{i,t} = 100\,(z_t / z_s - 1)`$.

The second term is zero if $`s`$ and $`t`$ are in the same year. For the
annual overlap and the growth over the previous period, this is the
formula of the example 8.9 of the manual. The formula for the
one-quarter overlap, and for the growth over the same period of the
previous year, derive from the same decomposition: they add up to the
growth of the total exactly.

The breakdown between the components is not unique, only its sum is: the
second term (revaluation due to the change of relative prices) is
allocated as in the manual.

## Example

[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)
computes the chain volume measures of the components and of their total
(last column):

``` r

x <- chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
                     output = "measure")
round(x, 3)
#>               A       B   Total
#> 2011 Q1 156.569 221.111 377.680
#> 2011 Q2 159.220 218.061 377.281
#> 2011 Q3 162.524 214.898 377.422
#> 2011 Q4 164.757 213.838 378.596
#> 2012 Q1 165.592 213.614 379.379
#> 2012 Q2 172.326 206.530 379.313
#> 2012 Q3 182.232 198.199 381.269
#> 2012 Q4 206.869 176.073 384.751
#> 2013 Q1 214.161 171.375 388.616
#> 2013 Q2 226.999 159.763 390.766
#> 2013 Q3 235.015 151.043 390.688
#> 2013 Q4 238.639 146.558 390.128
```

Contributions to the growth over the previous quarter
(`type = "period"`, the default). `extra` adds the growth of the total
and the residual (growth of the total minus the sum of the
contributions):

``` r

chain_contrib(x, imf_cp, method = "ao", extra = c("total", "residual")) |>
    round(3)
#>             A      B  Total Residual
#> 2011 Q1    NA     NA     NA       NA
#> 2011 Q2 0.702 -0.808 -0.106        0
#> 2011 Q3 0.876 -0.838  0.038        0
#> 2011 Q4 0.592 -0.281  0.311        0
#> 2012 Q1 0.248 -0.041  0.207        0
#> 2012 Q2 1.817 -1.835 -0.017        0
#> 2012 Q3 2.673 -2.158  0.516        0
#> 2012 Q4 6.615 -5.701  0.913        0
#> 2013 Q1 2.082 -1.077  1.005        0
#> 2013 Q2 3.440 -2.887  0.553        0
#> 2013 Q3 2.136 -2.156 -0.020        0
#> 2013 Q4 0.966 -1.109 -0.143        0
```

Contributions to the growth over the same quarter of the previous year:

``` r

chain_contrib(x, imf_cp, method = "ao", type = "yoy", extra = "total") |>
    round(3)
#>              A       B Total
#> 2011 Q1     NA      NA    NA
#> 2011 Q2     NA      NA    NA
#> 2011 Q3     NA      NA    NA
#> 2011 Q4     NA      NA    NA
#> 2012 Q1  2.419  -1.970 0.450
#> 2012 Q2  3.548  -3.009 0.539
#> 2012 Q3  5.357  -4.338 1.019
#> 2012 Q4 11.409  -9.783 1.626
#> 2013 Q1 13.261 -10.826 2.435
#> 2013 Q2 14.971 -11.951 3.020
#> 2013 Q3 14.419 -11.949 2.471
#> 2013 Q4  8.707  -7.310 1.398
```

Contributions to the growth of the annual sums:

``` r

chain_contrib(x, imf_cp, method = "ao", type = "annual", extra = "total") |>
    round(3)
#> Time Series:
#> Start = 2011 
#> End = 2013 
#> Frequency = 1 
#>           A       B Total
#> 2011  2.871  -2.139 0.732
#> 2012  5.687  -4.779 0.909
#> 2013 12.827 -10.499 2.328
```

## One-quarter overlap

``` r

x_oqo <- chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
                         output = "measure")
chain_contrib(x_oqo, imf_cp, method = "oqo", type = "period", pi = imf_pi,
              extra = c("total", "residual")) |>
    round(3)
#>             A      B  Total Residual
#> 2011 Q1    NA     NA     NA       NA
#> 2011 Q2 0.702 -0.808 -0.106        0
#> 2011 Q3 0.876 -0.838  0.038        0
#> 2011 Q4 0.592 -0.281  0.311        0
#> 2012 Q1 0.226 -0.058  0.167        0
#> 2012 Q2 1.817 -1.835 -0.017        0
#> 2012 Q3 2.673 -2.158  0.516        0
#> 2012 Q4 6.615 -5.701  0.913        0
#> 2013 Q1 1.970 -1.177  0.792        0
#> 2013 Q2 3.440 -2.887  0.553        0
#> 2013 Q3 2.136 -2.156 -0.020        0
#> 2013 Q4 0.966 -1.109 -0.143        0
```

The overlap quarter is valued at the average prices of the year, as in
the manual
([`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)):
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)
needs the price indices `pi` to do so (or `cp` already valued at these
prices). With the one-quarter overlap technique, the contributions to
the annual growth are only available from the second year (the annual
sum of the base year is not defined).

## Correspondence with the manual

- annual overlap: `type = "period"` and `type = "annual"` are the
  equations (29) (quarters 2 to 4 and annual data) and (30) (first
  quarter) of the paragraphs 8.86-8.87, and `type = "yoy"` is the
  equation (31) of the paragraph 8.88. The example 8.9 is reproduced by
  the tests of the package;
- one-quarter overlap: the manual (footnote 35) applies the same
  formulas with the annual deflators, but the contributions are then not
  exactly additive. The package provides this variant with
  `method = "ao"` applied to the one-quarter overlap measures, and an
  exactly additive version with `method = "oqo"`:

``` r

x_oqo <- chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
                         output = "measure")
# Formulas of the manual (annual deflators)
chain_contrib(x_oqo, imf_cp, method = "ao", extra = "residual") |> round(4)
#>              A       B Residual
#> 2011 Q1     NA      NA       NA
#> 2011 Q2 0.7019 -0.8075   0.0000
#> 2011 Q3 0.8759 -0.8384   0.0000
#> 2011 Q4 0.5916 -0.2807   0.0000
#> 2012 Q1 0.2483 -0.0414  -0.0396
#> 2012 Q2 1.8178 -1.8353   0.0000
#> 2012 Q3 2.6745 -2.1586  -0.0002
#> 2012 Q4 6.6174 -5.7037  -0.0004
#> 2013 Q1 2.0792 -1.0746  -0.2124
#> 2013 Q2 3.4476 -2.8932  -0.0012
#> 2013 Q3 2.1408 -2.1609   0.0000
#> 2013 Q4 0.9681 -1.1116   0.0003
# Deflators of the overlap period (valued at the average prices of the year)
chain_contrib(x_oqo, imf_cp, method = "oqo", pi = imf_pi,
              extra = "residual") |> round(4)
#>              A       B Residual
#> 2011 Q1     NA      NA       NA
#> 2011 Q2 0.7019 -0.8075        0
#> 2011 Q3 0.8759 -0.8384        0
#> 2011 Q4 0.5916 -0.2807        0
#> 2012 Q1 0.2255 -0.0582        0
#> 2012 Q2 1.8171 -1.8346        0
#> 2012 Q3 2.6734 -2.1578        0
#> 2012 Q4 6.6148 -5.7014        0
#> 2013 Q1 1.9696 -1.1774        0
#> 2013 Q2 3.4403 -2.8871        0
#> 2013 Q3 2.1363 -2.1563        0
#> 2013 Q4 0.9660 -1.1093        0
```

- a variable that can be negative, zero or positive (changes in
  inventories) is treated residually (paragraph 8.90): its contribution
  is the difference between the contribution of the aggregate that
  includes it and the contributions of the other components.

## Quarterly Fisher indices

The paragraph 8.89 gives the contributions to the percent change of a
quarterly Fisher index.
[`fisher_contrib()`](https://aqlt.github.io/chainlink/reference/fisher_contrib.md)
takes the current prices of all the components and their price indices
over the previous quarter
([`pi_py2pp()`](https://aqlt.github.io/chainlink/reference/pi_py2pp.md)
converts price indices over the previous year):

``` r

ep8.4 <- pi_py2pp(imf_pi)
fisher_contrib(imf_cp, ep8.4, extra = c("total", "residual")) |> round(3)
#>             A      B  Total Residual
#> 2010 Q1    NA     NA     NA       NA
#> 2010 Q2    NA     NA     NA       NA
#> 2010 Q3    NA     NA     NA       NA
#> 2010 Q4    NA     NA     NA       NA
#> 2011 Q1 1.767 -1.031  0.737        0
#> 2011 Q2 0.717 -0.795 -0.078        0
#> 2011 Q3 0.900 -0.822  0.078        0
#> 2011 Q4 0.607 -0.275  0.331        0
#> 2012 Q1 0.232 -0.057  0.175        0
#> 2012 Q2 1.860 -1.800  0.060        0
#> 2012 Q3 2.713 -2.130  0.583        0
#> 2012 Q4 6.699 -5.632  1.068        0
#> 2013 Q1 1.951 -1.195  0.756        0
#> 2013 Q2 3.433 -2.895  0.538        0
#> 2013 Q3 2.119 -2.182 -0.063        0
#> 2013 Q4 0.955 -1.130 -0.175        0
```

With $`x_i^t`$ the current price value of the component $`i`$ in period
$`t`$, $`z^t`$ the one of the aggregate, $`r_i = p_i^t / p_i^{t-1}`$ the
price index of the component over the previous period and $`F`$ the
Fisher volume index of the aggregate (previous period = 1), the
contribution of the component $`i`$ is
``` math
C_i^t = 100\, \frac{\dfrac{z^t}{z^{t-1}} \left(\dfrac{x_i^t}{r_i} - x_i^{t-1}\right)
+ F \left(x_i^t - x_i^{t-1} r_i\right)}
{z^t + F \sum_j x_j^{t-1} r_j}.
```

This is the equation (32) of the manual. The decomposition is exact: the
residual is zero up to numerical errors. As printed in the manual, the
equation has the ratio $`z^{t-1} / z^t`$ in the first term and
$`x_i^{t-1} / r_i`$ in the second one; with these ratios, the
contributions do not add up to the percent change. The version
implemented uses $`z^t / z^{t-1}`$ and $`x_i^{t-1} r_i`$ (consistent
with the denominator). The adjustments that some countries add to the
quarterly contributions (benchmarking of the quarterly indices, annual
rates) are not done.

## Non-additivity and residual

Two different things must not be mixed up:

- the chain volume measures are not additive: the chain measure of the
  total is not the sum of the chain measures of the components.
  [`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md)
  returns $`D_t = \sum_i x_{i,t} - z_t`$ (or $`100\, D_t / z_t`$ with
  `relative = TRUE`). It is zero in the base year and, with the annual
  overlap, in the year after;
- the contributions take this into account and add up to the growth of
  the total. The residual (`extra = "residual"`) is therefore zero if
  the data are fully consistent, i.e. if the annual price indices are
  exactly those of the quarterly data. In the example of the manual,
  they are not (the residual is small, below 0.001 percentage point).

``` r

chain_discrepancy(x) |> round(3)
#>        Qtr1   Qtr2   Qtr3   Qtr4
#> 2011  0.000  0.000  0.000  0.000
#> 2012 -0.173 -0.457 -0.837 -1.809
#> 2013 -3.080 -4.004 -4.630 -4.932
chain_discrepancy(x, relative = TRUE) |> round(3)
#>        Qtr1   Qtr2   Qtr3   Qtr4
#> 2011  0.000  0.000  0.000  0.000
#> 2012 -0.046 -0.120 -0.220 -0.470
#> 2013 -0.793 -1.025 -1.185 -1.264
```

## Monthly data

The functions use the frequency of the series. As an illustration, each
quarter of the data of the example is spread over three months (the
contributions are then non-zero only for the first month of each
quarter, when the quarter changes):

``` r

spread <- function(a, scale = 1) {
    m <- as.matrix(a)
    res <- ts(m[rep(seq_len(nrow(m)), each = 3), , drop = FALSE] * scale,
              start = c(start(a)[1], 1), frequency = 12)
    colnames(res) <- colnames(a)
    res
}
cp_m <- spread(imf_cp, 1 / 3)
pi_m <- spread(imf_pi)
x_m <- chain_laspeyres(cp_m, pi_m, method = "ao", base_year = 2010,
                       output = "measure")
chain_contrib(x_m, cp_m, method = "ao") |>
    window(start = c(2011, 1), end = c(2011, 8)) |>
    round(3)
#>              A      B
#> Jan 2011    NA     NA
#> Feb 2011 0.000  0.000
#> Mar 2011 0.000  0.000
#> Apr 2011 0.702 -0.808
#> May 2011 0.000  0.000
#> Jun 2011 0.000  0.000
#> Jul 2011 0.876 -0.838
#> Aug 2011 0.000  0.000
```

## Variables that change sign

Growth rates and chain volume measures are meaningless for a variable
that can be negative, zero or positive, such as changes in inventories
(paragraph 8.56 of the manual). Two solutions:

- contributions are calculated residually (paragraph 8.90): the
  contribution of the variable is the difference between the
  contribution of the aggregate that includes it and the contributions
  of the other components;
- a pseudo chain volume series is derived (paragraphs 8.57-8.58): the
  variable is written as the difference of two series that only take
  positive values (closing minus opening inventories, exports minus
  imports), each of them is chain-linked separately, and the chain
  volume series is their difference.
  [`chain_pseudo()`](https://aqlt.github.io/chainlink/reference/chain_pseudo.md)
  does it, from the current prices and the price indices of the two
  series (the two products of the example below only stand in for them):

``` r

chain_pseudo(imf_cp[, "A"], imf_pi[, "A"],
             imf_cp[, "B"], imf_pi[, "B"], base_year = 2010) |> round(1)
#>       Qtr1  Qtr2  Qtr3  Qtr4
#> 2011 -64.5 -58.8 -52.4 -49.1
#> 2012 -48.0 -34.2 -16.0  30.8
#> 2013  42.8  67.2  84.0  92.1
```

## Change of the reference year

[`chain_rebase()`](https://aqlt.github.io/chainlink/reference/chain_rebase.md)
changes the reference year of an index or of a measure. With $`b`$ the
new reference year and $`\bar{I}_b`$ the average of the index over its
periods, the rebased index is $`100\, I_t / \bar{I}_b`$; a measure is
multiplied by $`cp_b / x_b`$ (annual sums of the current prices and of
the measure in year $`b`$). The growth rates are unchanged.

``` r

chain_laspeyres(imf_cp, imf_pi, base_year = 2010) |>
    chain_rebase(base_year = 2012) |>
    round(2)
#>              A      B  Total
#> 2011 Q1  86.14 111.33  99.08
#> 2011 Q2  87.60 109.80  98.98
#> 2011 Q3  89.42 108.20  99.01
#> 2011 Q4  90.65 107.67  99.32
#> 2012 Q1  91.11 107.56  99.53
#> 2012 Q2  94.81 103.99  99.51
#> 2012 Q3 100.26  99.80 100.02
#> 2012 Q4 113.82  88.66 100.94
#> 2013 Q1 117.83  86.29 101.95
#> 2013 Q2 124.89  80.44 102.52
#> 2013 Q3 129.30  76.05 102.49
#> 2013 Q4 131.30  73.79 102.35
```
