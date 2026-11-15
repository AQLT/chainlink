# Changelog

## chainlink 0.1.0.9000

### New functions

- [`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md)
  chains sub-annual (quarterly or monthly) volume indices with the
  annual overlap (`method = "ao"`) or the one-quarter overlap
  (`method = "oqo"`) technique. It replaces the `vo_cp2vpch_*()`
  functions, and
  [`annual_chain()`](https://aqlt.github.io/chainlink/reference/chain_link.md)
  is simplified.
- [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md)
  computes in one step the chain-linked Laspeyres-type volume indices
  (or measures) of the components and of their total.
- [`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)
  computes the exact contributions to percent change of the chain-linked
  volume measures, for the annual overlap and the one-quarter overlap
  techniques, over the previous period (`type = "period"`), over the
  same period of the previous year (`type = "yoy"`) or for the annual
  growth (`type = "annual"`). The argument `extra` adds the growth of
  the total and the non-additivity residual.
- [`chain_unchain()`](https://aqlt.github.io/chainlink/reference/chain_unchain.md)
  and
  [`chain_aggregate()`](https://aqlt.github.io/chainlink/reference/chain_unchain.md)
  un-chain chain volume measures and derive the chain volume measure of
  an aggregate of components: indirect seasonal adjustment of
  chain-linked Laspeyres-type series (ESS Guidelines on Seasonal
  Adjustment, item 5.6).
- [`chain_pseudo()`](https://aqlt.github.io/chainlink/reference/chain_pseudo.md)
  computes the pseudo chain volume series of a variable that changes
  sign (changes in inventories, trade balance), as the difference of the
  chain volume measures of two positive series (paragraphs 8.56-8.58 of
  the manual).
- [`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md)
  returns the non-additivity of chain-linked volume measures and
  [`chain_rebase()`](https://aqlt.github.io/chainlink/reference/chain_rebase.md)
  changes their reference year.
- [`fisher_contrib()`](https://aqlt.github.io/chainlink/reference/fisher_contrib.md)
  computes the exact contributions to the percent change of a Fisher
  volume index (paragraph 8.89 of the manual).
- [`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)
  gives the quarterly (or monthly) values at the weighted average prices
  of the year, which value the overlap quarter of the one-quarter
  overlap technique (paragraph 8.72 and example 8.7 of the manual).
- [`pi_py2pp()`](https://aqlt.github.io/chainlink/reference/pi_py2pp.md)
  converts price indices over the previous year into price indices over
  the previous period, as needed for quarter-to-quarter (or
  month-to-month) Fisher indices.
- [`pi_annual()`](https://aqlt.github.io/chainlink/reference/pi_annual.md)
  derives annual price indices from quarterly (or monthly) ones: by
  default their weighted average (annual current prices over the annual
  sum of the volumes at the prices of the previous year), consistent
  with the quarterly data as in the examples 8.3, 8.8 and 8.9 of the
  manual, or their simple average (`method = "mean"`).
- `chain_laspeyres(method = "oqo")` follows the manual: the overlap
  quarter is valued at the average prices of the previous year (not at
  its current prices) and the first year is linked with the annual
  overlap technique. The printed example 8.7 and the annex 8.1 are
  reproduced.
- `chain_contrib(method = "oqo")` has a `pi` argument (see
  [`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md)).
- [`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md)
  has the sign of the manual: sum of the components minus the total.
- The functions work with monthly series (the overlap period is the last
  month).

### Other changes

- `cp_py2vol()` is removed (identical to
  [`cp_pi2vol()`](https://aqlt.github.io/chainlink/reference/cp_pi2vol.md)).
- The datasets `data8.2cp` and `data8.2ep` are renamed `imf_cp` and
  `imf_pi`.
- The quarterly chain (`"pq"`) is not implemented. The benchmarking of
  the quarterly series is done with the `tempdisagg` package (see the
  vignette).
- Fixes in
  [`laspeyres()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md),
  [`paasche()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md)
  and
  [`fisher()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md)
  (typo in the `output` argument, one-component case) and in their
  documentation.
- New vignettes: contributions to percent change and a practical case.
  The vignette on the manual starts with the correspondence between its
  examples and the functions. Examples 8.1, 8.5, 8.8, A8.1 and figures
  8.1, 8.2 and A8.1 of the manual are reproduced in the vignette
  `imf_qna_manual`.
- Tests against the examples of the manual and against fully consistent
  synthetic data (contributions add up exactly).
- Inputs are checked (class, frequency, number of variables, base year).
