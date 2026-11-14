#' Extend series to the start and end of the year
#'
#' @param x Time series
#' @param start Boolean indicating if the series must be extended at the start.
#' @param end Boolean indicating if the series must be extended at the end.
#' @noRd
extend_ts <- function(x, start = TRUE, end = TRUE) {
    first_date <- stats::start(x)
    last_date <- stats::end(x)
    if (start && first_date[2] != 1) {
        x <- stats::window(x, start = c(first_date[1], 1), extend = TRUE)
    }
    if (end && last_date[2] != stats::frequency(x)) {
        x <- stats::window(x, end = c(last_date[1], stats::frequency(x)), extend = TRUE)
    }
    x
}

# Year of the base period: by default, the year before the first year of the
# volume series (or the first year of current prices, if later).
auto_base_year <- function(vo, cp = NULL, base_year = NULL) {
    if (is.null(base_year)) {
        if (is.null(cp)) {
            base_year <- stats::start(vo)[1] - 1
        } else {
            base_year <- max(stats::start(vo)[1] - 1, stats::start(cp)[1])
        }
    }
    base_year
}

# Always work with a matrix-like ts (named columns)
as_mts <- function(x) {
    nm <- colnames(x)
    x <- stats::ts(matrix(x, ncol = NCOL(x)), start = stats::start(x), frequency = stats::frequency(x))
    colnames(x) <- if (is.null(nm)) paste0("V", seq_len(ncol(x))) else nm
    x
}

# Value of `a` k periods earlier, on the span of `like` (NA when unavailable).
# Unlike stats::lag(), the span never changes, so that no implicit intersection
# of spans happens in later arithmetic. k = 0 simply aligns `a` on `like`.
shift_ts <- function(a, k = 1, like = a) {
    stats::window(stats::lag(a, -k), start = stats::start(like), end = stats::end(like), extend = TRUE)
}

# Plain numeric matrix (without the ts attributes, so that cbind() and rbind()
# do not dispatch on the ts methods)
plain_matrix <- function(x) {
    matrix(as.numeric(x), nrow = NROW(x), ncol = NCOL(x), dimnames = list(NULL, colnames(x)))
}

# Annual series (ts of frequency 1) repeated on each period of the year
expand_years <- function(a, f) {
    stats::ts(rep(as.numeric(a), each = f), start = c(stats::start(a)[1], 1), frequency = f)
}
