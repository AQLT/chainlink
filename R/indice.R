#' Elementary volume indices
#'
#' Derive the elementary volume indices from current prices and price indices:
#' elementary volume measures (`cp / pi * 100`) divided by the current prices of
#' the reference period (the previous year, the previous period or a given
#' period of the previous year).
#'
#' @param cp Current prices (`ts` or `mts`).
#' @param pi Price indices (previous reference period = 100), same structure as `cp`.
#' @param reference_freq Frequency of the reference period: 1 (default) for the
#' previous year, or the frequency of the data (4 or 12) for the previous period
#' (quarter or month). It must divide the frequency of `cp`.
#' @param reference_cycle Integer to use a given period of the previous year as
#' reference (the last period of the year, 4 for quarterly data or 12 for monthly
#' data) instead of the average of the year, as needed for the one-quarter overlap
#' technique. It is used with `reference_freq` equal to the frequency of `cp`. The
#' reference period is valued at its own current prices: the one-quarter overlap
#' technique of the manual values it at the average prices of the year, see
#' [chain_laspeyres()] and [cp_pi2cy()].
#' @return A `ts` (or `mts`) of volume indices (reference period = 100).
#' @examples
#' # Volume indices over the previous year (previous-year prices)
#' cp_pi2vol(data8.2cp, data8.2ep)
#' # Volume indices over the previous quarter (price indices over the previous quarter)
#' cp_pi2vol(data8.2cp, pi_py2pp(data8.2ep), reference_freq = 4)
#' # Volume indices over the last quarter of the previous year
#' cp_pi2vol(data8.2cp, data8.2ep, reference_freq = 4, reference_cycle = 4)
#' @export
cp_pi2vol <- function(cp, pi, reference_freq = 1, reference_cycle = NULL) {
    UseMethod("cp_pi2vol", cp)
}
#' @export
cp_pi2vol.ts <- function(cp, pi, reference_freq = 1, reference_cycle = NULL) {
    cp <- extend_ts(cp)
    evm <- cp / pi * 100
    cp_y <- stats::aggregate(cp, nfrequency = reference_freq, FUN = sum)
    annual_freq <- reference_freq
    if (!is.null(reference_cycle)) {
        cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle], start = start(cp_y)[1], frequency = 1)
        annual_freq <- 1
    }
    cp_py <- stats::lag(cp_y, -1)
    cp_y_trim_py <- ts(rep(cp_py, each = frequency(cp) / annual_freq), start = start(cp_py), frequency = frequency(cp))
    vol <- evm / (cp_y_trim_py / (frequency(cp) / reference_freq)) * 100
    vol
}
#' @export
cp_pi2vol.mts <- function(cp, pi, reference_freq = 1, reference_cycle = NULL) {
    if (ncol(cp) != ncol(pi)) {
        stop("cp and pi must have the same number of variables")
    }
    vol <- do.call(
        cbind,
        lapply(1:ncol(pi), function(i) {
            cp_pi2vol(cp[, i], pi[, i], reference_freq = reference_freq, reference_cycle = reference_cycle)
        })
    )
    colnames(vol) <- colnames(cp)
    vol
}

