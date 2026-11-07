#' Extend series to the start and end of the year
#'
#' @param x Time series
#' @param start Boolean indicating if the series must be extended at the start.
#' @param end Boolean indicating if the series must be extended at the end.
extend_ts <- function(x, start = TRUE, end = TRUE) {
	first_date <- stats::start(x)
	last_date <- stats::end(x)
	if (start && first_date[2] != 1) {
		x <- window(x, start = c(first_date[1], 1), extend = TRUE)
	}
	if (end && last_date[2] != frequency(x)) {
		x <- window(x, end = c(last_date[1], frequency(x)), extend = TRUE)
	}
	x
}
