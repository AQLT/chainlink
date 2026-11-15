test_that("chain_unchain is the inverse of chain_link: volumes at the prices of the previous year", {
	evm <- window(imf_cp / imf_pi * 100, start = c(2011, 1))
	for (method in c("ao", "oqo")) {
		x <- chain_laspeyres(imf_cp, imf_pi, method = method, base_year = 2010,
							 output = "measure")[, c("A", "B")]
		res <- chain_unchain(x, imf_cp, method = method, base_year = 2010,
							 pi = imf_pi)
		expect_equal(colnames(res), c("A", "B"))
		expect_equal(as.numeric(as.matrix(res)), as.numeric(as.matrix(evm)))
	}
	# a single series
	x <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010, output = "measure")
	res <- chain_unchain(x[, "A"], imf_cp[, "A"], base_year = 2010)
	expect_s3_class(res, "ts")
	expect_equal(as.numeric(res), as.numeric(evm[, 1]))
})

test_that("chain_aggregate of the unadjusted components is the chain measure of the total", {
	for (method in c("ao", "oqo")) {
		x <- chain_laspeyres(imf_cp, imf_pi, method = method, base_year = 2010,
							 output = "measure")
		tot <- chain_aggregate(x[, c("A", "B")], imf_cp, method = method,
							   base_year = 2010, output = "measure", pi = imf_pi)
		expect_equal(as.numeric(tot), as.numeric(x[, "Total"]))
		idx <- chain_laspeyres(imf_cp, imf_pi, method = method, base_year = 2010)
		tot_idx <- chain_aggregate(x[, c("A", "B")], imf_cp, method = method,
								   base_year = 2010, pi = imf_pi)
		expect_equal(as.numeric(tot_idx), as.numeric(idx[, "Total"]))
	}
})

test_that("chain_aggregate: seasonally adjusted components with unchanged annual means (annual overlap)", {
	d <- make_chain("ao")
	year <- rep(1:4, each = 4)                       # 2011-2014
	x0 <- as.matrix(d$x)
	x1 <- x0 * rep(c(1.02, 0.99, 0.98, 1.01), 4)     # a seasonal pattern
	# rescale each component and year so that the annual means are unchanged
	adj <- rowsum(x0, year) / rowsum(x1, year)
	x_sa <- x1 * adj[year, ]
	x_sa_ts <- stats::ts(x_sa, start = stats::start(d$x), frequency = 4)
	colnames(x_sa_ts) <- colnames(d$x)
	tot <- chain_aggregate(x_sa_ts, d$cp, method = "ao", base_year = d$base_year,
						   output = "measure")
	# the aggregate is the sum of the components weighted by the relative prices
	# of the previous year, computed from the unadjusted data
	cp_2010 <- colSums(as.matrix(window(d$cp, end = c(2010, 4))))
	cp_y <- rbind(cp_2010, rowsum(as.matrix(window(d$cp, start = c(2011, 1))), year))
	x_y <- rbind(cp_2010, rowsum(x0, year))
	z_y <- c(sum(cp_2010), as.numeric(rowsum(as.numeric(d$z), year)))
	rho <- (cp_y / x_y) / (rowSums(cp_y) / z_y)      # years 2010-2014
	expected <- rowSums(x_sa * rho[year, ])          # rho of the previous year
	expect_equal(as.numeric(tot), expected)
	# no seasonal adjustment: the total
	same <- chain_aggregate(d$x, d$cp, method = "ao", base_year = d$base_year,
							output = "measure")
	expect_equal(as.numeric(same), as.numeric(d$z))
})

test_that("chain_aggregate on synthetic data, monthly data and output = 'both'", {
	for (f in c(4, 12)) {
		d <- make_chain("oqo", f = f)
		tot <- chain_aggregate(d$x, d$cp, method = "oqo", base_year = d$base_year,
							   output = "measure", pi = d$pi)
		expect_equal(as.numeric(tot), as.numeric(d$z))
	}
	x <- chain_laspeyres(imf_cp, imf_pi, base_year = 2010, output = "measure")
	both <- chain_aggregate(x[, c("A", "B")], imf_cp, base_year = 2010, output = "both")
	expect_equal(colnames(both), c("Index", "Measure"))
})

test_that("chain_unchain and chain_aggregate check their inputs", {
	x <- chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
						 output = "measure")[, c("A", "B")]
	expect_error(chain_unchain(x, imf_cp, method = "oqo"), "`pi` is needed")
	expect_error(chain_aggregate(x, imf_cp, method = "oqo"), "`pi` is needed")
	expect_error(chain_unchain(1:10, imf_cp), "must be a time series")
	expect_error(chain_unchain(x[, "A"], imf_cp), "same number of variables")
})

test_that("chain_unchain and chain_aggregate with the overlap period at its current prices", {
	evm <- window(imf_cp / imf_pi * 100, start = c(2011, 1))
	x <- chain_laspeyres(imf_cp, imf_pi, method = "oqo", base_year = 2010,
						 overlap_prices = "current_prices", output = "measure")
	res <- chain_unchain(x[, c("A", "B")], imf_cp, method = "oqo", base_year = 2010,
						 overlap_prices = "current_prices")
	expect_equal(as.numeric(as.matrix(res)), as.numeric(as.matrix(evm)))
	tot <- chain_aggregate(x[, c("A", "B")], imf_cp, method = "oqo", base_year = 2010,
						   output = "measure", overlap_prices = "current_prices")
	expect_equal(as.numeric(tot), as.numeric(x[, "Total"]))
	# pi is not needed in this case
	expect_error(chain_unchain(x[, c("A", "B")], imf_cp, method = "oqo",
							   overlap_prices = "year_prices"), "`pi` is needed")
})
