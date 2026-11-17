#' Values at the average prices of the year
#'
#' Quarterly (or monthly) values of each period valued at the weighted average
#' prices of its own year (the column "Current Year's Prices" of the example 8.7
#' of the IMF QNA Manual). They are used by the one-quarter overlap technique: the
#' overlap period is valued at the average prices of the year, and not at its own
#' current prices.
#'
#' The value is the volume measure at the prices of the previous year,
#' multiplied by the annual price index of the year \eqn{y} (the annual current
#' prices divided by the annual sum of the volume measures at the prices of the
#' previous year, see [pi_annual()]):
#' \deqn{cy_t = \frac{100\, cp_t}{pi_t} \times \frac{pi_y}{100}, \qquad
#' pi_y = 100 \times \frac{\sum_{q \in y} cp_q}{\sum_{q \in y} 100\, cp_q / pi_q},}
#' so that the annual sum of \eqn{cy_t} is the annual current price value.
#'
#' @inheritParams cp_pi2vol
#' @param pi Price indices over the previous year (previous year average = 100),
#' with the same structure as `cp`.
#' @return A `ts` (or `mts`) with the structure of `cp` (extended to complete
#' years). It is `NA` for the years without price indices (e.g. the reference
#' year).
#' @examples
#' cp_pi2cy(imf_cp, imf_pi)
#' @seealso [chain_laspeyres()], [chain_contrib()], [pi_annual()]
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
    evm * (weighted_annual_pi(cur, pi, f) / 100)[grp, , drop = FALSE]
}

# Weighted annual price indices (years x variables): annual current prices over
# the annual sums of the volumes at the prices of the previous year.
# cur, pi: plain matrices (periods x variables) with complete years
weighted_annual_pi <- function(cur, pi, f) {
    grp <- rep(seq_len(nrow(cur) / f), each = f)
    rowsum(cur, grp) / rowsum(cur / pi * 100, grp) * 100
}

#' Annual price indices
#'
#' Annual price indices (previous year average = 100) derived from quarterly or
#' monthly price indices over the previous year.
#'
#' With `method = "weighted"` (the default), the annual price index is the
#' weighted average of the sub-annual price indices, the weights being the volumes
#' at the prices of the previous year (\eqn{cp / pi \times 100}): it is the
#' implicit price index, i.e. the annual current prices divided by the annual sum
#' of the sub-annual volumes at the prices of the previous year,
#' \deqn{pi_y = 100 \times \frac{\sum_q cp_q}{\sum_q cp_q / pi_q \times 100}.}
#' It is consistent with the sub-annual data (as the unit value in example 8.1 of
#' the IMF QNA Manual): the annual volume at the prices of the previous year is the
#' annual sum of the sub-annual ones. This is what is used in examples 8.3, 8.8 and
#' 8.9 of the manual, and by [cp_pi2cy()].
#'
#' With `method = "mean"`, the annual price index is the simple average of the
#' sub-annual price indices: the annual volumes are then not exactly the annual
#' sums of the sub-annual ones.
#'
#' The sub-annual price indices themselves are normalised on the simple average of
#' the previous year (see [pi_py2pp()]): this is not affected by `method`.
#'
#' @param pi Quarterly or monthly price indices over the previous year (previous
#' year average = 100), `ts` or `mts`.
#' @param cp Current prices, with the same structure as `pi`. Needed for
#' `method = "weighted"`.
#' @param method `"weighted"` (default) for the weighted average of the price
#' indices (implicit annual price index), `"mean"` for their simple average.
#' @return An annual `ts` (or `mts`) with the structure of `pi`. It is `NA` for
#' the incomplete years and the years without price indices (e.g. the reference
#' year).
#' @examples
#' pi_annual(imf_pi, imf_cp)
#' pi_annual(imf_pi, method = "mean")
#' # Annual Fisher volume index (previous year = 100)
#' fisher(stats::aggregate(imf_cp), pi_annual(imf_pi, imf_cp))
#' @seealso [cp_pi2cy()], [pi_py2pp()]
#' @export
pi_annual <- function(pi, cp = NULL, method = c("weighted", "mean")) {
    method <- match.arg(method)
    check_ts(pi, "pi")
    f <- stats::frequency(pi)
    if (f == 1) {
        stop("`pi` must be quarterly or monthly", call. = FALSE)
    }
    single <- is.null(dim(pi))
    if (method == "mean") {
        res <- stats::aggregate(extend_ts(as_mts(pi)), nfrequency = 1, FUN = mean)
    } else {
        if (is.null(cp)) {
            stop(
                "`cp` is needed for method = \"weighted\" ",
                "(use method = \"mean\" for the simple average)",
                call. = FALSE
            )
        }
        check_ts(cp, "cp")
        check_same_ncol(cp, pi, "cp", "pi")
        check_same_frequency(cp = cp, pi = pi)
        pi <- extend_ts(as_mts(pi))
        cp <- shift_ts(extend_ts(as_mts(cp)), 0, pi)
        res <- weighted_annual_pi(plain_matrix(cp), plain_matrix(pi), f)
        res <- stats::ts(res, start = stats::start(pi)[1], frequency = 1)
        colnames(res) <- colnames(pi)
    }
    if (single) {
        res <- res[, 1L]
    }
    res
}
