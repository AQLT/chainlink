# library(chainlink)
# va = cp = data8.2cp[,1]
# pi = data8.2ep[,1]
# vo = cp_pi2vol(cp, pi)
# # vo[1:4] <- 25
# base <- 2010
#'@export
cp_vo2vpch_ao <- function (cp, vo, base = start(cp), output = c("index", "measure", "both")) {
	output <- match.arg(output)
	vo <- chainlink:::extend_ts(vo)
	vo_y <- aggregate.ts(vo, nfrequency = 1, FUN = mean)
	cp_y <- aggregate.ts(cp, nfrequency = 1, FUN = sum)
	# TODO : améliorer
	annual_ch <- c(cp_y[1], window(vo_y, start = start(cp_y)[1] + 1) / 100)
	annual_ch <- ts(cumprod(annual_ch), start = start(cp_y), frequency = 1)
	annual_ch <- annual_ch / as.numeric(window(annual_ch, start = base, end = base)) * 100

	# annual_links <- vo_y / stats::lag(cp_y, -1)

	annual_links_q <- ts(rep(annual_ch, each = frequency(vo)), start = start(annual_ch),
	   frequency = frequency(vo))

	ch_ind <- stats::lag(annual_links_q, - frequency(vo)) * vo / 100
	if (output == 'index') {
		return(ch_ind)
	} else {
		cp_y_ref_base <- as.numeric(window(cp_y, start = base, end = base))
		ch_m <- ch_ind * (cp_y_ref_base / (frequency(cp)) ) / 100
		if (output == "measure") {
			return(ch_m)
		} else {
			res <- cbind(ch_ind, ch_m)
			colnames(res) <- c("Index", "Measure")
			return (res)
		}
	}
}
