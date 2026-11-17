#' Data of the IMF Quarterly National Accounts Manual (chapter 8)
#'
#' Current prices and price indices of two products (`A` and `B`) used in the
#' examples of the chapter 8 (price and volume measures) of the IMF *Quarterly
#' National Accounts Manual*.
#' `imf_cp` and `imf_pi` are current prices and elementary price indices
#' over the previous year (average of the previous year = 100) of the example
#' 8.2. The price indices are not available in 2010 (reference year).
#' @format Quarterly `mts` from 2010Q1 to 2013Q4 with two columns (`A` and `B`).
#' @source Tables and charts of the examples of the chapter 8 (Price and Volume
#' Measures) of the IMF *Quarterly National Accounts Manual (2017 Edition)*,
#' \doi{10.5089/9781475589870.069}.
#' @references `r ref_imf()`
#' @examples
#' imf_cp
#' imf_pi
#' @docType data
#' @name data_manual
"imf_cp"

#' @rdname data_manual
"imf_pi"
