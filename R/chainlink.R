# library(chainlink)
# va = cp = data8.2cp[,1]
# pi = data8.2ep[,1]
# vo = cp_pi2vol(cp, pi)
# # vo[1:4] <- 25
# base_year <- 2010
#'
#'@export
cp_vo2vpch_ao <- function(cp, vo, base_year = NULL, output = c("index", "measure", "both")) {
	UseMethod("cp_vo2vpch_ao", cp)
}
#'@export
cp_vo2vpch_ao.ts <- function (cp, vo, base_year = NULL, output = c("index", "measure", "both")) {
	output <- match.arg(output)
	vo <- chainlink:::extend_ts(vo)
	cp <- chainlink:::extend_ts(cp)
	vo_y <- aggregate.ts(vo, nfrequency = 1, FUN = mean)
	cp_y <- aggregate.ts(cp, nfrequency = 1, FUN = sum)

	if (missing(base_year)) {
		base_year <- max(start(vo)[1] - 1, start(cp)[1])
	}
	annual_ch <- vo_y / 100
	if (start(end(cp_y))[1] < start(annual_ch)[1]) {
		# complete the first year with cp
		previous_y <- start(annual_ch)[1] - 1
		annual_ch <- ts(
			c(window(cp_y, start = previous_y, end = previous_y),
			  annual_ch),
			start = previous_y,
			frequency = 1)
		# annual_ch <- c(cp_y[1], window(vo_y, start = start(cp_y)[1] + 1) / 100)
	}
	# annual_ch <- c(cp_y[1], window(vo_y, start = start(cp_y)[1] + 1) / 100)
	annual_ch <- ts(cumprod(annual_ch), start = start(cp_y), frequency = 1)
	annual_ch <- annual_ch / as.numeric(window(annual_ch, start = base_year, end = base_year)) * 100

	# annual_links <- vo_y / stats::lag(cp_y, -1)

	annual_links_q <- ts(rep(annual_ch, each = frequency(vo)), start = start(annual_ch),
						 frequency = frequency(vo))

	ch_ind <- stats::lag(annual_links_q, - frequency(vo)) * vo / 100
	if (output == 'index') {
		return(ch_ind)
	} else {
		cp_y_ref_base_year <- as.numeric(window(cp_y, start = base_year, end = base_year))
		ch_m <- ch_ind * (cp_y_ref_base_year / (frequency(cp)) ) / 100
		if (output == "measure") {
			return(ch_m)
		} else {
			res <- cbind(ch_ind, ch_m)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
}
#' @export
cp_vo2vpch_ao.mts <- function(cp, vo, base_year = NULL, output = c("index", "measure", "both")) {
	if (ncol(cp) != ncol(vo))
		stop("cp and vo must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(vo), function(i){
		cp_vo2vpch_ao(cp[,i], vo[,i], base_year = base_year, output = output)
	}))
	colnames(vol) <- colnames(cp)
	vol
}
