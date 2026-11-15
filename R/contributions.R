#' Contributions to percent change of chain-linked volume measures
#'
#' Exact contributions of the components to the percent change of a total
#' chain-linked with the annual overlap (`"ao"`) or the one-quarter overlap
#' (`"oqo"`) technique (IMF QNA Manual, chapter 8, example 8.9).
#'
#' Let \eqn{x_t} be the chain volume measure of a component and \eqn{z_t} the
#' one of the total. Within year \eqn{y}, the total is exactly
#' \eqn{z_t = \sum_i \rho_{i,y-1} x_{i,t}}, where \eqn{\rho_{i,y-1}} is the
#' relative price (price of the component / price of the total) of the
#' previous year:
#' * `method = "ao"`: \eqn{\rho_y = (cp^x_y / x_y) / (cp^z_y / z_y)} with annual
#' sums;
#' * `method = "oqo"`: the same ratio computed on the overlap period (the last
#' period of the year), with the values at the average prices of the year
#' ([cp_pi2cy()]). In the reference year, the ratio is 1 (the first year is linked
#' with the annual overlap technique).
#'
#' The contribution to the growth between a period \eqn{s} and a period \eqn{t}
#' (previous period, same period of the previous year, or previous year) is
#' \deqn{100 \left[ \frac{(x_t - x_s)\rho_{y(t)-1}}{z_s} +
#' \left(\frac{x_s}{z_s} - a_{y(t)-1}\right)(\rho_{y(t)-1} - \rho_{y(s)-1})\right]}
#' where \eqn{a_y = x_y / z_y} (annual overlap) or the share of the overlap
#' period (one-quarter overlap). The second term is zero when \eqn{s} and
#' \eqn{t} are in the same year, and for the annual overlap technique it is also
#' zero for annual growth. For the growth over the previous period with the annual
#' overlap technique, it gives the formulas of the example 8.9.
#' Contributions add up to the growth of the total (up to the inconsistencies
#' of the data: see `extra = "residual"`).
#'
#' For the annual overlap technique, `type = "period"` and `type = "annual"` are
#' the equations (29) and (30) of the manual (paragraphs 8.86 and 8.87, example
#' 8.9) and `type = "yoy"` is the equation (31) (paragraph 8.88).
#'
#' For the one-quarter overlap technique, the manual (footnote 35) applies the
#' same formulas with the annual deflators, but the contributions are then not
#' exactly additive. With `method = "oqo"`, the deflators of the overlap period are
#' used, so that contributions add up exactly. The formulas of the manual can be
#' obtained with `method = "ao"` applied to the one-quarter overlap measures.
#'
#' As recommended by the manual (paragraph 8.90), the contribution of a variable
#' that can be negative, zero or positive (such as changes in inventories) should
#' be calculated residually: the difference between the contribution of the
#' aggregate that includes it and the contributions of the other components.
#'
#' Series can be monthly: the "overlap period" is then the last month of the
#' year.
#'
#' @param vo Chain volume measures (in monetary terms) of the components
#' (`ts` or `mts`), as returned by [chain_link()] or [chain_laspeyres()] with
#' `output = "measure"`. If `vo_total` is `NULL`, the last column of `vo` is the
#' total (as returned by [chain_laspeyres()]).
#' @param cp Current prices of the components (same number of columns as `vo`,
#' without the total). It must cover the base year.
#' @param vo_total Chain volume measure of the total (`ts`). It cannot be deduced
#' from `vo` because chain measures are not additive. By default (`NULL`), the
#' last column of `vo` is used (and the last column of `cp` is the total of the
#' current prices, if `cp` has one more column than the components).
#' @param cp_total Current prices of the total. By default, the sum of `cp`
#' (only valid if `cp` contains all the components).
#' @param pi Price indices of the components over the previous year (previous year
#' average = 100), needed for `method = "oqo"` to value the overlap period at the
#' average prices of the year (see [cp_pi2cy()]). If `NULL`, `cp` must already be
#' valued at the average prices of the year (`cp_pi2cy()`).
#' @param overlap_prices Only for `method = "oqo"`: prices used to value the
#' overlap period when `vo` was computed, `"year_prices"` (average prices of the
#' year, default) or `"current_prices"` (own current prices): see
#' [chain_laspeyres()]. With `"current_prices"`, `cp` is used as it is and `pi`
#' is not needed.
#' @param method Chain-linking technique used to compute `vo` and `vo_total`:
#' `"ao"` (annual overlap) or `"oqo"` (one-quarter overlap, built as in the
#' manual: see [chain_laspeyres()]).
#' @param type Growth to decompose: `"period"` (default) for the growth over the
#' previous period (quarter or month), `"yoy"` for the growth over the same
#' period of the previous year, `"annual"` for the growth of the annual sums.
#' For `method = "oqo"`, the contributions to annual growth are only defined
#' from the second year (the annual sum of the base year is not defined).
#' @param base_year Reference year of the chain measures. By default, the year
#' before the start of `vo` (or the first year of `cp`, if later).
#' @param extra Additional columns: `"total"` adds the growth of the total, and
#' `"residual"` the difference between this growth and the sum of the
#' contributions (non-additivity). Default: none.
#'
#' @return A `ts` (or `mts`) of contributions, in percentage points, with the
#' same columns as `vo` (followed by `Total` and/or `Residual`). It has the span
#' of `vo` (extended to complete years), with `NA` when a contribution cannot be
#' computed (e.g. the first periods).
#' @examples
#' # Chain volume measures of the components and of the total (last column)
#' x <- chain_laspeyres(imf_cp, imf_pi, method = "ao", base_year = 2010,
#' 					 output = "measure")
#' # Contributions to the growth over the previous quarter
#' chain_contrib(x, imf_cp, method = "ao", extra = c("total", "residual"))
#' # Contributions to the growth over the same quarter of the previous year
#' chain_contrib(x, imf_cp, method = "ao", type = "yoy")
#' # Contributions to the growth of the annual sums
#' chain_contrib(x, imf_cp, method = "ao", type = "annual")
#'
#' # One-quarter overlap
#' x_oqo <- chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
#' 						 output = "measure")
#' chain_contrib(x_oqo, imf_cp, method = "oqo", type = "yoy", pi = imf_pi)
#' # One-quarter overlap, overlap quarter at its own current prices
#' x_cp <- chain_laspeyres(
#'   imf_cp, imf_pi, method = "oqo", base_year = 2010,
#' 	 overlap_prices = "current_prices", output = "measure"
#' )
#' chain_contrib(x_cp, imf_cp, method = "oqo", type = "yoy",
#' 			  overlap_prices = "current_prices")
#' @seealso [chain_laspeyres()], [chain_link()], [chain_discrepancy()],
#' [fisher_contrib()]
#' @export
chain_contrib <- function(
    vo,
    cp,
    vo_total = NULL,
    cp_total = NULL,
    method = c("ao", "oqo"),
    type = c("period", "yoy", "annual"),
    base_year = NULL,
    extra = NULL,
    pi = NULL,
    overlap_prices = c("year_prices", "current_prices")
) {
    method <- match.arg(method)
    overlap_prices <- match.arg(overlap_prices)
    type <- match.arg(type)
    if (!is.null(extra)) {
        extra <- match.arg(extra, c("total", "residual"), several.ok = TRUE)
    }
    check_ts(vo, "vo")
    check_ts(cp, "cp")
    vo <- as_mts(vo)
    cp <- as_mts(cp)
    if (is.null(vo_total)) {
        # The last column of vo is the total (see chain_laspeyres())
        if (ncol(vo) < 2L) {
            stop("`vo_total` must be provided, or the last column of `vo` must be the total", call. = FALSE)
        }
        vo_total <- vo[, ncol(vo)]
        vo <- vo[, -ncol(vo), drop = FALSE]
        if (ncol(cp) == ncol(vo) + 1L) {
            if (is.null(cp_total)) {
                cp_total <- cp[, ncol(cp)]
            }
            cp <- cp[, -ncol(cp), drop = FALSE]
        }
    }
    check_ts(vo_total, "vo_total")
    check_same_ncol(vo, cp, "vo", "cp")
    if (method == "oqo" && overlap_prices == "year_prices" && !is.null(pi)) {
        # Values at the average prices of the year; the reference year (no price
        # index) keeps the current prices, only its annual sum is used
        check_ts(pi, "pi")
        pi <- as_mts(pi)
        check_same_ncol(cp, pi, "cp", "pi")
        cp_ext <- extend_ts(cp)
        cur <- plain_matrix(cp_ext)
        m <- plain_matrix(as_mts(cp_pi2cy(cp, pi)))
        f <- stats::frequency(cp_ext)
        years <- stats::start(cp_ext)[1] + (seq_len(nrow(cur)) - 1) %/% f
        until <- if (is.null(base_year)) stats::start(vo)[1] - 1 else base_year
        fill <- is.na(m) & (years <= until)
        m[fill] <- cur[fill]
        colnames(m) <- colnames(cp_ext)
        cp <- stats::ts(m, start = stats::start(cp_ext), frequency = f)
        cp_total <- stats::ts(rowSums(m), start = stats::start(cp_ext), frequency = f)
    }
    if (is.null(cp_total)) {
        cp_total <- stats::ts(rowSums(cp), start = stats::start(cp), frequency = stats::frequency(cp))
    }
    res <- lapply(seq_len(ncol(vo)), function(i) {
        contrib_chain_ts(
            x = vo[, i],
            z = vo_total,
            cx = cp[, i],
            cz = cp_total,
            method = method,
            type = type,
            base_year = base_year
        )
    })
    if (length(res) == 1L) {
        res <- res[[1L]]
    } else {
        res <- do.call(stats::ts.union, res)
        colnames(res) <- colnames(vo)
    }
    if (is.null(extra)) {
        return(res)
    }

    growth <- total_growth_chain(vo_total, cp_total, method, type, base_year, vo, cp)
    u <- stats::ts.union(res, growth)
    comp <- u[, seq_len(ncol(vo)), drop = FALSE]
    colnames(comp) <- colnames(vo)
    g <- u[, ncol(u)]
    out <- list(comp)
    if ("total" %in% extra) {
        out$Total <- g
    }
    if ("residual" %in% extra) {
        out$Residual <- g - stats::ts(rowSums(comp), start = stats::start(comp), frequency = stats::frequency(comp))
    }
    out_ts <- do.call(stats::ts.union, out)
    # do.call() would otherwise deparse the matrix to name its columns
    colnames(out_ts) <- c(colnames(vo), names(out)[-1L])
    out_ts
}

