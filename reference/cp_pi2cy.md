# Values at the average prices of the year

Quarterly (or monthly) values of each period valued at the weighted
average prices of its own year (the column "Current Year's Prices" of
the example 8.7 of the IMF QNA Manual). They are used by the one-quarter
overlap technique: the overlap period is valued at the average prices of
the year, and not at its own current prices.

## Usage

``` r
cp_pi2cy(cp, pi)
```

## Arguments

- cp:

  Current prices (`ts` or `mts`).

- pi:

  Price indices over the previous year (previous year average = 100),
  with the same structure as `cp`.

## Value

A `ts` (or `mts`) with the structure of `cp` (extended to complete
years). It is `NA` for the years without price indices (e.g. the
reference year).

## Details

The value is the volume measure at the prices of the previous year,
multiplied by the annual price index of the year \\y\\ (the annual
current prices divided by the annual sum of the volume measures at the
prices of the previous year, see
[`pi_annual()`](https://aqlt.github.io/chainlink/reference/pi_annual.md)):
\$\$cy_t = \frac{100\\ cp_t}{pi_t} \times \frac{pi_y}{100}, \qquad pi_y
= 100 \times \frac{\sum\_{q \in y} cp_q}{\sum\_{q \in y} 100\\ cp_q /
pi_q},\$\$ so that the annual sum of \\cy_t\\ is the annual current
price value.

## References

International Monetary Fund (2018), *Quarterly National Accounts Manual
(2017 Edition)*, chapter 8 "Price and Volume Measures", Washington, DC.
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
.

## See also

[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md),
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md),
[`pi_annual()`](https://aqlt.github.io/chainlink/reference/pi_annual.md)

## Examples

``` r
cp_pi2cy(imf_cp, imf_pi)
#>                A        B
#> 2010 Q1       NA       NA
#> 2010 Q2       NA       NA
#> 2010 Q3       NA       NA
#> 2010 Q4       NA       NA
#> 2011 Q1 160.6907 217.7970
#> 2011 Q2 163.4113 214.7928
#> 2011 Q3 166.8031 211.6770
#> 2011 Q4 169.0949 210.6333
#> 2012 Q1 172.8760 206.9142
#> 2012 Q2 179.9065 200.0522
#> 2012 Q3 190.2484 191.9827
#> 2012 Q4 215.9691 170.5509
#> 2013 Q1 222.1172 167.7939
#> 2013 Q2 235.4322 156.4248
#> 2013 Q3 243.7460 147.8865
#> 2013 Q4 247.5047 143.4949
```
