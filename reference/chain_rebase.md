# Change the reference year of chain-linked series

Rescale a chain index so that the average of the new reference year is
100, or a chain volume measure so that the annual sum of the new
reference year is its annual current prices. With \\b\\ the new
reference year, \$\$I'\_t = 100\\ \frac{I_t}{\bar{I}\_b}, \qquad x'\_t =
x_t\\ \frac{cp_b}{x_b},\$\$ where \\\bar{I}\_b\\ is the average of the
index over the periods of year \\b\\, and \\cp_b\\ and \\x_b\\ the
annual sums of the current prices and of the measure.

## Usage

``` r
chain_rebase(x, base_year, cp = NULL)
```

## Arguments

- x:

  Chain index (if `cp` is `NULL`) or chain volume measure (in monetary
  terms) (`ts` or `mts`).

- base_year:

  New reference year.

- cp:

  Current prices, same structure as `x`. If provided, `x` is a chain
  volume measure.

## Value

A `ts` (or `mts`) with the same structure as `x`.

## Details

The series must cover all the periods of the new reference year. The
contributions computed by
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)
must be computed from series whose reference year is the one used to
build them (the year before the start of the series, by default).

## Examples

``` r
x <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010)
chain_rebase(x, base_year = 2012)
#>                 A         B     Total
#> 2011 Q1  86.14286 111.33257  99.08231
#> 2011 Q2  87.60136 109.79691  98.97763
#> 2011 Q3  89.41961 108.20416  99.01475
#> 2011 Q4  90.64819 107.67065  99.32259
#> 2012 Q1  91.10725 107.55774  99.52808
#> 2012 Q2  94.81237 103.99074  99.51068
#> 2012 Q3 100.26266  99.79607 100.02382
#> 2012 Q4 113.81772  88.65546 100.93742
#> 2013 Q1 117.82982  86.28980 101.95148
#> 2013 Q2 124.89324  80.44313 102.51551
#> 2013 Q3 129.30358  76.05220 102.49498
#> 2013 Q4 131.29753  73.79378 102.34814
x_measure <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010,
               output = "measure")
cp_all <- ts(cbind(as.matrix(imf_cp), Total = rowSums(imf_cp)),
       start = start(imf_cp), frequency = frequency(imf_cp))
chain_rebase(x_measure, base_year = 2012, cp = cp_all)
#>                A        B    Total
#> 2011 Q1 163.4561 214.1760 378.6183
#> 2011 Q2 166.2236 211.2218 378.2183
#> 2011 Q3 169.6737 208.1578 378.3601
#> 2011 Q4 172.0049 207.1314 379.5365
#> 2012 Q1 172.8760 206.9142 380.3217
#> 2012 Q2 179.9065 200.0522 380.2552
#> 2012 Q3 190.2484 191.9827 382.2160
#> 2012 Q4 215.9691 170.5509 385.7071
#> 2013 Q1 223.5821 166.0000 389.5821
#> 2013 Q2 236.9849 154.7525 391.7374
#> 2013 Q3 245.3535 146.3054 391.6590
#> 2013 Q4 249.1371 141.9608 391.0978
```
