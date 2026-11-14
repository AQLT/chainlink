# Fully consistent chain-linked data, built independently of the package:
# components with random prices and quantities, volumes at the average prices of
# the previous year, then chained with the annual overlap technique ("ao") or the
# one-quarter overlap technique of the manual ("oqo": the overlap period is valued
# at the average prices of the previous year, and the first year is linked with the
# annual overlap technique).
# Returns the volume indices (previous year or overlap period = 100), the chain
# measures in monetary terms, the current prices, the values at the average prices
# of the year (cy) and the price indices over the previous year.
make_chain <- function(method = c("ao", "oqo"), f = 4, years = 2010:2014,
					   seed = 1) {
	method <- match.arg(method)
	set.seed(seed)
	n <- length(years) * f
	I <- 3
	q <- 100 * exp(apply(matrix(stats::rnorm(n * I, 0.01, 0.05), n, I), 2, cumsum))
	p <- exp(apply(matrix(stats::rnorm(n * I, 0.005, 0.04), n, I), 2, cumsum)) %*%
		diag(c(1, 2, 0.5))
	cp <- p * q
	idx_y <- function(y) ((y - years[1]) * f + 1):((y - years[1] + 1) * f)
	avg_price <- function(y) {
		colSums(cp[idx_y(y), , drop = FALSE]) / colSums(q[idx_y(y), , drop = FALSE])
	}
	base_cp <- colSums(cp[idx_y(years[1]), , drop = FALSE])
	x <- vo <- cy <- pi <- matrix(NA_real_, n, I)
	z <- vo_total <- rep(NA_real_, n)
	for (y in years) {
		cy[idx_y(y), ] <- sweep(q[idx_y(y), , drop = FALSE], 2, avg_price(y), "*")
		if (y > years[1])
			pi[idx_y(y), ] <- 100 * sweep(p[idx_y(y), , drop = FALSE], 2, avg_price(y - 1), "/")
	}
	lev <- rep(1, I)
	levz <- 1
	for (y in years[-1]) {
		cur <- idx_y(y)
		prev <- idx_y(y - 1)
		pyp <- sweep(q, 2, avg_price(y - 1), "*")      # at the average prices of y - 1
		if (method == "ao" || y == years[2]) {
			den <- colSums(cp[prev, , drop = FALSE]) / f   # annual overlap
		} else {
			den <- pyp[prev[f], ]    # overlap period at the average prices of y - 1
		}
		for (t in cur) {
			vo[t, ] <- 100 * pyp[t, ] / den
			vo_total[t] <- 100 * sum(pyp[t, ]) / sum(den)
			x[t, ] <- lev * (pyp[t, ] / den) * base_cp / f
			z[t] <- levz * (sum(pyp[t, ]) / sum(den)) * sum(base_cp) / f
		}
		if (method == "ao") {
			w <- colSums(cp[prev, , drop = FALSE])
			lev <- lev * colSums(pyp[cur, , drop = FALSE]) / w
			levz <- levz * sum(pyp[cur, ]) / sum(w)
		} else {
			lev <- lev * pyp[cur[f], ] / den
			levz <- levz * sum(pyp[cur[f], ]) / sum(den)
		}
	}
	keep <- -seq_len(f)   # chain series start the year after the base year
	nm <- c("A", "B", "C")
	mk <- function(m, from = keep, start_year = years[2]) {
		m <- as.matrix(m)[from, , drop = FALSE]
		colnames(m) <- nm
		stats::ts(m, start = c(start_year, 1), frequency = f)
	}
	mk1 <- function(v) stats::ts(v[keep], start = c(years[2], 1), frequency = f)
	mk_all <- function(m) {
		colnames(m) <- nm
		stats::ts(m, start = c(years[1], 1), frequency = f)
	}
	list(vo = mk(vo), vo_total = mk1(vo_total),
		 x = mk(x), z = mk1(z),
		 cp = mk_all(cp), cy = mk_all(cy), pi = mk_all(pi),
		 cp_total = stats::ts(rowSums(cp), start = c(years[1], 1), frequency = f),
		 base_year = years[1])
}
