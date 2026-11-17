#' @details
#' The package follows the chapter 8 (Price and Volume Measures) of the IMF
#' *Quarterly National Accounts Manual*. All the functions use `ts` objects
#' (quarterly or monthly series, or annual series for the annual indices).
#'
#' Main functions:
#' * volume indices from current prices and price indices: [cp_pi2vol()],
#' [laspeyres()], [paasche()], [fisher()], and the conversion of price indices
#' with [pi_py2pp()], [pi_annual()] and [cp_pi2cy()];
#' * chain-linking with the annual overlap and the one-quarter overlap
#' techniques: [chain_laspeyres()], [chain_link()], [annual_chain()], and
#' [chain_rebase()] to change the reference year;
#' * contributions to percent change: [chain_contrib()] (chain-linked
#' Laspeyres-type measures) and [fisher_contrib()] (Fisher indices);
#' * non-additivity and related tools: [chain_discrepancy()], [chain_pseudo()]
#' (variables that change sign), [chain_unchain()] and [chain_aggregate()]
#' (indirect seasonal adjustment of chain-linked series, following the ESS
#' Guidelines on Seasonal Adjustment).
#'
#' The benchmarking of the quarterly series on annual data is not implemented:
#' see for instance the `tempdisagg` package.
#'
#' See the vignettes: `vignette("imf_qna_manual", package = "chainlink")` (examples
#' of the manual), `vignette("contributions", package = "chainlink")` and
#' `vignette("practical_case", package = "chainlink")`.
#' @references `r ref_imf()`
#' @references `r ref_ess()`
#' @keywords internal
"_PACKAGE"

#' @importFrom stats aggregate cycle frequency lag start ts ts.union window
NULL
