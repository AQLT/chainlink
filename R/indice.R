#' Elementary Volume Indices
#'
#' Functions to derive the elementary volume indices from current prices and price indexes.
#' @param cp Current prices.
#' @param pi Price indexes.
#' @param py Elementary Price Indices
#' @param reference_freq Frequency of the reference period (default is 1, i.e. annual).
#' @param reference_cycle Integer to specify a specific period as reference (such as last quarter).
#' @export
cp_pi2vol <- function(cp, pi, reference_freq = 1, reference_cycle = NULL) {
	UseMethod("cp_pi2vol", cp)
}
#' @export
cp_pi2vol.ts <- function(cp, pi, reference_freq = 1, reference_cycle = NULL) {
	cp <- extend_ts(cp)
	evm <- cp / pi * 100
	cp_y <- stats:::aggregate.ts(cp,
								 nfrequency = reference_freq,
								 FUN = sum)
	annual_freq <- reference_freq
	if (!is.null(reference_cycle)) {
		cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle],
				   start = start(cp_y)[1],
				   frequency = 1)
		annual_freq <- 1
	}
	cp_py <- stats::lag(cp_y, -1)
	cp_y_trim_py <- ts(rep(cp_py, each = frequency(cp) / annual_freq),
					   start = start(cp_py), frequency = frequency(cp))
	vol <- evm / (cp_y_trim_py / (frequency(cp) / reference_freq) )* 100
	vol
}
#' @export
cp_pi2vol.mts <- function(cp, pi, reference_freq = 1, reference_cycle = NULL) {
	if (ncol(cp) != ncol(pi))
		stop("cp and pi must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(pi), function(i){
		cp_pi2vol(cp[,i], pi[,i], reference_freq = reference_freq, reference_cycle = reference_cycle)
	}))
	colnames(vol) <- colnames(cp)
	vol
}

