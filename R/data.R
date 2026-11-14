#' Data of the IMF Quarterly National Accounts Manual (chapter 8)
#'
#' Current prices and price indices of two products (`A` and `B`) used in the
#' examples of the chapter 8 (price and volume measures) of the IMF *Quarterly
#' National Accounts Manual*.
#'
#' * `data8.2cp` and `data8.2ep`: current prices and elementary price indices
#' over the previous year (average of the previous year = 100) of the examples
#' 8.2, 8.3 and 8.6 to 8.9. The price indices are not available in 2010 (reference
#' year);
#' * `data8.4cp` and `data8.4ep`: current prices and elementary price indices over
#' the previous quarter (previous quarter = 100) of the example 8.4. The price
#' indices over the previous quarter of the example 8.4 can be derived from
#' `data8.2ep` with [pi_py2pp()].
#'
#' @format Quarterly `mts` from 2010Q1 to 2013Q4 with two columns (`A` and `B`).
#' @source IMF, Quarterly National Accounts Manual, chapter 8 (Price and Volume
#' Measures), tables and charts of the examples.
#' @examples
#' data8.2cp
#' data8.2ep
#' @docType data
#' @name data_manual
"data8.2cp"

#' @rdname data_manual
"data8.2ep"

#' @rdname data_manual
"data8.4cp"

#' @rdname data_manual
"data8.4ep"
