#' Un-chain and aggregate chain-linked volume measures
#'
#' Indirect seasonal adjustment of chain-linked Laspeyres-type series (ESS
#' Guidelines on Seasonal Adjustment, item 5.6): the seasonally adjusted components
#' are un-chained, aggregated, and the aggregate is chain-linked again.
#' `chain_unchain()` un-chains chain volume measures and `chain_aggregate()`
#' derives the chain volume measure of the aggregate of components, whatever they
#' are (seasonally adjusted components, for instance).
#'
#' To derive the seasonally adjusted aggregate of seasonally adjusted chain-linked
#' components:
#' 1. seasonally adjust the chain volume measures of the components (outside the
#' package);
#' 2. un-chain the seasonally adjusted components: `chain_unchain()` returns the
#' volume at the prices of the previous year, which is additive within each year
#' (the sum of the components is the volume of the aggregate at the prices of the
#' previous year);
#' 3. aggregate them and chain-link the aggregate (again with the same technique);
#' 4. re-reference it to the reference year.
#'
#' With \eqn{x_t} the chain volume measure of a component, \eqn{b} the reference
#' year, \eqn{f} the frequency and \eqn{\Lambda_y} the chain level of year \eqn{y}
#' (see [chain_link()]), the volume at the prices of the previous year is
#' \deqn{x^{py}_t = \frac{x_t}{cp_b / f} \times
#' \frac{o_{y(t)-1}}{\Lambda_{y(t)-1}},}
#' where \eqn{o_y} is the value of the reference of year \eqn{y}: the annual
#' current prices divided by \eqn{f} (annual overlap) or the value of the overlap
#' period (one-quarter overlap). The volume index of the aggregate is then
#' \eqn{100 \sum_i x^{py}_{i,t} / \sum_i o_{i,y(t)-1}}, chain-linked with
#' [chain_link()].
#'
#' `chain_aggregate()` does the steps 2 to 4. The reference year of the result is
#' `base_year` and its annual current prices are those of `cp`, so that the
#' seasonally adjusted aggregate is normalised to the unadjusted data of the
#' reference year. The annual links are those of the series that are chained or
#' un-chained: `chain_unchain()` is the exact inverse of [chain_link()] with
#' `output = "measure"`, and `chain_aggregate()` applied to the unadjusted chain
#' volume measures of the components gives the chain volume measure of their
#' total ([chain_laspeyres()]).
#'
#' The annual totals of the seasonally adjusted data are not forced to be equal to
#' the annual totals of the unadjusted data (an option of the guidelines when users
#' require it and the unadjusted data are additive). This approach only concerns
#' Laspeyres-type series: for other chain-linked indices, only the direct approach
#' is feasible.
#'
#' With the one-quarter overlap technique, the overlap period is valued at the
#' average prices of the year (see [cp_pi2cy()]), hence the price indices `pi`, or
#' at its own current prices (`overlap_prices = "current_prices"`, `pi` is then
#' not needed). The
#' un-chaining of the first year after the reference year (or of the first year of
#' `x` if the reference year is not before it) needs the level of the previous
#' year: if the reference year is inside the series, the first year is `NA`.
#'
#' @param x Chain volume measures (in monetary terms) of the components (`ts` or
#' `mts`), as returned by [chain_link()] or [chain_laspeyres()] with
#' `output = "measure"`, or their seasonally adjusted version.
#' @param cp Current prices of the components (same number of variables as `x`).
#' It must cover the reference year.
#' @param method Chain-linking technique of `x`: `"ao"` or `"oqo"`.
#' @param base_year Reference year of the chain measures. By default, the year
#' before the start of `x` (or the first year of `cp`, if later).
#' @param pi Price indices of the components over the previous year (previous year
#' average = 100), needed for `method = "oqo"` with `overlap_prices = "year_prices"`.
#' @param overlap_prices Only for `method = "oqo"`: prices used to value the
#' overlap period, `"year_prices"` (default) or `"current_prices"`; it must be
#' the one used to compute `x` (see [chain_laspeyres()]).
#' @param output (`chain_aggregate()` only) Chain index (the default), chain
#' volume measure or both (see [chain_link()]).
#' @param cp_total (`chain_aggregate()` only) Current prices of the aggregate. By
#' default, the sum of `cp`.
#'
#' @return `chain_unchain()`: a `ts` (or `mts`) with the structure of `x`: the volume
#' of each period at the (average) prices of the previous year, in monetary terms.
#' `chain_aggregate()`: a `ts` (see [chain_link()] for `output = "both"`).
#' @references `r ref_imf()`
#' @references `r ref_ess()`
#' @examples
#' x <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010, output = "measure")
#' # Volumes at the prices of the previous year (additive within each year)
#' chain_unchain(x[, c("A", "B")], imf_cp, base_year = 2010)
#' # Aggregate of the components: the chain volume measure of the total
#' chain_aggregate(x[, c("A", "B")], imf_cp, base_year = 2010, output = "measure")
#' @seealso [chain_link()], [chain_laspeyres()]
#' @name chain_unchain
#' @export
chain_unchain <- function(x, cp, method = c("ao", "oqo"), base_year = NULL, pi = NULL,
						  overlap_prices = c("year_prices", "current_prices")) {
	method <- match.arg(method)
	overlap_prices <- match.arg(overlap_prices)
	inputs <- check_unchain_inputs(x, cp, method, pi, overlap_prices)
	res <- lapply(seq_len(ncol(inputs$x)), function(i) {
		unchain_parts(inputs$x[, i], inputs$cp[, i],
					  if (is.null(inputs$pi)) NULL else inputs$pi[, i],
					  method, base_year, overlap_prices)$pyp
	})
	if (length(res) == 1L)
		return(res[[1L]])
	res <- do.call(stats::ts.union, res)
	colnames(res) <- colnames(inputs$x)
	res
}

