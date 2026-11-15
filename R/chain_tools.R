#' Non-additivity of chain-linked volume measures
#'
#' Chain-linked volume measures are not additive: the chain volume measure of the
#' total differs from the sum of the chain volume measures of its components
#' (except in the base year and, with the annual overlap technique, in the year
#' after the base year). This function returns the difference, with the sign of
#' the column "Discrepancies" of the examples 8.6 and 8.7 of the manual: the sum of
#' the components minus the total.
#'
#' @param vo Chain volume measures (in monetary terms) of the components (`ts`
#' or `mts`). If `vo_total` is `NULL`, the last column is the total (as returned
#' by [chain_laspeyres()] with `output = "measure"`).
#' @param vo_total Chain volume measure of the total (`ts`).
#' @param relative Boolean: if `TRUE`, the discrepancy is expressed in percent of
#' the chain volume measure of the total.
#'
#' @return A `ts`: sum of the chain volume measures of the components minus the
#' chain volume measure of the total.
#' @examples
#' x <- chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
#' 					 output = "measure")
#' chain_discrepancy(x)
#' chain_discrepancy(x, relative = TRUE)
#' @seealso [chain_contrib()]
#' @export
chain_discrepancy <- function(vo, vo_total = NULL, relative = FALSE) {
	check_ts(vo, "vo")
	vo <- as_mts(vo)
	if (is.null(vo_total)) {
		if (ncol(vo) < 2L)
			stop("`vo_total` must be provided, or the last column of `vo` must be the total",
				 call. = FALSE)
		vo_total <- vo[, ncol(vo)]
		vo <- vo[, -ncol(vo), drop = FALSE]
	}
	check_ts(vo_total, "vo_total")
	check_same_frequency(vo = vo, vo_total = vo_total)
	sum_vo <- stats::ts(rowSums(vo), start = stats::start(vo),
						frequency = stats::frequency(vo))
	res <- sum_vo - vo_total
	if (relative)
		res <- 100 * res / vo_total
	res
}

#' Change the reference year of chain-linked series
#'
#' Rescale a chain index so that the average of the new reference year is 100, or
#' a chain volume measure so that the annual sum of the new reference year is its
#' annual current prices.
#'
#' The series must cover all the periods of the new reference year. The
#' contributions computed by [chain_contrib()] must be computed from series
#' whose reference year is the one used to build them (the year before the
#' start of the series, by default).
#'
#' @param x Chain index (if `cp` is `NULL`) or chain volume measure (in monetary
#' terms) (`ts` or `mts`).
#' @param base_year New reference year.
#' @param cp Current prices, same structure as `x`. If provided, `x` is a chain
#' volume measure.
#'
#' @return A `ts` (or `mts`) with the same structure as `x`.
#' @examples
#' x <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010)
#' chain_rebase(x, base_year = 2012)
#' x_measure <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010,
#' 							 output = "measure")
#' cp_all <- ts(cbind(as.matrix(imf_cp), Total = rowSums(imf_cp)),
#' 			 start = start(imf_cp), frequency = frequency(imf_cp))
#' chain_rebase(x_measure, base_year = 2012, cp = cp_all)
#' @export
chain_rebase <- function(x, base_year, cp = NULL) {
	check_ts(x, "x")
	x <- as_mts(x)
	if (!is.null(cp)) {
		check_ts(cp, "cp")
		cp <- as_mts(cp)
		check_same_ncol(x, cp, "x", "cp")
	}
	res <- lapply(seq_len(ncol(x)), function(i) {
		rebase_ts(x[, i], base_year, if (is.null(cp)) NULL else cp[, i])
	})
	if (length(res) == 1L)
		return(res[[1L]])
	res <- do.call(stats::ts.union, res)
	colnames(res) <- colnames(x)
	res
}

rebase_ts <- function(x, base_year, cp = NULL) {
	f <- stats::frequency(x)
	year <- function(s) {
		if (base_year < stats::start(s)[1] || base_year > stats::end(s)[1])
			stop("The series must cover the reference year (", base_year, ")",
				 call. = FALSE)
		s <- extend_ts(s)
		res <- stats::window(s, start = c(base_year, 1), end = c(base_year, f))
		if (anyNA(res))
			stop("The series must be available for all the periods of the ",
				 "reference year (", base_year, ")", call. = FALSE)
		res
	}
	if (is.null(cp))
		return(x / mean(year(x)) * 100)
	x / sum(year(x)) * sum(year(cp))
}
