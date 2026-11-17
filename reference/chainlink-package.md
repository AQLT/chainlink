# chainlink: Chain-Linked Price and Volume Measures

Tools to derive price and volume measures of national accounts following
chapter 8 of the International Monetary Fund (2018) "Quarterly National
Accounts Manual (2017 Edition)"
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
: Laspeyres-type, Paasche-type and Fisher-type volume indices,
chain-linking of quarterly or monthly volume indices with the annual
overlap and the one-quarter overlap techniques, exact contributions to
percent change of the chain-linked volume measures, and non-additivity
of the chain-linked series. The benchmarking of the quarterly series on
annual data can be done with the 'tempdisagg' package.

## Details

The package follows the chapter 8 (Price and Volume Measures) of the IMF
*Quarterly National Accounts Manual*. All the functions use `ts` objects
(quarterly or monthly series, or annual series for the annual indices).

Main functions:

- volume indices from current prices and price indices:
  [`cp_pi2vol()`](https://aqlt.github.io/chainlink/reference/cp_pi2vol.md),
  [`laspeyres()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md),
  [`paasche()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md),
  [`fisher()`](https://aqlt.github.io/chainlink/reference/fixed_weight_indices.md),
  and the conversion of price indices with
  [`pi_py2pp()`](https://aqlt.github.io/chainlink/reference/pi_py2pp.md),
  [`pi_annual()`](https://aqlt.github.io/chainlink/reference/pi_annual.md)
  and
  [`cp_pi2cy()`](https://aqlt.github.io/chainlink/reference/cp_pi2cy.md);

- chain-linking with the annual overlap and the one-quarter overlap
  techniques:
  [`chain_laspeyres()`](https://aqlt.github.io/chainlink/reference/chain_laspeyres.md),
  [`chain_link()`](https://aqlt.github.io/chainlink/reference/chain_link.md),
  [`annual_chain()`](https://aqlt.github.io/chainlink/reference/chain_link.md),
  and
  [`chain_rebase()`](https://aqlt.github.io/chainlink/reference/chain_rebase.md)
  to change the reference year;

- contributions to percent change:
  [`chain_contrib()`](https://aqlt.github.io/chainlink/reference/chain_contrib.md)
  (chain-linked Laspeyres-type measures) and
  [`fisher_contrib()`](https://aqlt.github.io/chainlink/reference/fisher_contrib.md)
  (Fisher indices);

- non-additivity and related tools:
  [`chain_discrepancy()`](https://aqlt.github.io/chainlink/reference/chain_discrepancy.md),
  [`chain_pseudo()`](https://aqlt.github.io/chainlink/reference/chain_pseudo.md)
  (variables that change sign),
  [`chain_unchain()`](https://aqlt.github.io/chainlink/reference/chain_unchain.md)
  and
  [`chain_aggregate()`](https://aqlt.github.io/chainlink/reference/chain_unchain.md)
  (indirect seasonal adjustment of chain-linked series, following the
  ESS Guidelines on Seasonal Adjustment).

The benchmarking of the quarterly series on annual data is not
implemented: see for instance the `tempdisagg` package.

See the vignettes:
[`vignette("imf_qna_manual", package = "chainlink")`](https://aqlt.github.io/chainlink/articles/imf_qna_manual.md)
(examples of the manual),
[`vignette("contributions", package = "chainlink")`](https://aqlt.github.io/chainlink/articles/contributions.md)
and
[`vignette("practical_case", package = "chainlink")`](https://aqlt.github.io/chainlink/articles/practical_case.md).

## References

International Monetary Fund (2018), *Quarterly National Accounts Manual
(2017 Edition)*, chapter 8 "Price and Volume Measures", Washington, DC.
[doi:10.5089/9781475589870.069](https://doi.org/10.5089/9781475589870.069)
.

Eurostat (2015), *ESS Guidelines on Seasonal Adjustment (2015 Edition)*,
Luxembourg, Publications Office of the European Union.
[doi:10.2785/317290](https://doi.org/10.2785/317290) .

## See also

Useful links:

- <https://github.com/AQLT/chainlink>

- <https://aqlt.github.io/chainlink/>

- Report bugs at <https://github.com/AQLT/chainlink/issues>

## Author

**Maintainer**: Alain Quartier-la-Tente <alain.quartier@yahoo.fr>
([ORCID](https://orcid.org/0000-0001-7890-3857))

Authors:

- Alain Quartier-la-Tente <alain.quartier@yahoo.fr>
  ([ORCID](https://orcid.org/0000-0001-7890-3857))
