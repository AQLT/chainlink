
#' @export
cp_pi2vol <- function(cp, pi, reference_freq = 1) {
	UseMethod("cp_pi2vol", cp)
}
#' @export
cp_pi2vol.ts <- function(cp, pi, reference_freq = 1) {
	cp <- extend_ts(cp)
	evm <- cp / pi * 100
	cp_y <- stats:::aggregate.ts(cp,
								 nfrequency = reference_freq,
								 FUN = sum)
	cp_py <- stats::lag(cp_y, -1)
	cp_y_trim_py <- ts(rep(cp_py, each = frequency(cp) / reference_freq),
					start = start(cp_py), frequency = frequency(cp))
	vol <- evm / (cp_y_trim_py / (frequency(cp) / reference_freq) )* 100
	vol
}
#' @export
cp_pi2vol.mts <- function(cp, pi, reference_freq = 1) {
	if (ncol(cp) != ncol(pi))
		stop("cp and pi must have the same number of variables")
	vol <- do.call(cbind, lapply(1:ncol(pi), function(i){
		cp_pi2vol(cp[,i], pi[,i], reference_freq = reference_freq)
	}))
	colnames(vol) <- colnames(cp)
	vol
}
#' @export
laspeyres <- function(cp, pi, output = c("index", "measure", "both"), reference_freq = 1){
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
	cp_py <- stats::lag(cp_y, -1)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim_py <- ts(matrix(rep(cp_py, each = frequency(cp) / reference_freq), ncol = ncol(cp_y)),
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
#' @export
paasche <- function(cp, pi, output = c("index", "measure", "both"), reference_freq = 1){
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
	cp_py <- stats::lag(cp_y, -1)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim_py <- ts(matrix(rep(cp_py, each = frequency(cp) / reference_freq), ncol = ncol(cp_py)),
					start = start(cp_py), frequency = frequency(cp))
	cp_y_trim <- ts(matrix(rep(cp_y, each = frequency(cp) / reference_freq), ncol = ncol(cp_y)),
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
	# mapply(cp_pi2vol, cp, pi,
	# 	   SIMPLIFY = FALSE)
}

#' @export
fisher <- function(cp, pi, output = c("index", "measure", "both"), all_index = FALSE, reference_freq = 1){
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
	cp_py <- stats::lag(cp_y, -1)
	# Yearly current prices in a low frequency (for multiplications)
	cp_y_trim_py <- ts(matrix(rep(cp_py, each = frequency(cp) / reference_freq), ncol = ncol(cp_py)),
					   start = start(cp_py), frequency = frequency(cp))
	cp_y_trim <- ts(matrix(rep(cp_y, each = frequency(cp) / reference_freq), ncol = ncol(cp_y)),
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
	# mapply(cp_pi2vol, cp, pi,
	# 	   SIMPLIFY = FALSE)
}
