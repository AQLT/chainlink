# library(chainlink)
# va = cp = data8.2cp[,1]
# pi = data8.2ep[,1]
# vo = cp_pi2vol(cp, pi)
# # vo[1:4] <- 25
# base_year <- 2010
#'
#'
#'@export
vo_cp2vpch_ao <- function(vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
	UseMethod("vo_cp2vpch_ao", vo)
}
#'@export
vo_cp2vpch_ao.ts <- function (vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
	output <- match.arg(output)
	vo <- extend_ts(vo)
	vo_y <- aggregate.ts(vo, nfrequency = 1, FUN = mean)
	if (!is.null (cp)) {
		cp <- extend_ts(cp)
		cp_y <- aggregate.ts(cp, nfrequency = 1, FUN = sum)
	}

	base_year <- auto_base_year(vo = vo, cp = cp, base_year = base_year)

	annual_ch <- vo_y / 100
	if ((!is.null(cp) && start(end(cp))[1] < start(annual_ch)[1]) |
		(is.null(cp) && base_year < start(annual_ch)[1])) {
		# complete the first year with cp
		previous_y <- start(annual_ch)[1] - 1
		previous_p <- c(previous_y, frequency(vo))
		if (is.null(cp)) {
			first_value <- 100
		} else {
			first_value <- window(cp, start = previous_p, end = previous_p)
		}
		annual_ch <- ts(
			c(first_value,
			  annual_ch),
			start = previous_y,
			frequency = 1)
	}

	annual_ch <- ts(cumprod(annual_ch), start = start(annual_ch), frequency = 1)
	annual_ch <- annual_ch / as.numeric(window(annual_ch, start = base_year, end = base_year)) * 100


	annual_links_q <- ts(rep(annual_ch, each = frequency(vo)),
						 start = start(annual_ch),
						 frequency = frequency(vo))

	ch_ind <- stats::lag(annual_links_q, - frequency(vo)) * vo / 100
	if (output == 'index') {
		return(ch_ind)
	} else {
		if (is.null(cp))
			stop("cp variable must be defined")
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
vo_cp2vpch_ao.mts <- function(vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
	if (is.null(cp) && ncol(cp) != ncol(vo))
		stop("cp and vo must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(vo), function(i){
		vo_cp2vpch_ao(vo = vo[,i], cp = cp[,i],
					  base_year = base_year, output = output)
	}))
	colnames(vol) <- colnames(cp)
	vol
}

#'@export
vo_cp2vpch_oqo <- function(vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
	UseMethod("vo_cp2vpch_oqo", vo)
}
#'@export
vo_cp2vpch_oqo.ts <- function (vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
	output <- match.arg(output)
	vo <- extend_ts(vo)
	if (!is.null (cp)) {
		cp <- extend_ts(cp)
		cp_y <- aggregate.ts(cp, nfrequency = 1, FUN = sum)
	}

	base_year <- auto_base_year(vo = vo, cp = cp, base_year = base_year)

	annual_ch <- ts(vo[cycle(vo) == frequency(vo)] / 100,
					start = start(vo)[1],
					frequency = 1)
	if ((!is.null(cp) && start(end(cp))[1] < start(annual_ch)[1]) |
		(is.null(cp) && base_year < start(annual_ch)[1])) {
		# complete the first year with cp
		previous_y <- start(annual_ch)[1] - 1
		previous_p <- c(previous_y, frequency(vo))
		if (is.null(cp)) {
			first_value <- 100
		} else {
			first_value <- window(cp, start = previous_p, end = previous_p)
		}
		annual_ch <- ts(
			c(first_value,
			  annual_ch),
			start = previous_y,
			frequency = 1)
	}
	annual_ch <- ts(cumprod(annual_ch), start = start(annual_ch), frequency = 1)
	annual_ch <- annual_ch / as.numeric(window(annual_ch, start = base_year, end = base_year)) * 100

	annual_links_q <- ts(rep(annual_ch, each = frequency(vo)), start = start(annual_ch),
						 frequency = frequency(vo))

	ch_ind <- stats::lag(annual_links_q, - frequency(vo)) * vo / 100
	if (output == 'index') {
		return(ch_ind)
	} else {
		if (is.null(cp))
			stop("cp variable must be defined")
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
vo_cp2vpch_oqo.mts <- function(vo, cp = NULL, base_year = NULL, output = c("index", "measure", "both")) {
	if (is.null(cp) && ncol(cp) != ncol(vo))
		stop("cp and vo must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(vo), function(i){
		vo_cp2vpch_oqo(vo = vo[,i], cp = cp[,i],
					   base_year = base_year, output = output)
	}))
	colnames(vol) <- colnames(cp)
	vol
}

auto_base_year <- function(vo, cp = NULL, base_year = NULL) {
	if (is.null(base_year)) {
		if (is.null(cp)) {
			base_year <- start(vo)[1] - 1
		} else {
			base_year <- max(start(vo)[1] - 1, start(cp)[1])
		}
	}
	base_year
}
