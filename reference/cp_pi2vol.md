# Elementary volume indices

Derive the elementary volume indices from current prices and price
indices: elementary volume measures (`cp / pi * 100`) divided by the
current prices of the reference period (the previous year, the previous
period or a given period of the previous year).

## Usage

``` r
cp_pi2vol(cp, pi, reference_freq = 1, reference_cycle = NULL)
```

## Arguments

- cp:

  Current prices (`ts` or `mts`).

- pi:

  Price indices (previous reference period = 100), same structure as
  `cp`.

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

## Value

A `ts` (or `mts`) of volume indices (reference period = 100).

## Details

With \\cp_t\\ the current prices and \\pi_t\\ the price index of period
\\t\\, the volume index is \$\$v_t = 100 \times \frac{100\\ cp_t /
pi_t}{\overline{cp}\_{r(t)}}\$\$ where \\\overline{cp}\_{r(t)}\\ is the
value per period of the reference period \\r(t)\\: the annual sum of the
previous year divided by the frequency \\f\\ (`reference_freq = 1`), the
value of the previous period (`reference_freq = f`) or the value of the
period `reference_cycle` of the previous year.

## Examples

``` r
# Volume indices over the previous year (previous-year prices)
cp_pi2vol(imf_cp, imf_pi)
#>                A        B
#> 2011 Q1 104.3791 98.27160
#> 2011 Q2 106.1463 96.91610
#> 2011 Q3 108.3495 95.51020
#> 2011 Q4 109.8382 95.03928
#> 2012 Q1 103.0007 98.45005
#> 2012 Q2 107.1895 95.18509
#> 2012 Q3 113.3513 91.34562
#> 2012 Q4 128.6759 81.14837
#> 2013 Q1 117.8298 86.28980
#> 2013 Q2 124.8932 80.44313
#> 2013 Q3 129.3036 76.05220
#> 2013 Q4 131.2975 73.79378
# Volume indices over the previous quarter (price indices over the previous quarter)
cp_pi2vol(imf_cp, pi_py2pp(imf_pi), reference_freq = 4)
#>                A        B
#> 2011 Q1 104.3791 98.27160
#> 2011 Q2 101.6931 98.62065
#> 2011 Q3 102.0756 98.54937
#> 2011 Q4 101.3740 99.50694
#> 2012 Q1 100.5140 99.89629
#> 2012 Q2 104.0668 96.68364
#> 2012 Q3 105.7485 95.96631
#> 2012 Q4 113.5195 88.83662
#> 2013 Q1 103.4955 97.29449
#> 2013 Q2 105.9946 93.22438
#> 2013 Q3 103.5313 94.54157
#> 2013 Q4 101.5421 97.03044
# Volume indices over the last quarter of the previous year
cp_pi2vol(imf_cp, imf_pi, reference_freq = 4, reference_cycle = 4)
#>                A        B
#> 2011 Q1 104.3791 98.27160
#> 2011 Q2 106.1463 96.91610
#> 2011 Q3 108.3495 95.51020
#> 2011 Q4 109.8382 95.03928
#> 2012 Q1 100.1480 99.39177
#> 2012 Q2 104.2208 96.09558
#> 2012 Q3 110.2120 92.21938
#> 2012 Q4 125.1121 81.92458
#> 2013 Q1 103.7504 96.68026
#> 2013 Q2 109.9698 90.12957
#> 2013 Q3 113.8531 85.20991
#> 2013 Q4 115.6088 82.67955
```
