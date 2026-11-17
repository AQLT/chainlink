# Un-chain and aggregate chain-linked volume measures

Indirect seasonal adjustment of chain-linked Laspeyres-type series (ESS
Guidelines on Seasonal Adjustment, item 5.6): the seasonally adjusted
components are un-chained, aggregated, and the aggregate is chain-linked
again. `chain_unchain()` un-chains chain volume measures and
`chain_aggregate()` derives the chain volume measure of the aggregate of
components, whatever they are (seasonally adjusted components, for
instance).

## Usage

``` r
chain_unchain(
  x,
  cp,
  method = c("ao", "oqo"),
  base_year = NULL,
  pi = NULL,
  overlap_prices = c("year_prices", "current_prices")
)

chain_aggregate(
  x,
  cp,
  method = c("ao", "oqo"),
  base_year = NULL,
  output = c("index", "measure", "both"),
  pi = NULL,
  cp_total = NULL,
  overlap_prices = c("year_prices", "current_prices")
)
```

## Arguments

- x:

  Chain volume measures (in monetary terms) of the components (`ts` or
  `mts`), as returned by
  [`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)
  or
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)
  with `output = "measure"`, or their seasonally adjusted version.

- cp:

  Current prices of the components (same number of variables as `x`). It
  must cover the reference year.

- method:

  Chain-linking technique of `x`: `"ao"` or `"oqo"`.

- base_year:

  Reference year of the chain measures. By default, the year before the
  start of `x` (or the first year of `cp`, if later).

- pi:

  Price indices of the components over the previous year (previous year
  average = 100), needed for `method = "oqo"` with
  `overlap_prices = "year_prices"`.

- overlap_prices:

  Only for `method = "oqo"`: prices used to value the overlap period,
  `"year_prices"` (default) or `"current_prices"`; it must be the one
  used to compute `x` (see
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)).

- output:

  (`chain_aggregate()` only) Chain index (the default), chain volume
  measure or both (see
  [`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)).

- cp_total:

  (`chain_aggregate()` only) Current prices of the aggregate. By
  default, the sum of `cp`.

## Value

`chain_unchain()`: a `ts` (or `mts`) with the structure of `x`: the
volume of each period at the (average) prices of the previous year, in
monetary terms. `chain_aggregate()`: a `ts` (see
[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)
for `output = "both"`).

## Details

To derive the seasonally adjusted aggregate of seasonally adjusted
chain-linked components:

1.  seasonally adjust the chain volume measures of the components
    (outside the package);

2.  un-chain the seasonally adjusted components: `chain_unchain()`
    returns the volume at the prices of the previous year, which is
    additive within each year (the sum of the components is the volume
    of the aggregate at the prices of the previous year);

3.  aggregate them and chain-link the aggregate (again with the same
    technique);

4.  re-reference it to the reference year.

With \\x_t\\ the chain volume measure of a component, \\b\\ the
reference year, \\f\\ the frequency and \\\Lambda_y\\ the chain level of
year \\y\\ (see
[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)),
the volume at the prices of the previous year is \$\$x^{py}\_t =
\frac{x_t}{cp_b / f} \times \frac{o\_{y(t)-1}}{\Lambda\_{y(t)-1}},\$\$
where \\o_y\\ is the value of the reference of year \\y\\: the annual
current prices divided by \\f\\ (annual overlap) or the value of the
overlap period (one-quarter overlap). The volume index of the aggregate
is then \\100 \sum_i x^{py}\_{i,t} / \sum_i o\_{i,y(t)-1}\\,
chain-linked with
[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md).

`chain_aggregate()` does the steps 2 to 4. The reference year of the
result is `base_year` and its annual current prices are those of `cp`,
so that the seasonally adjusted aggregate is normalised to the
unadjusted data of the reference year. The annual links are those of the
series that are chained or un-chained: `chain_unchain()` is the exact
inverse of
[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)
with `output = "measure"`, and `chain_aggregate()` applied to the
unadjusted chain volume measures of the components gives the chain
volume measure of their total
([`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)).

The annual totals of the seasonally adjusted data are not forced to be
equal to the annual totals of the unadjusted data (an option of the
guidelines when users require it and the unadjusted data are additive).
This approach only concerns Laspeyres-type series: for other
chain-linked indices, only the direct approach is feasible.

With the one-quarter overlap technique, the overlap period is valued at
the average prices of the year (see
[`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)),
hence the price indices `pi`, or at its own current prices
(`overlap_prices = "current_prices"`, `pi` is then not needed). The
un-chaining of the first year after the reference year (or of the first
year of `x` if the reference year is not before it) needs the level of
the previous year: if the reference year is inside the series, the first
year is `NA`.

## References

International Monetary Fund (2018), *Quarterly National Accounts Manual
(2017 Edition)*, chapter 8 "Price and Volume Measures", Washington, DC.
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
.

Eurostat (2015), *ESS Guidelines on Seasonal Adjustment (2015 Edition)*,
Luxembourg, Publications Office of the European Union.
[doi:10.2785/317290](https://doi.org/10.2785/317290) .

## See also

[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md),
[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)

## Examples

``` r
x <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010, output = "measure")
# Volumes at the prices of the previous year (additive within each year)
chain_unchain(x[, c("A", "B")], imf_cp, base_year = 2010)
#>                A        B
#> 2011 Q1 156.5686 221.1111
#> 2011 Q2 159.2195 218.0612
#> 2011 Q3 162.5243 214.8980
#> 2011 Q4 164.7573 213.8384
#> 2012 Q1 169.9512 210.4124
#> 2012 Q2 176.8627 203.4343
#> 2012 Q3 187.0297 195.2284
#> 2012 Q4 212.3153 173.4343
#> 2013 Q1 223.5821 166.0000
#> 2013 Q2 236.9849 154.7525
#> 2013 Q3 245.3535 146.3054
#> 2013 Q4 249.1371 141.9608
# Aggregate of the components: the chain volume measure of the total
chain_aggregate(x[, c("A", "B")], imf_cp, base_year = 2010, output = "measure")
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2011 377.6797 377.2807 377.4222 378.5957
#> 2012 379.3789 379.3126 381.2686 384.7510
#> 2013 388.6164 390.7664 390.6881 390.1284
```
