test_that("inputs are checked", {
	d <- make_chain("ao")
	expect_error(chain_link(as.numeric(1:10)), "must be a time series")
	expect_error(chain_contrib(unclass(d$x), d$cp, d$z), "must be a time series")
	expect_error(pi_py2pp(1:10), "must be a time series")
	# different number of variables
	expect_error(chain_laspeyres(data8.2cp, data8.2ep[, "A"]), "same number of variables")
	expect_error(chain_link(d$vo, d$cp[, 1:2], method = "ao"), "same number of variables")
	# different frequencies
	z_year <- stats::aggregate(d$z, FUN = sum)
	expect_error(chain_contrib(d$x, d$cp, z_year), "same frequency")
	# base year not covered by current prices
	expect_error(chain_link(d$vo, window(d$cp, start = 2011), base_year = 2010,
							output = "measure"), "cover the base year")
	expect_error(chain_link(d$vo, output = "measure"), "cp variable must be defined")
	# the total is needed
	expect_error(chain_contrib(d$x[, "A"], d$cp[, "A"]), "must be provided")
	expect_error(chain_discrepancy(d$x[, "A"]), "must be provided")
})
