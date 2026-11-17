#' Contributions to percent change of a Fisher volume index
#'
#' Exact contributions of the components to the percent change, from the previous
#' period (quarter, month or year) to the current one, of the Fisher volume index
#' of their aggregate (equation (32) of the paragraph 8.89 of the IMF QNA Manual).
#'
#' With \eqn{x^t} the current price value of the component \eqn{x} in period
#' \eqn{t}, \eqn{z^t} the one of the aggregate, \eqn{r_j = p_j^t / p_j^{t-1}}
#' the price index of the component \eqn{j} over the previous period, and
#' \eqn{F} the Fisher volume index of the aggregate (previous period = 1), the
#' contribution of the component \eqn{x} is
#' \deqn{100 \frac{\frac{z^t}{z^{t-1}} \left(x^t / r_x - x^{t-1}\right) +
#' F \left(x^t - x^{t-1} r_x\right)}{z^t + F \sum_j x_j^{t-1} r_j}.}
#' Contributions add up exactly to the percent change of the Fisher index,
#' whatever the number of components.
#'
#' The formula as printed in the manual has the ratio \eqn{z^{t-1} / z^t} in the
#' first term and \eqn{x^{t-1} p_x^{t-1} / p_x^t} in the second one. With these
#' ratios the contributions do not add up to the percent change (checked
#' numerically), so that the formula implemented corrects them
#' (\eqn{z^t / z^{t-1}} and \eqn{x^{t-1} p_x^t / p_x^{t-1}}, consistent with
#' the denominator). Among the variants of the formula that were tested, it is the
#' only one that is exact.
#'
#' The adjustments that some countries add to the quarterly contributions
#' (benchmarking of the quarterly Fisher indices on the annual ones, percent
#' changes at annual rates) are not done. As recommended by the manual (paragraph
#' 8.90), the contribution of a variable that can be negative, zero or positive
#' (such as changes in inventories) should be calculated residually, as the
#' difference between the contribution of the aggregate that includes it and the
#' contributions of the other components.
#'
#' @param cp Current prices of all the components of the aggregate (`ts` or
#' `mts`). The aggregate is their sum.
#' @param pi Price indices of the components over the previous period (previous
#' quarter, month or year = 100), with the same structure as `cp`. Price indices
#' over the previous year can be converted with [pi_py2pp()].
#' @param extra Additional columns: `"total"` adds the percent change of the
#' Fisher volume index, and `"residual"` the difference between this percent
#' change and the sum of the contributions (zero, up to numerical errors).
#'
#' @return A `ts` (or `mts`) of contributions, in percentage points, with the
#' span and the columns of `cp` (followed by `Total` and/or `Residual`). The first
#' period is `NA`.
#' @references
#' Chevalier, M. (2003), "Chain Fisher Volume Index Methodology", Statistics
#' Canada (formula drawn from the appendix II).
#' @references `r ref_imf()`
#' @examples
#' # Price indices over the previous quarter (example 8.4)
#' ep <- pi_py2pp(imf_pi)
#' fisher_contrib(imf_cp, ep, extra = c("total", "residual"))
#' @seealso [fisher()], [chain_contrib()]
#' @export
fisher_contrib <- function(cp, pi, extra = NULL) {
    check_ts(cp, "cp")
    check_ts(pi, "pi")
    if (!is.null(extra)) {
        extra <- match.arg(extra, c("total", "residual"), several.ok = TRUE)
    }
    cp <- as_mts(cp)
    pi <- as_mts(pi)
    check_same_ncol(cp, pi, "cp", "pi")
    f <- check_same_frequency(cp = cp, pi = pi)
    # same span as cp (no extension to complete years: it is not needed here)
    pi <- shift_ts(pi, 0, cp)
    n <- nrow(cp)
    k <- ncol(cp)
    if (n < 2L) {
        stop("At least two periods are needed", call. = FALSE)
    }

    cur <- plain_matrix(cp)
    prev <- rbind(rep(NA_real_, k), cur[-n, , drop = FALSE])
    r <- plain_matrix(pi) / 100
    z_cur <- rowSums(cur)
    z_prev <- rowSums(prev)

    laspeyres_idx <- rowSums(cur / r) / z_prev # sum(p0 q1) / sum(p0 q0)
    s10 <- rowSums(prev * r) # sum(p1 q0)
    paasche_idx <- z_cur / s10 # sum(p1 q1) / sum(p1 q0)
    fisher_idx <- sqrt(laspeyres_idx * paasche_idx)

    a <- cur / r - prev # x^t p^{t-1} / p^t - x^{t-1}
    b <- cur - prev * r # x^t - x^{t-1} p^t / p^{t-1}
    # equation (32) of the manual
    contrib <- 100 * ((z_cur / z_prev) * a + fisher_idx * b) / (z_cur + fisher_idx * s10)
    colnames(contrib) <- colnames(cp)

    if (!is.null(extra)) {
        if ("total" %in% extra) {
            contrib <- cbind(contrib, Total = 100 * (fisher_idx - 1))
        }
        if ("residual" %in% extra) {
            comp <- contrib[, seq_len(k), drop = FALSE]
            contrib <- cbind(contrib, Residual = 100 * (fisher_idx - 1) - rowSums(comp))
        }
    } else if (k == 1L) {
        return(stats::ts(contrib[, 1L], start = stats::start(cp), frequency = f))
    }
    stats::ts(contrib, start = stats::start(cp), frequency = f)
}