# Prepare the series (same frequency, full years, same span) and the base year
prepare_chain <- function(x, z, cx, cz, base_year) {
    f <- check_same_frequency(x = x, z = z, cx = cx, cz = cz)
    x <- extend_ts(x)
    z <- shift_ts(extend_ts(z), 0, x)
    cx <- extend_ts(cx)
    cz <- extend_ts(cz)
    if (is.null(base_year)) {
        base_year <- auto_base_year(vo = x, cp = cx)
    }
    check_covers_base_year(cx, base_year)
    if (stats::start(x)[1] > base_year + 1) {
        stop("vo must start at the latest the year after the base year", call. = FALSE)
    }
    list(x = x, z = z, cx = cx, cz = cz, base_year = base_year, f = f)
}

# Annual sums, and relative prices and shares used for the weights.
# Returns annual ts: X, Z (annual measures), rho (relative price of the
# component) and anchor (share of the component in the total) for each year,
# from the base year.
chain_weights <- function(p, method) {
    f <- p$f
    agg <- function(s) stats::aggregate(s, nfrequency = 1, FUN = sum)
    cx_y <- agg(p$cx)
    cz_y <- agg(p$cz)
    if (method == "ao") {
        # In the base year, chain measures = current prices
        X <- fill_base_year(agg(p$x), cx_y, p$base_year)
        Z <- fill_base_year(agg(p$z), cz_y, p$base_year)
        rho <- (cx_y / X) / (cz_y / Z)
        anchor <- X / Z
    } else {
        # Overlap period: last period of each year. In the base year, the chain
        # measure of the overlap period is the annual current price / f.
        last <- function(s) {
            stats::ts(as.numeric(s)[stats::cycle(s) == f], start = stats::start(s)[1], frequency = 1)
        }
        x_o <- fill_base_year(last(p$x), cx_y / f, p$base_year)
        z_o <- fill_base_year(last(p$z), cz_y / f, p$base_year)
        cx_o <- last(p$cx)
        cz_o <- last(p$cz)
        if (stats::start(p$x)[1] > p$base_year) {
            # The base year is not in the chain measures: the first year is linked
            # with the annual overlap technique, the overlap value of the base year
            # is its annual average (so that the relative price is 1)
            pos <- p$base_year - stats::start(cx_o)[1] + 1
            cx_o[pos] <- as.numeric(stats::window(cx_y, start = p$base_year, end = p$base_year)) / f
            cz_o[pos] <- as.numeric(stats::window(cz_y, start = p$base_year, end = p$base_year)) / f
        }
        rho <- (cx_o / x_o) / (cz_o / z_o)
        anchor <- x_o / z_o
        X <- agg(p$x)
        Z <- agg(p$z)
    }
    list(X = X, Z = Z, rho = rho, anchor = anchor)
}

