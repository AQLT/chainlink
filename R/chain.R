
#' @export
current_price2vol <- function(cp, ni) {
	UseMethod("current_price2vol", cp)
}
#' @export
current_price2vol.ts <- function(cp, pi) {
	cp <- extend_ts(cp)
	evm <- cp / pi * 100
	cp_y <- stats:::aggregate.ts(cp,
								 nfrequency = 1,
								 FUN = sum)
	cp_y_trim <- ts(rep(cp_y, each = frequency(cp)),
					start = start(cp_y), frequency = frequency(cp))
	vol <- evm / (stats::lag(cp_y_trim,
							 - frequency(cp_y_trim)) / frequency(cp) )* 100
	vol
}
#' @export
current_price2vol.mts <- function(cp, pi) {
	if (ncol(cp) != ncol(pi))
		stop("cp and pi must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(pi), function(i){
		current_price2vol(cp[,i], pi[,i])
	}))
	colnames(vol) <- colnames(cp)
	vol
}
#' @export
laspeyres_vol <- function(cp, pi, output = c("index", "measure", "both")){
	output <- match.arg(output)
	if (is.list(cp))
		cp <- do.call(cbind, cp)
	if (is.list(pi))
		pi <- do.call(cbind, pi)
	cp <- extend_ts(cp)
	cp_tot <- ts(apply(cp, 1, sum),
				 start = start(cp),
				 frequency = frequency(cp))
	names_col <- colnames(cp)

	cp <- window(cbind(cp, cp_tot),
				 start = start(cp), extends = TRUE)
	# Elementary volume measures
	evm <- cp[,-ncol(cp)] / pi * 100
	# Yearly current prices
	cp_y <- stats:::aggregate.ts(cp,
								 nfrequency = 1,
								 FUN = sum)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim <- ts(matrix(rep(cp_y, each = frequency(cp)), ncol = ncol(cp_y)),
					start = start(cp_y), frequency = frequency(cp))
	evi <- evm / (stats::lag(cp_y_trim[,-ncol(cp_y_trim)],
							 - frequency(cp_y_trim)) / frequency(cp) )* 100
	lvi <- evi * stats::lag(
		cp_y_trim[,-ncol(cp_y_trim)] /
			cp_y_trim[,ncol(cp_y_trim)],
		- frequency(cp_y_trim))
	lvi <- ts(apply(lvi,1, sum), start = start(lvi), frequency = frequency(lvi))

	if (output == 'index') {
		return(lvi)
	} else {
		lvm <- lvi *stats::lag(cp_y_trim[,ncol(cp_y_trim)] / 4,
							   - frequency(cp_y_trim)) / 100
		if (output == "measure") {
			return(lvm)
		} else {
			res <- cbind(lvi, lvm)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
	# mapply(current_price2vol, cp, pi,
	# 	   SIMPLIFY = FALSE)
}
#' @export
paasche_vol_index <- function(cp, pi, output = c("index", "measure", "both")){
	output <- match.arg(output)
	if (is.list(cp))
		cp <- do.call(cbind, cp)
	if (is.list(pi))
		pi <- do.call(cbind, pi)
	cp <- extend_ts(cp)
	cp_tot <- ts(apply(cp, 1, sum),
				 start = start(cp),
				 frequency = frequency(cp))
	names_col <- colnames(cp)

	cp <- window(cbind(cp, cp_tot),
				 start = start(cp), extends = TRUE)
	# Elementary volume measures
	evm <- cp[,-ncol(cp)] / pi * 100
	# Yearly current prices
	cp_y <- stats:::aggregate.ts(cp,
								 nfrequency = 1,
								 FUN = sum)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim <- ts(matrix(rep(cp_y, each = frequency(cp)), ncol = ncol(cp_y)),
					start = start(cp_y), frequency = frequency(cp))
	evi <- evm / (stats::lag(cp_y_trim[,-ncol(cp_y_trim)],
							 - frequency(cp_y_trim)) / frequency(cp) )* 100
	lvi <- evi * stats::lag(
		cp_y_trim[,-ncol(cp_y_trim)] /
			cp_y_trim[,ncol(cp_y_trim)],
		- frequency(cp_y_trim))
	lvi <- ts(apply(lvi,1, sum), start = start(lvi), frequency = frequency(lvi))

	if (output == 'index') {
		return(lvi)
	} else {
		lvm <- lvi *stats::lag(cp_y_trim[,ncol(cp_y_trim)] / 4,
							   - frequency(cp_y_trim)) / 100
		if (ouput == "measure") {
			return(lvm)
		} else {
			res <- cbind(lvi, lvm)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
	# mapply(current_price2vol, cp, pi,
	# 	   SIMPLIFY = FALSE)
}
