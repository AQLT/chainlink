# Pseudo chain volume series of a variable that changes sign

Growth rates and chain volume measures cannot be calculated for
variables that can take positive, negative and zero values, such as
changes in inventories or the external trade balance (IMF QNA Manual,
paragraph 8.56). The solution of the 2008 SNA (paragraphs 8.57 and 8.58)
is to write the variable as the difference of two series that only take
positive values, to chain-link each of them separately, and to take the
difference of the chain volume measures. For instance, changes in
inventories are closing inventories minus opening inventories, and the
trade balance is exports minus imports.

## Usage

``` r
chain_pseudo(
  cp_pos,
  pi_pos,
  cp_neg,
  pi_neg,
  method = c("ao", "oqo"),
  base_year = NULL
)
```

## Arguments

- cp_pos:

  Current prices of the series that takes positive values (`ts`; an
  `mts` is the aggregate of its columns): closing inventories, exports,
  etc.

- pi_pos:

  Price indices of `cp_pos` over the previous year (previous year
  average = 100), with the same structure.

- cp_neg, pi_neg:

  The same for the series that is subtracted (opening inventories,
  imports, etc.).

- method:

  Chain-linking technique: `"ao"` for annual overlap, `"oqo"` for
  one-quarter overlap (for monthly series, the overlap period is the
  last month of the year).

- base_year:

  Reference year (index = 100). By default, the year before the start of
  `vo` (or the first year of `cp`, if later).

## Value

A `ts`: the chain volume measure (in monetary terms) of `cp_pos` minus
the one of `cp_neg`.

## Details

With \\x^{+}\_t\\ and \\x^{-}\_t\\ the chain volume measures of the two
series
([`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)),
the pseudo chain volume series is \\x^{+}\_t - x^{-}\_t\\.

The result is a pseudo chain volume series: it is the difference of two
chained components, which are not additive by construction. It is
expressed in monetary terms (its growth rates are meaningless). The
measure of each series is that of
[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md).

If the two series are already chain-linked (in monetary terms, with the
same reference year), their simple difference is the pseudo chain volume
series.

## References

International Monetary Fund (2018), *Quarterly National Accounts Manual
(2017 Edition)*, chapter 8 "Price and Volume Measures", Washington, DC.
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
.

## See also

[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md),
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)

## Examples

``` r
# Illustration: the two products of the example 8.2 stand in for closing and
# opening inventories
chain_pseudo(imf_cp[, "A"], imf_pi[, "A"],
       imf_cp[, "B"], imf_pi[, "B"], base_year = 2010)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 2011 -64.54248 -58.84171 -52.37369 -49.08110
#> 2012 -48.02250 -34.20406 -15.96712  30.79554
#> 2013  42.78602  67.23583  83.97240  92.08181
```
