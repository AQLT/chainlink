#' Chain-linked Laspeyres-type volume series of a total and its components
#'
#' Chain-linked volume indices (or measures) of the components and of their total
#' in one step. For each component, the volume indices are derived from the
#' current prices and the price indices, the volume index of the total is a
#' Laspeyres-type index, and all of them are chain-linked ([chain_link()]) with
#' the annual overlap or the one-quarter overlap technique.
#'
#' With the annual overlap technique (`method = "ao"`), the volume indices are
#' those of [cp_pi2vol()] and [laspeyres()] (previous year average = 100).
#'
#' With the one-quarter overlap technique (`method = "oqo"`), the volume at the
#' prices of the previous year of each period is divided by the value of the last
#' period (quarter or month) of the previous year. This overlap period can be
#' valued in two ways (`overlap_prices`):
#'
#' * `"year_prices"` (default), as printed in the manual (paragraph 8.72 and
#' example 8.7): at the **average prices of the year** (see [cp_pi2cy()]);
#' * `"current_prices"`, as in the spreadsheet of the manual: at its **own current
#' prices**. The volume indices are then those of [cp_pi2vol()] with
#' `reference_freq = f` and `reference_cycle = f` (`f` = 4 or 12), the
#' "q4 previous year = 100" volume measures.
#'
#' As there are no price indices in the reference year, the first year is linked
#' with the annual overlap technique (footnote 32 of the manual).
#'
#' The result with `output = "measure"` can be used directly in
#' [chain_contrib()] and [chain_discrepancy()].
#'
#' @inheritParams cp_pi2vol
#' @inheritParams chain_link
#' @param cp Current prices of the components (`ts` or `mts`), without the total.
#' It must cover the base year.
#' @param pi Price indices of the components over the previous year (previous
#' year average = 100), with the same structure as `cp`.
#' @param overlap_prices Only for `method = "oqo"`: prices used to value the
#' overlap period, `"year_prices"` (average prices of the year, default) or
#' `"current_prices"` (own current prices). See details.
#'
#' @return A `ts` (`mts`): the columns of `cp` and a column `Total`. With
#' `output = "both"`, the indices then the measures of each variable
#' (see [chain_link()]).
#' @examples
#' # Annual overlap
#' chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010)
#' chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
#' 				output = "measure")
#' # One-quarter overlap (example 8.7 of the manual)
#' chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
#' 				output = "measure")
#' # Overlap quarter valued at its own current prices
#' chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
#' 				overlap_prices = "current_prices", output = "measure")
#' @seealso [chain_contrib()], [chain_discrepancy()], [cp_pi2cy()]
#' @export
chain_laspeyres <- function(
    cp,
    pi,
    method = c("ao", "oqo"),
    base_year = NULL,
    output = c("index", "measure", "both"),
    overlap_prices = c("year_prices", "current_prices")
) {
    method <- match.arg(method)
    overlap_prices <- match.arg(overlap_prices)
    output <- match.arg(output)
    check_ts(cp, "cp")
    check_ts(pi, "pi")
    check_same_ncol(cp, pi, "cp", "pi")
    f <- check_same_frequency(cp = cp, pi = pi)
    nm <- colnames(cp)
    if (is.null(nm)) {
        nm <- paste0("V", seq_len(NCOL(cp)))
    }
    if (method == "ao") {
        vo <- cp_pi2vol(cp, pi)
        vo_total <- laspeyres(cp, pi, output = "index")
        vo_all <- stats::ts.union(vo, vo_total)
    } else {
        vo_all <- oqo_indices(cp, pi, overlap_prices)
    }
    cp_total <- stats::ts(rowSums(as.matrix(cp)), start = stats::start(cp), frequency = f)
    cp_all <- stats::ts.union(cp, cp_total)
    colnames(vo_all) <- colnames(cp_all) <- c(nm, "Total")
    chain_link(vo_all, cp_all, method = method, base_year = base_year, output = output)
}

# Volume indices (overlap period of the previous year = 100) of the components
# and of the total for the one-quarter overlap technique. The first year (without
# price indices in the previous year) uses the annual average of the reference
# year as denominator (annual overlap).
oqo_indices <- function(cp, pi, overlap_prices = "year_prices") {
    cp <- extend_ts(as_mts(cp))
    pi <- shift_ts(as_mts(pi), 0, cp)
    f <- stats::frequency(cp)
    cur <- plain_matrix(cp)
    price <- plain_matrix(pi)
    n <- nrow(cur)
    ny <- n / f
    evm <- cur / price * 100 # at the prices of the previous year
    cy <- value_at_year_prices(cur, price, f) # at the average prices of the year
    grp <- rep(seq_len(ny), each = f)
    annual_avg <- rowsum(cur, grp) / f
    # overlap period of each year: at the average prices of the year or at its own
    # current prices
    overlap <- if (overlap_prices == "year_prices") cy else cur
    overlap <- overlap[seq(f, n, by = f), , drop = FALSE]
    if (overlap_prices == "year_prices") {
        first_na <- is.na(overlap[1L, ])
        overlap[1L, first_na] <- annual_avg[1L, first_na] # first year: annual overlap
    } else {
        overlap[1L, ] <- annual_avg[1L, ] # first year: annual overlap
    }
    previous <- c(NA_integer_, seq_len(ny - 1L))[grp] # previous year of each period
    den <- overlap[previous, , drop = FALSE]
    res <- cbind(evm / den * 100, rowSums(evm) / rowSums(den) * 100)
    res <- stats::ts(res, start = stats::start(cp), frequency = f)
    # remove the leading periods without indices (reference year)
    first <- which(!is.na(res[, ncol(res)]))[1L]
    stats::window(res, start = stats::time(res)[first])
}
