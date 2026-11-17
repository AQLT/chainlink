# Price indices over the previous period

Convert price indices expressed over the previous year (average of the
previous year = 100, as in the examples 8.2 and 8.3 of the IMF QNA
Manual) into price indices over the previous period (quarter or month),
as needed by
[`laspeyres()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md),
[`paasche()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md)
and
[`fisher()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md)
with `reference_freq` equal to the frequency of the data.

## Usage

``` r
pi_py2pp(pi, previous = 100)
```

## Arguments

- pi:

  Price indices over the previous year (`ts` or `mts`, quarterly or
  monthly). Leading and trailing missing values are ignored.

- previous:

  Value, over the previous year, assumed for the period before the first
  one (default: 100, i.e. the prices of that period are those of the
  average of its year).

## Value

A `ts` (or `mts`) of price indices (previous period = 100).

## Details

With \\i_t\\ the index over the previous year, the index over the
previous period is \\100 i_t / i\_{t-1}\\ within a year, and \\i_t /
i\_{t-1} \times \bar{i}\_{y-1}\\ for the first period of year \\y\\
(\\\bar{i}\_{y-1}\\ is the simple average of the indices of the previous
year, on which the indices of year \\y-1\\ are normalised). This simple
average is the normalisation of the indices, not the annual price index
used to deflate annual data, which is by default their weighted average
(see
[`pi_annual()`](https://aqlt.github.io/chainlink/reference/pi_annual.md)).

## References

International Monetary Fund (2018), *Quarterly National Accounts Manual
(2017 Edition)*, chapter 8 "Price and Volume Measures", Washington, DC.
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
.

## See also

[`pi_annual()`](https://aqlt.github.io/chainlink/reference/pi_annual.md)

## Examples

``` r
pi_py2pp(imf_pi)
#>                 A         B
#> 2011 Q1 102.00000  99.00000
#> 2011 Q2 100.49020  98.98990
#> 2011 Q3 100.48780 100.00000
#> 2011 Q4 100.00000 101.02041
#> 2012 Q1 102.12682  96.51010
#> 2012 Q2  99.51220 102.06186
#> 2012 Q3  99.01961  99.49495
#> 2012 Q4 100.49505 100.50761
#> 2013 Q1 100.74754  99.36869
#> 2013 Q2  99.00498 101.00000
#> 2013 Q3  99.49749 100.49505
#> 2013 Q4  99.49495 100.49261
```