#' Laspeyres, Paasche and Fisher volume indices
#'
#' Derive the Laspeyres-type, Paasche-type or Fisher-type volume indices of the
#' total from the current prices and the price indices of its components.
#'
#' @inheritParams cp_pi2vol
#' @param output Character if the output should be the volume index (the
#' default), the volume measure (in monetary terms) or both.
#' @param all_index (`fisher()` only) Boolean: if `TRUE`, return the Laspeyres,
#' Paasche and Fisher indices instead of the Fisher index only.
#' @return A `ts` (or `mts`).
#' @examples
#' # Laspeyres-type volume index over the previous year
#' laspeyres(data8.2cp, data8.2ep)
#' # Volume index and measure (in monetary terms)
#' paasche(data8.2cp, data8.2ep, output = "both")
#' # The three indices
#' fisher(data8.2cp, data8.2ep, all_index = TRUE)
#' # Quarter-to-quarter indices need price indices over the previous quarter
#' fisher(data8.2cp, pi_py2pp(data8.2ep), reference_freq = 4)
#' @rdname fixed_weight_indices
#' @name fixed_weight_indices
#' @export
laspeyres <- function(cp, pi, output = c("index", "measure", "both"), reference_freq = 1, reference_cycle = NULL) {
    output <- match.arg(output)
    if (is.list(cp)) {
        cp <- do.call(cbind, cp)
    }
    if (is.list(pi)) {
        pi <- do.call(cbind, pi)
    }
    cp <- extend_ts(cp)
    cp_tot <- ts(rowSums(as.matrix(cp)), start = start(cp), frequency = frequency(cp))

    cp <- window(cbind(cp, cp_tot), start = start(cp), extend = TRUE)
    # Elementary volume measures
    evm <- cp[, -ncol(cp), drop = FALSE] / pi * 100
    # Yearly current prices
    cp_y <- stats::aggregate(
        cp,
        nfrequency = reference_freq,
        FUN = sum
    )
    annual_freq <- reference_freq
    if (!is.null(reference_cycle)) {
        cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle, ], start = start(cp_y)[1], frequency = 1)
        annual_freq <- 1
    }
    cp_py <- stats::lag(cp_y, -1)
    # Yearly current prices in a low frequency (for multiplications)
    cp_y_trim_py <- ts(
        matrix(rep(cp_py, each = frequency(cp) / annual_freq), ncol = ncol(cp_y)),
        start = start(cp_py),
        frequency = frequency(cp)
    )

    evi <- evm / (cp_y_trim_py[, -ncol(cp_y_trim_py), drop = FALSE] / (frequency(cp) / reference_freq)) * 100

    lvi <- evi *
        cp_y_trim_py[, -ncol(cp_y_trim_py), drop = FALSE] /
        cp_y_trim_py[, ncol(cp_y_trim_py)]

    lvi <- ts(apply(lvi, 1, sum), start = start(lvi), frequency = frequency(lvi))

    if (output == 'index') {
        return(lvi)
    } else {
        lvm <- lvi * (cp_y_trim_py[, ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq)) / 100
        if (output == "measure") {
            return(lvm)
        } else {
            res <- cbind(lvi, lvm)
            colnames(res) <- c("Index", "Measure")
            return(res)
        }
    }
}
#' @name fixed_weight_indices
#' @export
paasche <- function(cp, pi, output = c("index", "measure", "both"), reference_freq = 1, reference_cycle = NULL) {
    output <- match.arg(output)
    if (is.list(cp)) {
        cp <- do.call(cbind, cp)
    }
    if (is.list(pi)) {
        pi <- do.call(cbind, pi)
    }
    cp <- extend_ts(cp)
    cp_tot <- ts(rowSums(as.matrix(cp)), start = start(cp), frequency = frequency(cp))

    cp <- window(cbind(cp, cp_tot), start = start(cp), extend = TRUE)
    # Elementary volume measures
    evm <- cp[, -ncol(cp), drop = FALSE] / pi * 100
    # Yearly current prices
    cp_y <- stats::aggregate(cp, nfrequency = reference_freq, FUN = sum)
    annual_freq <- reference_freq
    if (!is.null(reference_cycle)) {
        cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle, ], start = start(cp_y)[1], frequency = 1)
        annual_freq <- 1
    }
    cp_py <- stats::lag(cp_y, -1)
    # Yearly current prices in a low frequency (for multiplications)
    cp_y_trim_py <- ts(
        matrix(rep(cp_py, each = frequency(cp) / annual_freq), ncol = ncol(cp_py)),
        start = start(cp_py),
        frequency = frequency(cp)
    )
    cp_y_trim <- ts(
        matrix(rep(cp_y, each = frequency(cp) / annual_freq), ncol = ncol(cp_y)),
        start = start(cp_y),
        frequency = frequency(cp)
    )
    evi <- evm / (cp_y_trim_py[, -ncol(cp_y_trim_py), drop = FALSE] / (frequency(cp) / reference_freq)) * 100

    pvi <-
        (1 / evi) *
        cp_y_trim[, -ncol(cp_y_trim), drop = FALSE] /
        cp_y_trim[, ncol(cp_y_trim)]
    pvi <- 1 /
        ts(apply(pvi, 1, sum), start = start(pvi), frequency = frequency(pvi))

    if (output == 'index') {
        return(pvi)
    } else {
        pvm <- pvi * (cp_y_trim[, ncol(cp_y_trim)] / (frequency(cp) / reference_freq)) / 100
        if (output == "measure") {
            return(pvm)
        } else {
            res <- cbind(pvi, pvm)
            colnames(res) <- c("Index", "Measure")
            return(res)
        }
    }
}
#' @name fixed_weight_indices
#' @export
fisher <- function(
    cp,
    pi,
    output = c("index", "measure", "both"),
    all_index = FALSE,
    reference_freq = 1,
    reference_cycle = NULL
) {
    output <- match.arg(output)
    if (is.list(cp)) {
        cp <- do.call(cbind, cp)
    }
    if (is.list(pi)) {
        pi <- do.call(cbind, pi)
    }
    cp <- extend_ts(cp)
    cp_tot <- ts(rowSums(as.matrix(cp)), start = start(cp), frequency = frequency(cp))

    cp <- window(cbind(cp, cp_tot), start = start(cp), extend = TRUE)
    # Elementary volume measures
    evm <- cp[, -ncol(cp), drop = FALSE] / pi * 100
    # Yearly current prices
    cp_y <- stats::aggregate(cp, nfrequency = reference_freq, FUN = sum)
    annual_freq <- reference_freq
    if (!is.null(reference_cycle)) {
        cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle, ], start = start(cp_y)[1], frequency = 1)
        annual_freq <- 1
    }
    cp_py <- stats::lag(cp_y, -1)
    # Yearly current prices in a low frequency (for multiplications)
    cp_y_trim_py <- ts(
        matrix(rep(cp_py, each = frequency(cp) / annual_freq), ncol = ncol(cp_py)),
        start = start(cp_py),
        frequency = frequency(cp)
    )
    cp_y_trim <- ts(
        matrix(rep(cp_y, each = frequency(cp) / annual_freq), ncol = ncol(cp_y)),
        start = start(cp_y),
        frequency = frequency(cp)
    )
    evi <- evm / (cp_y_trim_py[, -ncol(cp_y_trim_py), drop = FALSE] / (frequency(cp) / reference_freq)) * 100
    lvi <- evi *
        cp_y_trim_py[, -ncol(cp_y_trim_py), drop = FALSE] /
        cp_y_trim_py[, ncol(cp_y_trim_py)]
    lvi <- ts(apply(lvi, 1, sum), start = start(lvi), frequency = frequency(lvi))

    pvi <-
        (1 / evi) *
        cp_y_trim[, -ncol(cp_y_trim), drop = FALSE] /
        cp_y_trim[, ncol(cp_y_trim)]
    pvi <- 1 /
        ts(apply(pvi, 1, sum), start = start(pvi), frequency = frequency(pvi))

    fvi <- ts.union(lvi, pvi)
    fvi <- ts(exp(apply(log(fvi), 1, mean)), start = start(fvi), frequency = frequency(fvi))
    all_vi <- ts.union(lvi, pvi, fvi)
    colnames(all_vi) <- c("Laspeyres", "Paasche", "Fisher")
    if (output == 'index') {
        if (all_index) {
            all_vi
        } else {
            all_vi[, "Fisher"]
        }
    } else {
        all_vm <- all_vi * (cp_y_trim_py[, ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq)) / 100
        if (output == "measure") {
            if (all_index) {
                all_vm
            } else {
                all_vm[, "Fisher"]
            }
        } else {
            if (all_index) {
                res <- cbind(all_vi, all_vm)
                colnames(res) <- paste(rep(colnames(all_vi), 2), rep(c("Index", "Measure"), each = 3))
                res
            } else {
                res <- cbind(all_vi[, "Fisher"], all_vm[, "Fisher"])
                colnames(res) <- c("Index", "Measure")
                res
            }
        }
    }
}

