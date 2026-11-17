#' Chain-linking
#'
#' Chain-linking of volume indices. `chain_link()` links sub-annual (quarterly or
#' monthly) volume indices with the annual overlap (`"ao"`) or the one-quarter
#' overlap (`"oqo"`) technique; `annual_chain()` chains annual links.
#'
#' With \eqn{v_t} the volume index of period \eqn{t} (year \eqn{y(t)}) over the
#' reference of the previous year, the annual link of year \eqn{y} is
#' \eqn{\lambda_y = \bar{v}_y / 100} (annual average, `"ao"` and `annual_chain()`)
#' or \eqn{\lambda_y = v_{y,f} / 100} (overlap period, the last one of the year,
#' `"oqo"`). With the reference year \eqn{b}, the chain level of year \eqn{y} is
#' \eqn{\Lambda_y = \prod_{k=b+1}^{y} \lambda_k} (\eqn{\Lambda_b = 1}) and the
#' chain index is
#' \deqn{I_t = \Lambda_{y(t)-1}\, v_t}
#' for sub-annual series (`chain_link()`) and \eqn{I_y = 100\, \Lambda_y} for
#' annual series (`annual_chain()`). The chain volume measure is
#' \eqn{I_t\, cp_b / (100 f)}, with \eqn{cp_b} the annual current prices of the
#' reference year and \eqn{f} the frequency (1 for `annual_chain()`).
#' To compute the volume indices of a total from its components, see
#' [chain_laspeyres()].
#'
#' @param vo Volume indices (`ts` or `mts`):
#' * `method = "ao"`: volume indices with the average of the previous year = 100
#' (output of [cp_pi2vol()] or [laspeyres()] with the default `reference_freq = 1`);
#' * `method = "oqo"`: volume indices with the overlap period of the previous year
#' (its last quarter or month, valued at the average prices of the previous year)
#' = 100: see [chain_laspeyres()], which builds them as in the manual;
#' * `annual_chain()`: annual or sub-annual indices with the previous year = 100
#' (sub-annual indices are averaged by year).
#' @param cp Current prices, optional (same number of variables as `vo`). Needed
#' for `output = "measure"` or `"both"`. It must cover the base year.
#' @param method Chain-linking technique: `"ao"` for annual overlap, `"oqo"` for
#' one-quarter overlap (for monthly series, the overlap period is the last month
#' of the year).
#' @param base_year Reference year (index = 100). By default, the year before the
#' start of `vo` (or the first year of `cp`, if later).
#' @param output Chain index (the default), chain volume measure (in monetary
#' terms, i.e. the index times the base-year current prices) or both.
#'
#' @return A `ts` (or `mts`). With `output = "both"`, the columns are the
#' indices then the measures of each variable.
#' @references `r ref_imf()`
#' @examples
#' # Annual overlap: volume indices over the previous year
#' vo <- cp_pi2vol(imf_cp, imf_pi)
#' chain_link(vo, imf_cp, method = "ao", base_year = 2010)
#' chain_link(vo, imf_cp, method = "ao", base_year = 2010, output = "measure")
#'
#' # One-quarter overlap: the volume indices over the overlap quarter are built by
#' # chain_laspeyres(), which also chains them
#' chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010)
#'
#' # Annual chain index from annual Fisher indices
#' fis <- fisher(stats::aggregate(imf_cp), pi_annual(imf_pi, imf_cp))
#' annual_chain(fis, base_year = 2010)
#' @export
chain_link <- function(
    vo,
    cp = NULL,
    method = c("ao", "oqo"),
    base_year = NULL,
    output = c("index", "measure", "both")
) {
    method <- match.arg(method)
    output <- match.arg(output)
    chain_apply(vo, cp, base_year, output, link_fun = function(x) subannual_links(x, method), subannual = TRUE)
}

#' @rdname chain_link
#' @export
annual_chain <- function(vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
    output <- match.arg(output)
    chain_apply(vo, cp, base_year, output, link_fun = annual_links, subannual = FALSE)
}

# Annual links (ratio year / previous year) from the indices
annual_links <- function(vo) {
    stats::aggregate(vo, nfrequency = 1, FUN = mean) / 100
}
subannual_links <- function(vo, method) {
    f <- stats::frequency(vo)
    if (method == "ao") {
        annual_links(vo)
    } else {
        # oqo: overlap period (last quarter or month) / the one of the previous year
        stats::ts(vo[stats::cycle(vo) == f] / 100, start = stats::start(vo)[1], frequency = 1)
    }
}

# Loop over the columns, then bind the results
chain_apply <- function(vo, cp, base_year, output, link_fun, subannual) {
    check_ts(vo, "vo")
    vo <- as_mts(vo)
    if (!is.null(cp)) {
        check_ts(cp, "cp")
        cp <- as_mts(cp)
        check_same_ncol(vo, cp, "vo", "cp")
        check_same_frequency(vo = vo, cp = cp)
    } else if (output != "index") {
        stop("cp variable must be defined", call. = FALSE)
    }
    res <- lapply(seq_len(ncol(vo)), function(i) {
        chain_link_ts(vo[, i], if (is.null(cp)) NULL else cp[, i], base_year, output, link_fun, subannual)
    })
    if (ncol(vo) == 1L && output != "both") {
        return(res[[1L]])
    }
    res <- do.call(stats::ts.union, res)
    if (output == "both") {
        colnames(res) <- paste(rep(colnames(vo), each = 2), rep(c("Index", "Measure"), ncol(vo)))
        if (ncol(vo) == 1L) {
            colnames(res) <- c("Index", "Measure")
        }
    } else {
        colnames(res) <- colnames(vo)
    }
    res
}

chain_link_ts <- function(vo, cp, base_year, output, link_fun, subannual) {
    f <- stats::frequency(vo)
    vo <- extend_ts(vo)
    if (!is.null(cp)) {
        cp <- extend_ts(cp)
    }
    base_year <- auto_base_year(vo = vo, cp = cp, base_year = base_year)
    if (!is.null(cp) && output != "index") {
        check_covers_base_year(cp, base_year)
    }

    link <- link_fun(vo)
    first <- stats::start(link)[1]
    if (base_year < first - 1) {
        stop("vo must start at the latest the year after the base year", call. = FALSE)
    }
    # The year before the first link is the starting point of the chain
    link <- stats::ts(c(1, as.numeric(link)), start = first - 1, frequency = 1)
    # Chain level of each year, with the base year = 1
    level <- stats::ts(cumprod(as.numeric(link)), start = first - 1, frequency = 1)
    level <- level / as.numeric(stats::window(level, start = base_year, end = base_year))

    if (subannual) {
        # Periods of year y are linked with the level of year y - 1;
        # vo is already in base 100, so is the result
        level_p <- stats::ts(rep(as.numeric(level), each = f), start = first - 1, frequency = f)
        ind <- shift_ts(level_p, f, vo) * vo
    } else {
        ind <- level * 100
    }
    if (output == "index") {
        return(ind)
    }

    cp_y <- stats::aggregate(cp, nfrequency = 1, FUN = sum)
    cp_base <- as.numeric(stats::window(cp_y, start = base_year, end = base_year))
    # monetary terms: base-year current prices (per period for sub-annual series)
    meas <- ind * (cp_base / (if (subannual) f else 1)) / 100
    if (output == "measure") {
        return(meas)
    }
    res <- stats::ts.union(ind, meas)
    colnames(res) <- c("Index", "Measure")
    res
}