# Single component. x, z: chain measures (component, total);
# cx, cz: current prices (component, total).
contrib_chain_ts <- function(x, z, cx, cz, method, type, base_year = NULL) {
    p <- prepare_chain(x, z, cx, cz, base_year)
    f <- p$f
    w <- chain_weights(p, method)

    if (f == 1 || type == "annual") {
        s <- stats::aggregate(p$x, nfrequency = 1, FUN = sum) # years of x
        rho_t <- shift_ts(w$rho, 1, s)
        rho_s <- shift_ts(w$rho, 2, s)
        a <- shift_ts(w$anchor, 1, s)
        x_t <- shift_ts(w$X, 0, s)
        x_s <- shift_ts(w$X, 1, s)
        z_s <- shift_ts(w$Z, 1, s)
    } else {
        k <- if (type == "period") 1 else f
        to_period <- function(a) {
            stats::ts(rep(as.numeric(a), each = f), start = c(stats::start(a)[1], 1), frequency = f)
        }
        rho_p <- to_period(w$rho)
        anchor_p <- to_period(w$anchor)
        x_t <- p$x
        rho_t <- shift_ts(rho_p, f, x_t) # rho_{y(t)-1}
        rho_s <- shift_ts(rho_p, f + k, x_t) # rho_{y(s)-1}
        a <- shift_ts(anchor_p, f, x_t) # share at the overlap of y(t)-1
        x_s <- shift_ts(p$x, k)
        z_s <- shift_ts(p$z, k)
    }
    main <- (x_t - x_s) * rho_t / z_s
    d <- x_s / z_s - a
    reval <- d * (rho_t - rho_s)
    # When d is exactly zero, rho_s is not needed (it can be unavailable)
    zero <- !is.na(as.numeric(d)) & as.numeric(d) == 0
    reval[zero] <- 0
    100 * (main + reval)
}

# Growth (in %) of the total chain measure
total_growth_chain <- function(z, cz, method, type, base_year, vo, cp) {
    f <- stats::frequency(z)
    z <- extend_ts(z)
    if (f == 1 || type == "annual") {
        agg <- function(s) stats::aggregate(s, nfrequency = 1, FUN = sum)
        s <- agg(z)
        Z <- s
        if (method == "ao") {
            if (is.null(base_year)) {
                base_year <- auto_base_year(vo = extend_ts(vo[, 1]), cp = extend_ts(cp[, 1]))
            }
            Z <- fill_base_year(s, agg(extend_ts(cz)), base_year)
        }
        return(100 * (shift_ts(Z, 0, s) / shift_ts(Z, 1, s) - 1))
    }
    k <- if (type == "period") 1 else f
    100 * (z / shift_ts(z, k) - 1)
}

# If the base year is not in the chain measures (they start the year after),
# use current prices for the base year.
fill_base_year <- function(a_y, c_y, base_year) {
    first <- stats::start(a_y)[1]
    if (first > base_year) {
        base <- stats::window(c_y, start = base_year, end = first - 1)
        a_y <- stats::ts(c(as.numeric(base), as.numeric(a_y)), start = base_year, frequency = 1)
    }
    a_y
}
