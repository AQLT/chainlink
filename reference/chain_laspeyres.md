# Chain-linked Laspeyres-type volume series of a total and its components

Chain-linked volume indices (or measures) of the components and of their
total in one step. For each component, the volume indices are derived
from the current prices and the price indices, the volume index of the
total is a Laspeyres-type index, and all of them are chain-linked
([`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md))
with the annual overlap or the one-quarter overlap technique.

## Usage

``` r
chain_laspeyres(
  cp,
  pi,
  method = c("ao", "oqo"),
  base_year = NULL,
  output = c("index", "measure", "both"),
  overlap_prices = c("year_prices", "current_prices")
)
```

## Arguments

- cp:

  Current prices of the components (`ts` or `mts`), without the total.
  It must cover the base year.

- pi:

  Price indices of the components over the previous year (previous year
  average = 100), with the same structure as `cp`.

- method:

  Chain-linking technique: `"ao"` for annual overlap, `"oqo"` for
  one-quarter overlap (for monthly series, the overlap period is the
  last month of the year).

- base_year:

  Reference year (index = 100). By default, the year before the start of
  `vo` (or the first year of `cp`, if later).

- output:

  Chain index (the default), chain volume measure (in monetary terms,
  i.e. the index times the base-year current prices) or both.

- overlap_prices:

  Only for `method = "oqo"`: prices used to value the overlap period,
  `"year_prices"` (average prices of the year, default) or
  `"current_prices"` (own current prices). See details.

## Value

A `ts` (`mts`): the columns of `cp` and a column `Total`. With
`output = "both"`, the indices then the measures of each variable (see
[`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)).

## Details

With the annual overlap technique (`method = "ao"`), the volume indices
are those of
[`cp_pi2vol()`](https://aqlt.github.io/chainlink/reference/cp_pi2vol.md)
and
[`laspeyres()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md)
(previous year average = 100).

With the one-quarter overlap technique (`method = "oqo"`), the volume at
the prices of the previous year of each period is divided by the value
of the last period (quarter or month) of the previous year: \$\$v_t =
100 \times \frac{100\\ cp_t / pi_t}{cy\_{y(t)-1, f}}\$\$ where
\\cy\_{y,f}\\ is the value of the last period \\f\\ of year \\y\\. This
overlap period can be valued in two ways (`overlap_prices`):

- `"year_prices"` (default), as printed in the manual (paragraph 8.72
  and example 8.7): at the **average prices of the year** (see
  [`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md));

- `"current_prices"`, as in the spreadsheet of the manual: at its **own
  current prices**. The volume indices are then those of
  [`cp_pi2vol()`](https://aqlt.github.io/chainlink/reference/cp_pi2vol.md)
  with `reference_freq = f` and `reference_cycle = f` (`f` = 4 or 12),
  the "q4 previous year = 100" volume measures.

As there are no price indices in the reference year, the first year is
linked with the annual overlap technique (footnote 32 of the manual).

The result with `output = "measure"` can be used directly in
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)
and
[`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md).

## See also

[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md),
[`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md),
[`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)

## Examples

``` r
# Annual overlap
chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010)
#>                A        B    Total
#> 2011 Q1 104.3791 98.27160 100.7146
#> 2011 Q2 106.1463 96.91610 100.6082
#> 2011 Q3 108.3495 95.51020 100.6459
#> 2011 Q4 109.8382 95.03928 100.9588
#> 2012 Q1 110.3944 94.93962 101.1677
#> 2012 Q2 114.8839 91.79108 101.1500
#> 2012 Q3 121.4880 88.08851 101.6716
#> 2012 Q4 137.9126 78.25486 102.6003
#> 2013 Q1 142.7741 76.16672 103.6310
#> 2013 Q2 151.3328 71.00596 104.2044
#> 2013 Q3 156.6768 67.13015 104.1835
#> 2013 Q4 159.0929 65.13667 104.0342
chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
        output = "measure")
#>                A        B    Total
#> 2011 Q1 156.5686 221.1111 377.6797
#> 2011 Q2 159.2195 218.0612 377.2807
#> 2011 Q3 162.5243 214.8980 377.4222
#> 2011 Q4 164.7573 213.8384 378.5957
#> 2012 Q1 165.5916 213.6141 379.3789
#> 2012 Q2 172.3259 206.5299 379.3126
#> 2012 Q3 182.2320 198.1991 381.2686
#> 2012 Q4 206.8690 176.0734 384.7510
#> 2013 Q1 214.1611 171.3751 388.6164
#> 2013 Q2 226.9992 159.7634 390.7664
#> 2013 Q3 235.0152 151.0428 390.6881
#> 2013 Q4 238.6393 146.5575 390.1284
# One-quarter overlap (example 8.7 of the manual)
chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
        output = "measure")
#>                A        B    Total
#> 2011 Q1 156.5686 221.1111 377.6797
#> 2011 Q2 159.2195 218.0612 377.2807
#> 2011 Q3 162.5243 214.8980 377.4222
#> 2011 Q4 164.7573 213.8384 378.5957
#> 2012 Q1 165.5916 213.6141 379.2292
#> 2012 Q2 172.3259 206.5299 379.1629
#> 2012 Q3 182.2320 198.1991 381.1181
#> 2012 Q4 206.8690 176.0734 384.5992
#> 2013 Q1 214.1611 171.3751 387.6460
#> 2013 Q2 226.9992 159.7634 389.7906
#> 2013 Q3 235.0152 151.0428 389.7125
#> 2013 Q4 238.6393 146.5575 389.1542
# Overlap quarter valued at its own current prices
chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
        overlap_prices = "current_prices", output = "measure")
#>                A        B    Total
#> 2011 Q1 156.5686 221.1111 377.6797
#> 2011 Q2 159.2195 218.0612 377.2807
#> 2011 Q3 162.5243 214.8980 377.4222
#> 2011 Q4 164.7573 213.8384 378.5957
#> 2012 Q1 165.0012 212.5377 377.5669
#> 2012 Q2 171.7114 205.4892 377.5009
#> 2012 Q3 181.5822 197.2004 379.4475
#> 2012 Q4 206.1313 175.1862 382.9133
#> 2013 Q1 213.8621 169.3705 385.2690
#> 2013 Q2 226.6822 157.8946 387.4005
#> 2013 Q3 234.6870 149.2760 387.3229
#> 2013 Q4 238.3060 144.8432 386.7680
```
