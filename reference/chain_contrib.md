# Contributions to percent change of chain-linked volume measures

Exact contributions of the components to the percent change of a total
chain-linked with the annual overlap (`"ao"`) or the one-quarter overlap
(`"oqo"`) technique (IMF QNA Manual, chapter 8, example 8.9).

## Usage

``` r
chain_contrib(
  vo,
  cp,
  vo_total = NULL,
  cp_total = NULL,
  method = c("ao", "oqo"),
  type = c("period", "yoy", "annual"),
  base_year = NULL,
  extra = NULL,
  pi = NULL,
  overlap_prices = c("year_prices", "current_prices")
)
```

## Arguments

- vo:

  Chain volume measures (in monetary terms) of the components (`ts` or
  `mts`), as returned by
  [`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)
  or
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)
  with `output = "measure"`. If `vo_total` is `NULL`, the last column of
  `vo` is the total (as returned by
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)).

- cp:

  Current prices of the components (same number of columns as `vo`,
  without the total). It must cover the base year.

- vo_total:

  Chain volume measure of the total (`ts`). It cannot be deduced from
  `vo` because chain measures are not additive. By default (`NULL`), the
  last column of `vo` is used (and the last column of `cp` is the total
  of the current prices, if `cp` has one more column than the
  components).

- cp_total:

  Current prices of the total. By default, the sum of `cp` (only valid
  if `cp` contains all the components).

- method:

  Chain-linking technique used to compute `vo` and `vo_total`: `"ao"`
  (annual overlap) or `"oqo"` (one-quarter overlap, built as in the
  manual: see
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)).

- type:

  Growth to decompose: `"period"` (default) for the growth over the
  previous period (quarter or month), `"yoy"` for the growth over the
  same period of the previous year, `"annual"` for the growth of the
  annual sums. For `method = "oqo"`, the contributions to annual growth
  are only defined from the second year (the annual sum of the base year
  is not defined).

- base_year:

  Reference year of the chain measures. By default, the year before the
  start of `vo` (or the first year of `cp`, if later).

- extra:

  Additional columns: `"total"` adds the growth of the total, and
  `"residual"` the difference between this growth and the sum of the
  contributions (non-additivity). Default: none.

- pi:

  Price indices of the components over the previous year (previous year
  average = 100), needed for `method = "oqo"` to value the overlap
  period at the average prices of the year (see
  [`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)).
  If `NULL`, `cp` must already be valued at the average prices of the
  year
  ([`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)).

- overlap_prices:

  Only for `method = "oqo"`: prices used to value the overlap period
  when `vo` was computed, `"year_prices"` (average prices of the year,
  default) or `"current_prices"` (own current prices): see
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md).
  With `"current_prices"`, `cp` is used as it is and `pi` is not needed.

## Value

A `ts` (or `mts`) of contributions, in percentage points, with the same
columns as `vo` (followed by `Total` and/or `Residual`). It has the span
of `vo` (extended to complete years), with `NA` when a contribution
cannot be computed (e.g. the first periods).

## Details

Let \\x_t\\ be the chain volume measure of a component and \\z_t\\ the
one of the total. Within year \\y\\, the total is exactly \\z_t = \sum_i
\rho\_{i,y-1} x\_{i,t}\\, where \\\rho\_{i,y-1}\\ is the relative price
(price of the component / price of the total) of the previous year:

- `method = "ao"`: \\\rho_y = (cp^x_y / x_y) / (cp^z_y / z_y)\\ with
  annual sums;

- `method = "oqo"`: the same ratio computed on the overlap period (the
  last period of the year), with the values at the average prices of the
  year
  ([`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)).
  In the reference year, the ratio is 1 (the first year is linked with
  the annual overlap technique).

The contribution to the growth between a period \\s\\ and a period \\t\\
(previous period, same period of the previous year, or previous year) is
\$\$100 \left\[ \frac{(x_t - x_s)\rho\_{y(t)-1}}{z_s} +
\left(\frac{x_s}{z_s} - a\_{y(t)-1}\right)(\rho\_{y(t)-1} -
\rho\_{y(s)-1})\right\]\$\$ where \\a_y = x_y / z_y\\ (annual overlap)
or the share of the overlap period (one-quarter overlap). The second
term is zero when \\s\\ and \\t\\ are in the same year, and for the
annual overlap technique it is also zero for annual growth. For the
growth over the previous period with the annual overlap technique, it
gives the formulas of the example 8.9. Contributions add up to the
growth of the total (up to the inconsistencies of the data: see
`extra = "residual"`).

For the annual overlap technique, `type = "period"` and
`type = "annual"` are the equations (29) and (30) of the manual
(paragraphs 8.86 and 8.87, example 8.9) and `type = "yoy"` is the
equation (31) (paragraph 8.88).

