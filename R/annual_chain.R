#'
#'@export
annual_chain <- function(vo, cp = NULL, base_vo = vo, base_cp = cp,
						 base_year = NULL, output = c("index", "measure", "both")) {
	UseMethod("annual_chain", vo)
}
#'@export
annual_chain.ts <- function (vo, cp = NULL, base_vo = vo, base_cp = cp,
							 base_year = NULL, output = c("index", "measure", "both")) {
	output <- match.arg(output)
	vo <- extend_ts(vo)
	vo_y <- aggregate.ts(vo, nfrequency = 1, FUN = mean)
	if (!is.null (cp)) {
		cp <- extend_ts(cp)
		cp_y <- aggregate.ts(cp, nfrequency = 1, FUN = sum)
	}

	base_year <- auto_base_year(vo = vo, cp = cp, base_year = base_year)

	annual_ch <- vo_y / 100
	annual_ch <- vo_y / 100
	if ((!is.null(cp) && start(end(cp))[1] < start(annual_ch)[1]) |
		(is.null(cp) && base_year < start(annual_ch)[1])) {
		# complete the first year with cp
		previous_y <- start(annual_ch)[1] - 1
		if (is.null(cp)) {
			first_value <- 100
		} else {
			first_value <- window(cp_y, start = previous_y, end = previous_y)
		}
		annual_ch <- ts(
			c(first_value,
			  annual_ch),
			start = previous_y,
			frequency = 1)
	}

	annual_ch <- ts(cumprod(annual_ch), start = start(annual_ch), frequency = 1)
	annual_ch <- annual_ch / as.numeric(window(annual_ch, start = base_year, end = base_year)) * 100

	if (output == 'index') {
		return(annual_ch)
	} else {
		if (is.null(cp))
			stop("cp variable must be defined")
		cp_y_ref_base_year <- as.numeric(window(cp_y, start = base_year, end = base_year))
		ch_m <- annual_ch * cp_y_ref_base_year  / 100
		if (output == "measure") {
			return(ch_m)
		} else {
			res <- cbind(annual_ch, ch_m)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
}
#' @export
annual_chain.mts <- function(vo, cp = NULL, base_vo = vo, base_cp = cp,
							 base_year = NULL, output = c("index", "measure", "both")) {
	if (is.null(cp) && ncol(cp) != ncol(vo))
		stop("cp and vo must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(vo), function(i){
		annual_chain(vo = vo[,i], cp = cp[,i],
					  base_year = base_year, output = output)
	}))
	colnames(vol) <- colnames(cp)
	vol
}
