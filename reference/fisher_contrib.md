# Contributions to percent change of a Fisher volume index

Exact contributions of the components to the percent change, from the
previous period (quarter, month or year) to the current one, of the
Fisher volume index of their aggregate (equation (32) of the paragraph
8.89 of the IMF QNA Manual).

## Usage

``` r
fisher_contrib(cp, pi, extra = NULL)
```

## Arguments

- cp:

  Current prices of all the components of the aggregate (`ts` or `mts`).
  The aggregate is their sum.

- pi:

  Price indices of the components over the previous period (previous
  quarter, month or year = 100), with the same structure as `cp`. Price
  indices over the previous year can be converted with
  [`pi_py2pp()`](https://aqlt.github.io/chainlink/reference/pi_py2pp.md).

- extra:

  Additional columns: `"total"` adds the percent change of the Fisher
  volume index, and `"residual"` the difference between this percent
  change and the sum of the contributions (zero, up to numerical
  errors).

## Value

A `ts` (or `mts`) of contributions, in percentage points, with the span
and the columns of `cp` (followed by `Total` and/or `Residual`). The
first period is `NA`.

## Details

With \\x^t\\ the current price value of the component \\x\\ in period
\\t\\, \\z^t\\ the one of the aggregate, \\r_j = p_j^t / p_j^{t-1}\\ the
price index of the component \\j\\ over the previous period, and \\F\\
the Fisher volume index of the aggregate (previous period = 1), the
contribution of the component \\x\\ is \$\$100 \frac{\frac{z^t}{z^{t-1}}
\left(x^t / r_x - x^{t-1}\right) + F \left(x^t - x^{t-1}
r_x\right)}{z^t + F \sum_j x_j^{t-1} r_j}.\$\$ Contributions add up
exactly to the percent change of the Fisher index, whatever the number
of components.

The formula as printed in the manual has the ratio \\z^{t-1} / z^t\\ in
the first term and \\x^{t-1} p_x^{t-1} / p_x^t\\ in the second one. With
these ratios the contributions do not add up to the percent change
(checked numerically), so that the formula implemented corrects them
(\\z^t / z^{t-1}\\ and \\x^{t-1} p_x^t / p_x^{t-1}\\, consistent with
the denominator). Among the variants of the formula that were tested, it
is the only one that is exact.

The adjustments that some countries add to the quarterly contributions
(benchmarking of the quarterly Fisher indices on the annual ones,
percent changes at annual rates) are not done. As recommended by the
manual (paragraph 8.90), the contribution of a variable that can be
negative, zero or positive (such as changes in inventories) should be
calculated residually, as the difference between the contribution of the
aggregate that includes it and the contributions of the other
components.

## References

Chevalier, M. (2003), "Chain Fisher Volume Index Methodology",
Statistics Canada (formula drawn from the appendix II).

## See also

[`fisher()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md),
[`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)

## Examples

``` r
# Price indices over the previous quarter (example 8.4)
ep <- pi_py2pp(imf_pi)
fisher_contrib(imf_cp, ep, extra = c("total", "residual"))
#>                 A           B       Total      Residual
#> 2010 Q1        NA          NA          NA            NA
#> 2010 Q2        NA          NA          NA            NA
#> 2010 Q3        NA          NA          NA            NA
#> 2010 Q4        NA          NA          NA            NA
#> 2011 Q1 1.7673655 -1.03082791  0.73653760 -8.881784e-15
#> 2011 Q2 0.7172937 -0.79498091 -0.07768721 -8.659740e-15
#> 2011 Q3 0.8999876 -0.82163252  0.07835505  5.884182e-15
#> 2011 Q4 0.6067458 -0.27532191  0.33142386  4.996004e-16
#> 2012 Q1 0.2322934 -0.05683666  0.17545677 -1.793010e-14
#> 2012 Q2 1.8599025 -1.79965011  0.06025244  1.354472e-14
#> 2012 Q3 2.7127291 -2.13018549  0.58254360  3.552714e-15
#> 2012 Q4 6.6992703 -5.63164656  1.06762372  5.329071e-15
#> 2013 Q1 1.9513802 -1.19513501  0.75624524  1.554312e-15
#> 2013 Q2 3.4329839 -2.89535604  0.53762784  1.465494e-14
#> 2013 Q3 2.1194067 -2.18238871 -0.06298201 -6.661338e-15
#> 2013 Q4 0.9551832 -1.13016685 -0.17498365  4.218847e-15
```
