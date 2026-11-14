# Input checks, with homogeneous error messages

check_ts <- function(x, arg) {
    if (!stats::is.ts(x)) {
        stop("`", arg, "` must be a time series (class ts or mts)", call. = FALSE)
    }
    invisible(x)
}

# All the series must have the same frequency
check_same_frequency <- function(...) {
    x <- list(...)
    f <- vapply(x, stats::frequency, numeric(1))
    if (length(unique(f)) > 1L) {
        stop(
            "All the series must have the same frequency (found: ",
            paste(paste0(names(x), " = ", f), collapse = ", "),
            ")",
            call. = FALSE
        )
    }
    invisible(f[[1L]])
}

# Series (components) must have the same number of variables
check_same_ncol <- function(x, y, arg_x, arg_y) {
    if (NCOL(x) != NCOL(y)) {
        stop(
            "`",
            arg_x,
            "` and `",
            arg_y,
            "` must have the same number of ",
            "variables (",
            NCOL(x),
            " and ",
            NCOL(y),
            ")",
            call. = FALSE
        )
    }
    invisible(TRUE)
}

# Current prices must cover the base year
check_covers_base_year <- function(cp, base_year) {
    if (stats::start(cp)[1] > base_year || stats::end(cp)[1] < base_year) {
        stop("cp must cover the base year (", base_year, ")", call. = FALSE)
    }
    invisible(TRUE)
}