#' Price indices over the previous period
#'
#' Convert price indices expressed over the previous year (average of the
#' previous year = 100, as in the examples 8.2 and 8.3 of the IMF QNA Manual)
#' into price indices over the previous period (quarter or month), as needed by
#' [laspeyres()], [paasche()] and [fisher()] with `reference_freq` equal to the
#' frequency of the data.
#'
#' With \eqn{i_t} the index over the previous year, the index over the previous
#' period is \eqn{100 i_t / i_{t-1}} within a year, and
#' \eqn{i_t / i_{t-1} \times \bar{i}_{y-1}} for the first period of year \eqn{y}
#' (\eqn{\bar{i}_{y-1}} is the average of the indices of the previous year, which
#' is the annual price index of year \eqn{y-1}).
#'
#' @param pi Price indices over the previous year (`ts` or `mts`, quarterly or
#' monthly). Leading and trailing missing values are ignored.
#' @param previous Value, over the previous year, assumed for the period before
#' the first one (default: 100, i.e. the prices of that period are those of the
#' average of its year).
#' @return A `ts` (or `mts`) of price indices (previous period = 100).
#' @examples
#' pi_py2pp(data8.2ep)
#' @export
pi_py2pp <- function(pi, previous = 100) {
    check_ts(pi, "pi")
    if (is.null(dim(pi))) {
        return(pi_py2pp_ts(pi, previous))
    }
    x <- as_mts(pi)
    res <- lapply(seq_len(ncol(x)), function(i) pi_py2pp_ts(x[, i], previous))
    if (length(res) == 1L) {
        return(res[[1L]])
    }
    res <- do.call(stats::ts.union, res)
    colnames(res) <- colnames(x)
    res
}

pi_py2pp_ts <- function(x, previous = 100) {
    f <- stats::frequency(x)
    if (f == 1) {
        stop("price indices must be quarterly or monthly")
    }
    # Leading and trailing missing values (e.g. no price index in the base year)
    x <- stats::na.omit(x)
    x <- stats::ts(as.numeric(x), start = stats::start(x), frequency = f)
    x <- extend_ts(x)
    m_y <- stats::aggregate(x, nfrequency = 1, FUN = mean)
    m_q <- stats::ts(rep(as.numeric(m_y), each = f), start = c(stats::start(m_y)[1], 1), frequency = f)
    # average of the indices of the previous year, on each period
    fac <- as.numeric(shift_ts(m_q, f, x))
    fac[as.numeric(stats::cycle(x)) != 1] <- 100
    res <- x / shift_ts(x, 1) * fac
    res[1] <- x[1] / previous * 100
    res
}
