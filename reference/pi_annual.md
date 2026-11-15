# Annual price indices

Annual price indices (previous year average = 100) derived from
quarterly or monthly price indices over the previous year.

## Usage

``` r
pi_annual(pi, cp = NULL, method = c("weighted", "mean"))
```

## Arguments

- pi:

  Quarterly or monthly price indices over the previous year (previous
  year average = 100), `ts` or `mts`.

- cp:

  Current prices, with the same structure as `pi`. Needed for
  `method = "weighted"`.

- method:

  `"weighted"` (default) for the weighted average of the price indices
  (implicit annual price index), `"mean"` for their simple average.

## Value

An annual `ts` (or `mts`) with the structure of `pi`. It is `NA` for the
incomplete years and the years without price indices (e.g. the reference
year).

## Details

With `method = "weighted"` (the default), the annual price index is the
weighted average of the sub-annual price indices, the weights being the
volumes at the prices of the previous year (\\cp / pi \times 100\\): it
is the implicit price index, i.e. the annual current prices divided by
the annual sum of the sub-annual volumes at the prices of the previous
year, \$\$pi_y = 100 \times \frac{\sum_q cp_q}{\sum_q cp_q / pi_q \times
100}.\$\$ It is consistent with the sub-annual data (as the unit value
in example 8.1 of the IMF QNA Manual): the annual volume at the prices
of the previous year is the annual sum of the sub-annual ones. This is
what is used in examples 8.3, 8.8 and 8.9 of the manual, and by
[`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md).

With `method = "mean"`, the annual price index is the simple average of
the sub-annual price indices: the annual volumes are then not exactly
the annual sums of the sub-annual ones.

The sub-annual price indices themselves are normalised on the simple
average of the previous year (see
[`pi_py2pp()`](https://aqlt.github.io/chainlink/reference/pi_py2pp.md)):
this is not affected by `method`.

## See also

[`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md),
[`pi_py2pp()`](https://aqlt.github.io/chainlink/reference/pi_py2pp.md)

## Examples

``` r
pi_annual(imf_pi, imf_cp)
#> Time Series:
#> Start = 2010 
#> End = 2013 
#> Frequency = 1 
#>              A         B
#> 2010        NA        NA
#> 2011 102.63273  98.50115
#> 2012 101.72096  98.33747
#> 2013  99.34479 101.08064
pi_annual(imf_pi, method = "mean")
#> Time Series:
#> Start = 2010 
#> End = 2013 
#> Frequency = 1 
#>            A       B
#> 2010      NA      NA
#> 2011 102.625  98.500
#> 2012 101.750  98.375
#> 2013  99.375 101.125
# Annual Fisher volume index (previous year = 100)
fisher(stats::aggregate(imf_cp), pi_annual(imf_pi, imf_cp))
#> Time Series:
#> Start = 2011 
#> End = 2013 
#> Frequency = 1 
#> [1] 100.7851 100.9985 102.2264
```