#' @rdname chain_unchain
#' @export
chain_aggregate <- function(x, cp, method = c("ao", "oqo"), base_year = NULL,
							output = c("index", "measure", "both"), pi = NULL,
							cp_total = NULL,
							overlap_prices = c("year_prices", "current_prices")) {
	method <- match.arg(method)
	output <- match.arg(output)
	overlap_prices <- match.arg(overlap_prices)
	inputs <- check_unchain_inputs(x, cp, method, pi, overlap_prices)
	parts <- lapply(seq_len(ncol(inputs$x)), function(i) {
		unchain_parts(inputs$x[, i], inputs$cp[, i],
					  if (is.null(inputs$pi)) NULL else inputs$pi[, i],
					  method, base_year, overlap_prices)
	})
	# Volume at the prices of the previous year of the aggregate, over the value of
	# the reference of the previous year (annual average, or overlap period)
	pyp <- Reduce(`+`, lapply(parts, function(p) p$pyp))
	over <- Reduce(`+`, lapply(parts, function(p) p$over))
	vo_total <- 100 * pyp / over
	if (is.null(cp_total)) {
		cp_total <- stats::ts(rowSums(inputs$cp), start = stats::start(inputs$cp),
							  frequency = stats::frequency(inputs$cp))
	}
	chain_link(vo_total, cp_total, method = method, base_year = base_year,
			   output = output)
}

check_unchain_inputs <- function(x, cp, method, pi, overlap_prices = "year_prices") {
	check_ts(x, "x")
	check_ts(cp, "cp")
	if (method == "oqo" && overlap_prices == "year_prices" && is.null(pi))
		stop("`pi` is needed for method = \"oqo\" (the overlap period is valued at ",
			 "the average prices of the year)", call. = FALSE)
	x <- as_mts(x)
	cp <- as_mts(cp)
	check_same_ncol(x, cp, "x", "cp")
	check_same_frequency(x = x, cp = cp)
	if (!is.null(pi)) {
		check_ts(pi, "pi")
		pi <- as_mts(pi)
		check_same_ncol(cp, pi, "cp", "pi")
	}
	list(x = x, cp = cp, pi = pi)
}

# Single series. Returns the volume at the prices of the previous year (`pyp`) and
# the value of the reference of the previous year (`over`: annual average of the
# current prices for the annual overlap, overlap period at the average prices of
# the year for the one-quarter overlap), so that pyp / over * 100 is the volume
# index (previous year = 100).
unchain_parts <- function(x, cp, pi, method, base_year,
						  overlap_prices = "year_prices") {
	f <- stats::frequency(x)
	x <- extend_ts(x)
	cp <- extend_ts(cp)
	base_year <- auto_base_year(vo = x, cp = cp, base_year = base_year)
	check_covers_base_year(cp, base_year)
	first <- stats::start(x)[1]
	if (base_year < first - 1)
		stop("x must start at the latest the year after the base year", call. = FALSE)
	cp_y <- stats::aggregate(cp, nfrequency = 1, FUN = sum)
	cp_base <- as.numeric(stats::window(cp_y, start = base_year, end = base_year))
	u <- x / (cp_base / f)      # chain index / 100 (reference year = 1)
	if (method == "ao") {
		level <- stats::aggregate(u, nfrequency = 1, FUN = mean)
		over_year <- cp_y / f
	} else {
		level <- stats::ts(as.numeric(u)[stats::cycle(u) == f], start = first,
						   frequency = 1)
		cy <- if (overlap_prices == "year_prices") cp_pi2cy(cp, pi) else cp
		over_year <- stats::ts(as.numeric(cy)[stats::cycle(cy) == f],
							   start = stats::start(cy)[1], frequency = 1)
		# the reference year has no price index: its overlap value is its annual average
		over_year[base_year - stats::start(over_year)[1] + 1] <- cp_base / f
	}
	# level of each year: the year before the first one is the reference year (1) or
	# unknown
	level <- stats::ts(c(if (base_year == first - 1) 1 else NA_real_, as.numeric(level)),
					   start = first - 1, frequency = 1)
	level_prev <- shift_ts(expand_years(level, f), f, x)
	over_prev <- shift_ts(expand_years(over_year, f), f, x)
	list(pyp = u / level_prev * over_prev, over = over_prev)
}
