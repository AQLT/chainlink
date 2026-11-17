# Non-additivity of chain-linked volume measures

Chain-linked volume measures are not additive: the chain volume measure
of the total differs from the sum of the chain volume measures of its
components (except in the base year and, with the annual overlap
technique, in the year after the base year). This function returns the
difference, with the sign of the column "Discrepancies" of the examples
8.6 and 8.7 of the manual: the sum of the components minus the total,
\$\$D_t = \sum_i x\_{i,t} - z_t,\$\$ with \\x\_{i,t}\\ the chain volume
measures of the components and \\z_t\\ the one of the total (\\100\\ D_t
/ z_t\\ with `relative = TRUE`).

## Usage

``` r
chain_discrepancy(vo, vo_total = NULL, relative = FALSE)
```

## Arguments

- vo:

  Chain volume measures (in monetary terms) of the components (`ts` or
  `mts`). If `vo_total` is `NULL`, the last column is the total (as
  returned by
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)
  with `output = "measure"`).

- vo_total:

  Chain volume measure of the total (`ts`).

- relative:

  Boolean: if `TRUE`, the discrepancy is expressed in percent of the
  chain volume measure of the total.

## Value

A `ts`: sum of the chain volume measures of the components minus the
chain volume measure of the total.

## References

International Monetary Fund (2018), *Quarterly National Accounts Manual
(2017 Edition)*, chapter 8 "Price and Volume Measures", Washington, DC.
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
.

## See also

[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)

## Examples

``` r
x <- chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
           output = "measure")
chain_discrepancy(x)
#>               Qtr1          Qtr2          Qtr3          Qtr4
#> 2011  0.000000e+00  0.000000e+00 -1.136868e-13 -5.684342e-14
#> 2012 -1.731737e-01 -4.568221e-01 -8.374144e-01 -1.808633e+00
#> 2013 -3.080118e+00 -4.003720e+00 -4.630056e+00 -4.931551e+00
chain_discrepancy(x, relative = TRUE)
#>               Qtr1          Qtr2          Qtr3          Qtr4
#> 2011  0.000000e+00  0.000000e+00 -3.012192e-14 -1.501428e-14
#> 2012 -4.564664e-02 -1.204342e-01 -2.196390e-01 -4.700788e-01
#> 2013 -7.925857e-01 -1.024582e+00 -1.185103e+00 -1.264084e+00
```