For the one-quarter overlap technique, the manual (footnote 35) applies
the same formulas with the annual deflators, but the contributions are
then not exactly additive. With `method = "oqo"`, the deflators of the
overlap period are used, so that contributions add up exactly. The
formulas of the manual can be obtained with `method = "ao"` applied to
the one-quarter overlap measures.

As recommended by the manual (paragraph 8.90), the contribution of a
variable that can be negative, zero or positive (such as changes in
inventories) should be calculated residually: the difference between the
contribution of the aggregate that includes it and the contributions of
the other components.

Series can be monthly: the "overlap period" is then the last month of
the year.

## See also

[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md),
[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md),
[`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md),
[`fisher_contrib()`](https://aqlt.github.io/chainlink/reference/fisher_contrib.md)

## Examples

``` r
# Chain volume measures of the components and of the total (last column)
x <- chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
           output = "measure")
# Contributions to the growth over the previous quarter
chain_contrib(x, imf_cp, method = "ao", extra = c("total", "residual"))
#>                 A           B       Total      Residual
#> 2011 Q1        NA          NA          NA            NA
#> 2011 Q2 0.7018869 -0.80753250 -0.10564556  1.110223e-15
#> 2011 Q3 0.8759418 -0.83843806  0.03750373  2.386980e-14
#> 2011 Q4 0.5916476 -0.28074005  0.31090759 -1.265654e-14
#> 2012 Q1 0.2482781 -0.04138817  0.20688994 -3.441691e-14
#> 2012 Q2 1.8170839 -1.83456773 -0.01748383  1.110223e-15
#> 2012 Q3 2.6734251 -2.15776489  0.51566023 -1.332268e-15
#> 2012 Q4 6.6147888 -5.70140470  0.91338411  7.993606e-15
#> 2013 Q1 2.0816590 -1.07701699  1.00464199  3.774758e-15
#> 2013 Q2 3.4403109 -2.88707439  0.55323650 -3.730349e-14
#> 2013 Q3 2.1362808 -2.15630586 -0.02002510  2.042810e-14
#> 2013 Q4 0.9660243 -1.10929020 -0.14326595 -5.773160e-15
# Contributions to the growth over the same quarter of the previous year
chain_contrib(x, imf_cp, method = "ao", type = "yoy")
#>                 A          B
#> 2011 Q1        NA         NA
#> 2011 Q2        NA         NA
#> 2011 Q3        NA         NA
#> 2011 Q4        NA         NA
#> 2012 Q1  2.419471  -1.969565
#> 2012 Q2  3.547655  -3.009097
#> 2012 Q3  5.357150  -4.338040
#> 2012 Q4 11.409099  -9.783259
#> 2013 Q1 13.260886 -10.825998
#> 2013 Q2 14.970646 -11.951039
#> 2013 Q3 14.419294 -11.948717
#> 2013 Q4  8.707144  -7.309522
# Contributions to the growth of the annual sums
chain_contrib(x, imf_cp, method = "ao", type = "annual")
#> Time Series:
#> Start = 2011 
#> End = 2013 
#> Frequency = 1 
#>              A          B
#> 2011  2.871313  -2.139421
#> 2012  5.687434  -4.778567
#> 2013 12.826798 -10.499269

# One-quarter overlap
x_oqo <- chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
             output = "measure")
chain_contrib(x_oqo, imf_cp, method = "oqo", type = "yoy", pi = imf_pi)
#>                 A          B
#> 2011 Q1        NA         NA
#> 2011 Q2        NA         NA
#> 2011 Q3        NA         NA
#> 2011 Q4        NA         NA
#> 2012 Q1  2.396658  -1.986400
#> 2012 Q2  3.524103  -3.025228
#> 2012 Q3  5.332544  -4.353307
#> 2012 Q4 11.381924  -9.796196
#> 2013 Q1 13.147118 -10.927676
#> 2013 Q2 14.849443 -12.046512
#> 2013 Q3 14.294159 -12.039103
#> 2013 Q4  8.581168  -7.396810
# One-quarter overlap, overlap quarter at its own current prices
x_cp <- chain_laspeyres(
  imf_cp, imf_pi, method = "oqo", base_year = 2010,
   overlap_prices = "current_prices", output = "measure"
)
chain_contrib(x_cp, imf_cp, method = "oqo", type = "yoy",
        overlap_prices = "current_prices")
#>                 A          B
#> 2011 Q1        NA         NA
#> 2011 Q2        NA         NA
#> 2011 Q3        NA         NA
#> 2011 Q4        NA         NA
#> 2012 Q1  2.236542  -2.266425
#> 2012 Q2  3.355772  -3.297427
#> 2012 Q3  5.152517  -4.615915
#> 2012 Q4 11.173380 -10.032946
#> 2013 Q1 13.263378 -11.223438
#> 2013 Q2 14.959509 -12.337104
#> 2013 Q3 14.400948 -12.325457
#> 2013 Q4  8.687256  -7.680583
```
