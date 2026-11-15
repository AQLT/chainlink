# Laspeyres, Paasche and Fisher volume indices

Derive the Laspeyres-type, Paasche-type or Fisher-type volume indices of
the total from the current prices and the price indices of its
components.

## Usage

``` r
laspeyres(
  cp,
  pi,
  output = c("index", "measure", "both"),
  reference_freq = 1,
  reference_cycle = NULL
)

paasche(
  cp,
  pi,
  output = c("index", "measure", "both"),
  reference_freq = 1,
  reference_cycle = NULL
)

fisher(
  cp,
  pi,
  output = c("index", "measure", "both"),
  all_index = FALSE,
  reference_freq = 1,
  reference_cycle = NULL
)
```

## Arguments

- cp:

  Current prices (`ts` or `mts`).

- pi:

  Price indices (previous reference period = 100), same structure as
  `cp`.

- output:

  Character if the output should be the volume index (the default), the
  volume measure (in monetary terms) or both.

- reference_freq:

  Frequency of the reference period: 1 (default) for the previous year,
  or the frequency of the data (4 or 12) for the previous period
  (quarter or month). It must divide the frequency of `cp`.

- reference_cycle:

  Integer to use a given period of the previous year as reference (the
  last period of the year, 4 for quarterly data or 12 for monthly data)
  instead of the average of the year, as needed for the one-quarter
  overlap technique. It is used with `reference_freq` equal to the
  frequency of `cp`. The reference period is valued at its own current
  prices: the one-quarter overlap technique of the manual values it at
  the average prices of the year, see
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)
  and
  [`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md).

- all_index:

  (`fisher()` only) Boolean: if `TRUE`, return the Laspeyres, Paasche
  and Fisher indices instead of the Fisher index only.

## Value

A `ts` (or `mts`).

## Examples

``` r
# Laspeyres-type volume index over the previous year
laspeyres(imf_cp, imf_pi)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2011 100.7146 100.6082 100.6459 100.9588
#> 2012 100.4327 100.4151 100.9329 101.8548
#> 2013 101.9515 102.5155 102.4950 102.3481
# Volume index and measure (in monetary terms)
paasche(imf_cp, imf_pi, output = "both")
#>             Index  Measure
#> 2011 Q1 100.84230 381.9150
#> 2011 Q2 100.73235 381.4986
#> 2011 Q3 100.70951 381.4121
#> 2011 Q4 100.96596 382.3833
#> 2012 Q1 100.65838 384.6408
#> 2012 Q2 100.79021 385.1446
#> 2012 Q3 101.09097 386.2939
#> 2012 Q4  99.37475 379.7358
#> 2013 Q1 103.01329 402.8850
#> 2013 Q2 102.58697 401.2177
#> 2013 Q3 101.37238 396.4674
#> 2013 Q4 100.48494 392.9966
# The three indices
fisher(imf_cp, imf_pi, all_index = TRUE)
#>         Laspeyres   Paasche   Fisher
#> 2011 Q1  100.7146 100.84230 100.7784
#> 2011 Q2  100.6082 100.73235 100.6703
#> 2011 Q3  100.6459 100.70951 100.6777
#> 2011 Q4  100.9588 100.96596 100.9624
#> 2012 Q1  100.4327 100.65838 100.5455
#> 2012 Q2  100.4151 100.79021 100.6025
#> 2012 Q3  100.9329 101.09097 101.0119
#> 2012 Q4  101.8548  99.37475 100.6071
#> 2013 Q1  101.9515 103.01329 102.4810
#> 2013 Q2  102.5155 102.58697 102.5512
#> 2013 Q3  102.4950 101.37238 101.9321
#> 2013 Q4  102.3481 100.48494 101.4123
# Quarter-to-quarter indices need price indices over the previous quarter
fisher(imf_cp, pi_py2pp(imf_pi), reference_freq = 4)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 2011 100.73654  99.92231 100.07836 100.33142
#> 2012 100.17546 100.06025 100.58254 101.06762
#> 2013 100.75625 100.53763  99.93702  99.82502
```
