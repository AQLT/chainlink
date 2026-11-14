#' Values at the average prices of the year
#'
#' Quarterly (or monthly) values of each period valued at the weighted average
#' prices of its own year (the column "Current Year's Prices" of the example 8.7
#' of the IMF QNA Manual). They are used by the one-quarter overlap technique: the
#' overlap period is valued at the average prices of the year, and not at its own
#' current prices.
#'
#' The value is the volume measure at the prices of the previous year,
#' \eqn{cp / pi \times 100}, multiplied by the annual price index of the year (the
#' annual current prices divided by the annual sum of the volume measures at the
#' prices of the previous year), so that the annual sum is the annual current
#' price value.
#'
#' @inheritParams cp_pi2vol
#' @param pi Price indices over the previous year (previous year average = 100),
#' with the same structure as `cp`.
#' @return A `ts` (or `mts`) with the structure of `cp` (extended to complete
#' years). It is `NA` for the years without price indices (e.g. the reference
#' year).
#' @examples
#' cp_pi2cy(data8.2cp, data8.2ep)
#' @seealso [chain_laspeyres()], [chain_contrib()]
#' @export
cp_pi2cy <- function(cp, pi) {
    check_ts(cp, "cp")
    check_ts(pi, "pi")
    check_same_ncol(cp, pi, "cp", "pi")
    f <- check_same_frequency(cp = cp, pi = pi)
    single <- is.null(dim(cp))
    cp <- extend_ts(as_mts(cp))
    pi <- shift_ts(as_mts(pi), 0, cp)
    cy <- value_at_year_prices(plain_matrix(cp), plain_matrix(pi), f)
    colnames(cy) <- colnames(cp)
    res <- stats::ts(cy, start = stats::start(cp), frequency = f)
    if (single) {
        res <- res[, 1L]
    }
    res
}

# cur, pi: plain matrices (periods x variables) with complete years
value_at_year_prices <- function(cur, pi, f) {
    evm <- cur / pi * 100 # volume at the prices of the previous year
    grp <- rep(seq_len(nrow(cur) / f), each = f) # year of each period
    cp_y <- rowsum(cur, grp)
    k_y <- rowsum(evm, grp)
    evm * (cp_y / k_y)[grp, , drop = FALSE]
}
