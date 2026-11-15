# Chain-linking

Chain-linking of volume indices. `chain_link()` links sub-annual
(quarterly or monthly) volume indices with the annual overlap (`"ao"`)
or the one-quarter overlap (`"oqo"`) technique; `annual_chain()` chains
annual links. To compute the volume indices of a total from its
components, see
[`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md).

## Usage

``` r
chain_link(
  vo,
  cp = NULL,
  method = c("ao", "oqo"),
  base_year = NULL,
  output = c("index", "measure", "both")
)

annual_chain(
  vo,
  cp = NULL,
  base_year = NULL,
  output = c("index", "measure", "both")
)
```

## Arguments

- vo:

  Volume indices (`ts` or `mts`):

  - `method = "ao"`: volume indices with the average of the previous
    year = 100 (output of
    [`cp_pi2vol()`](https://aqlt.github.io/chainlink/reference/cp_pi2vol.md)
    or
    [`laspeyres()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md)
    with the default `reference_freq = 1`);

  - `method = "oqo"`: volume indices with the overlap period of the
    previous year (its last quarter or month, valued at the average
    prices of the previous year) = 100: see
    [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md),
    which builds them as in the manual;

  - `annual_chain()`: annual or sub-annual indices with the previous
    year = 100 (sub-annual indices are averaged by year).

- cp:

  Current prices, optional (same number of variables as `vo`). Needed
  for `output = "measure"` or `"both"`. It must cover the base year.

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

## Value

A `ts` (or `mts`). With `output = "both"`, the columns are the indices
then the measures of each variable.

## Examples

``` r
# Annual overlap: volume indices over the previous year
vo <- cp_pi2vol(imf_cp, imf_pi)
chain_link(vo, imf_cp, method = "ao", base_year = 2010)
#>                A        B
#> 2011 Q1 104.3791 98.27160
#> 2011 Q2 106.1463 96.91610
#> 2011 Q3 108.3495 95.51020
#> 2011 Q4 109.8382 95.03928
#> 2012 Q1 110.3944 94.93962
#> 2012 Q2 114.8839 91.79108
#> 2012 Q3 121.4880 88.08851
#> 2012 Q4 137.9126 78.25486
#> 2013 Q1 142.7741 76.16672
#> 2013 Q2 151.3328 71.00596
#> 2013 Q3 156.6768 67.13015
#> 2013 Q4 159.0929 65.13667
chain_link(vo, imf_cp, method = "ao", base_year = 2010, output = "measure")
#>                A        B
#> 2011 Q1 156.5686 221.1111
#> 2011 Q2 159.2195 218.0612
#> 2011 Q3 162.5243 214.8980
#> 2011 Q4 164.7573 213.8384
#> 2012 Q1 165.5916 213.6141
#> 2012 Q2 172.3259 206.5299
#> 2012 Q3 182.2320 198.1991
#> 2012 Q4 206.8690 176.0734
#> 2013 Q1 214.1611 171.3751
#> 2013 Q2 226.9992 159.7634
#> 2013 Q3 235.0152 151.0428
#> 2013 Q4 238.6393 146.5575

# One-quarter overlap: the volume indices over the overlap quarter are built by
# chain_laspeyres(), which also chains them
chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010)
#>                A        B    Total
#> 2011 Q1 104.3791 98.27160 100.7146
#> 2011 Q2 106.1463 96.91610 100.6082
#> 2011 Q3 108.3495 95.51020 100.6459
#> 2011 Q4 109.8382 95.03928 100.9588
#> 2012 Q1 110.3944 94.93962 101.1278
#> 2012 Q2 114.8839 91.79108 101.1101
#> 2012 Q3 121.4880 88.08851 101.6315
#> 2012 Q4 137.9126 78.25486 102.5598
#> 2013 Q1 142.7741 76.16672 103.3723
#> 2013 Q2 151.3328 71.00596 103.9442
#> 2013 Q3 156.6768 67.13015 103.9233
#> 2013 Q4 159.0929 65.13667 103.7745

# Annual chain index from annual Fisher indices
fis <- fisher(stats::aggregate(imf_cp), pi_annual(imf_pi, imf_cp))
annual_chain(fis, base_year = 2010)
#> Time Series:
#> Start = 2010 
#> End = 2013 
#> Frequency = 1 
#> [1] 100.0000 100.7851 101.7914 104.0577
```
