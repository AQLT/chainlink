# Data of the IMF Quarterly National Accounts Manual (chapter 8)

Current prices and price indices of two products (`A` and `B`) used in
the examples of the chapter 8 (price and volume measures) of the IMF
*Quarterly National Accounts Manual*. `imf_cp` and `imf_pi` are current
prices and elementary price indices over the previous year (average of
the previous year = 100) of the example 8.2. The price indices are not
available in 2010 (reference year).

## Usage

``` r
imf_cp

imf_pi
```

## Format

Quarterly `mts` from 2010Q1 to 2013Q4 with two columns (`A` and `B`).

An object of class `mts` (inherits from `ts`, `matrix`) with 16 rows and
2 columns.

## Source

IMF, Quarterly National Accounts Manual, chapter 8 (Price and Volume
Measures), tables and charts of the examples.

## Examples

``` r
imf_cp
#>             A     B
#> 2010 Q1 150.0 225.0
#> 2010 Q2 150.0 225.0
#> 2010 Q3 150.0 225.0
#> 2010 Q4 150.0 225.0
#> 2011 Q1 159.7 218.9
#> 2011 Q2 163.2 213.7
#> 2011 Q3 167.4 210.6
#> 2011 Q4 169.7 211.7
#> 2012 Q1 174.2 204.1
#> 2012 Q2 180.4 201.4
#> 2012 Q3 188.9 192.3
#> 2012 Q4 215.5 171.7
#> 2013 Q1 224.7 166.0
#> 2013 Q2 235.8 156.3
#> 2013 Q3 242.9 148.5
#> 2013 Q4 245.4 144.8
imf_pi
#>             A     B
#> 2010 Q1    NA    NA
#> 2010 Q2    NA    NA
#> 2010 Q3    NA    NA
#> 2010 Q4    NA    NA
#> 2011 Q1 102.0  99.0
#> 2011 Q2 102.5  98.0
#> 2011 Q3 103.0  98.0
#> 2011 Q4 103.0  99.0
#> 2012 Q1 102.5  97.0
#> 2012 Q2 102.0  99.0
#> 2012 Q3 101.0  98.5
#> 2012 Q4 101.5  99.0
#> 2013 Q1 100.5 100.0
#> 2013 Q2  99.5 101.0
#> 2013 Q3  99.0 101.5
#> 2013 Q4  98.5 102.0
```