# TODO = supprimer function?
#' @name cp_pi2vol
#' @export
cp_py2vol <- function(cp, py, reference_freq = 1, reference_cycle = NULL) {
	UseMethod("cp_py2vol", cp)
}
#' @export
cp_py2vol.ts <- function(cp, py, reference_freq = 1, reference_cycle = NULL) {
	cp <- extend_ts(cp)
	evm <- cp / py * 100
	cp_y <- stats:::aggregate.ts(
		cp,
		nfrequency = reference_freq,
		FUN = sum)
	annual_freq <- reference_freq
	if (!is.null(reference_cycle)) {
		cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle],
				   start = start(cp_y)[1],
				   frequency = 1)
		annual_freq <- 1
	}
	cp_py <- stats::lag(cp_y, -1)
	cp_y_trim_py <- ts(rep(cp_py, each = frequency(cp) / annual_freq),
					   start = start(cp_py), frequency = frequency(cp))
	vol <- evm / (cp_y_trim_py / (frequency(cp) / reference_freq) )* 100
	vol
}
#' @export
cp_py2vol.mts <- function(cp, py, reference_freq = 1, reference_cycle = NULL) {
	if (ncol(cp) != ncol(py))
		stop("cp and py must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(py), function(i){
		cp_py2vol(cp[,i], py[,i], reference_freq = reference_freq, reference_cycle = reference_cycle)
	}))
	colnames(vol) <- colnames(cp)
	vol
}
#' Price deflators
#'
#' Functions to compute Laspeyres-type, Paasche-type or Fisher-type price indexes.
#'
#' @inheritParams cp_pi2vol
#' @param output Character if the output should be the Volume Index (the default), the Volume Measure (in Monetary Terms) or both.
#' @rdname price-deflators
#' @name price-deflators
#' @export
laspeyres <- function(cp, pi, output = c("index", "measure", "both"), reference_freq = 1, reference_cycle = NULL){
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
	cp_y <- stats:::aggregate.ts(
		cp,
		nfrequency = reference_freq,
		FUN = sum)
	annual_freq <- reference_freq
	if (!is.null(reference_cycle)) {
		cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle, ],
				   start = start(cp_y)[1],
				   frequency = 1)
		annual_freq <- 1
	}
	cp_py <- stats::lag(cp_y, -1)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim_py <- ts(matrix(rep(cp_py, each = frequency(cp) / annual_freq), ncol = ncol(cp_y)),
					   start = start(cp_py), frequency = frequency(cp))

	evi <- evm / (cp_y_trim_py[,-ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq) )* 100

	lvi <- evi *
		cp_y_trim_py[,-ncol(cp_y_trim_py)] /
		cp_y_trim_py[,ncol(cp_y_trim_py)]

	lvi <- ts(apply(lvi,1, sum), start = start(lvi), frequency = frequency(lvi))

	if (output == 'index') {
		return(lvi)
	} else {
		lvm <- lvi * (cp_y_trim_py[, ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq) ) / 100
		if (output == "measure") {
			return(lvm)
		} else {
			res <- cbind(lvi, lvm)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
	# mapply(cp_pi2vol, cp, pi,
	# 	   SIMPLIFY = FALSE)
}
#' @name price-deflators
#' @export
paasche <- function(cp, pi, output = c("index", "measure", "both"), reference_freq = 1, reference_cycle = NULL){
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
								 nfrequency = reference_freq,
								 FUN = sum)
	annual_freq <- reference_freq
	if (!is.null(reference_cycle)) {
		cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle, ],
				   start = start(cp_y)[1],
				   frequency = 1)
		annual_freq <- 1
	}
	cp_py <- stats::lag(cp_y, -1)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim_py <- ts(matrix(rep(cp_py, each = frequency(cp) / annual_freq), ncol = ncol(cp_py)),
					   start = start(cp_py), frequency = frequency(cp))
	cp_y_trim <- ts(matrix(rep(cp_y, each = frequency(cp) / annual_freq), ncol = ncol(cp_y)),
					start = start(cp_y), frequency = frequency(cp))
	evi <- evm / (cp_y_trim_py[,-ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq) )* 100


	pvi <-
		(1 / evi) *
		cp_y_trim[,-ncol(cp_y_trim)] /
		cp_y_trim[,ncol(cp_y_trim)]
	pvi <- 1 /
		ts(apply(pvi,1, sum), start = start(pvi), frequency = frequency(pvi))

	if (output == 'index') {
		return(pvi)
	} else {
		pvm <- pvi * (cp_y_trim[, ncol(cp_y_trim)] / (frequency(cp) / reference_freq) ) / 100
		if (ouput == "measure") {
			return(lvm)
		} else {
			res <- cbind(pvi, pvm)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
}
#' @name price-deflators
#' @export
fisher <- function(cp, pi, output = c("index", "measure", "both"), all_index = FALSE, reference_freq = 1, reference_cycle = NULL){
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
								 nfrequency = reference_freq,
								 FUN = sum)
	annual_freq <- reference_freq
	if (!is.null(reference_cycle)) {
		cp_y <- ts(cp_y[cycle(cp_y) %in% reference_cycle, ],
				   start = start(cp_y)[1],
				   frequency = 1)
		annual_freq <- 1
	}
	cp_py <- stats::lag(cp_y, -1)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim_py <- ts(matrix(rep(cp_py, each = frequency(cp) / annual_freq), ncol = ncol(cp_py)),
					   start = start(cp_py), frequency = frequency(cp))
	cp_y_trim <- ts(matrix(rep(cp_y, each = frequency(cp) / annual_freq), ncol = ncol(cp_y)),
					start = start(cp_y), frequency = frequency(cp))
	evi <- evm / (cp_y_trim_py[,-ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq) )* 100
	lvi <- evi *
		cp_y_trim_py[,-ncol(cp_y_trim_py)] /
		cp_y_trim_py[,ncol(cp_y_trim_py)]
	lvi <- ts(apply(lvi, 1, sum), start = start(lvi), frequency = frequency(lvi))

	pvi <-
		(1 / evi) *
		cp_y_trim[,-ncol(cp_y_trim)] /
		cp_y_trim[,ncol(cp_y_trim)]
	pvi <- 1 /
		ts(apply(pvi,1, sum), start = start(pvi), frequency = frequency(pvi))

	fvi <- ts.union(lvi, pvi)
	fvi <- ts(exp(apply(log(fvi), 1, mean)),
			  start = start(fvi), frequency = frequency(fvi))
	all_vi <- ts.union(lvi, pvi, fvi)
	colnames(all_vi) <- c("Laspeyres", "Paasche", "Fisher")
	if (output == 'index') {
		if (all_index) {
			all_vi
		} else {
			all_vi[, "Fisher"]
		}
	} else {
		all_vm <- all_vi * (cp_y_trim_py[, ncol(cp_y_trim_py)] / (frequency(cp) / reference_freq) ) / 100
		if (ouput == "measure") {
			if (all_index) {
				all_vm
			} else {
				all_vm[, "Fisher"]
			}
		} else {
			if (all_index) {
				res <- cbind(all_vi, all_vm)
				colnames(res) <- paste(rep(colnames(all_vi), 2),
									   rep(c("Index", "Measure"), each = 3))
				res
			} else {
				res <- all_vm
				res <- cbind(all_vi[, "Fisher"], all_vm[, "Fisher"])
				colnames(res) <- c("Index", "Measure")
				res
			}
		}
	}
}
