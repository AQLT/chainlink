cp_a <- data8.2cp[, "A"]
cp_b <- data8.2cp[, "B"]
pi_a <- data8.2ep[, "A"]
pi_b <- data8.2ep[, "B"]

test_that("chain_pseudo is the difference of the two chain volume measures", {
	for (method in c("ao", "oqo")) {
		pos <- chain_laspeyres(cp_a, pi_a, method = method, base_year = 2010,
							   output = "measure")[, "Total"]
		neg <- chain_laspeyres(cp_b, pi_b, method = method, base_year = 2010,
							   output = "measure")[, "Total"]
		res <- chain_pseudo(cp_a, pi_a, cp_b, pi_b, method = method, base_year = 2010)
		expect_s3_class(res, "ts")
		expect_equal(start(res), c(2011, 1))
		expect_equal(as.numeric(res), as.numeric(pos - neg))
	}
})

test_that("chain_pseudo: first year after the reference year", {
	# annual overlap: the measures of the first year are the volumes at the prices
	# of the reference year
	res <- chain_pseudo(cp_a, pi_a, cp_b, pi_b, base_year = 2010)
	expect_equal(as.numeric(window(res, end = c(2011, 4))),
				 as.numeric(window(cp_a / pi_a * 100 - cp_b / pi_b * 100,
								   start = c(2011, 1), end = c(2011, 4))))
})

test_that("chain_pseudo with aggregates", {
	cp_pos <- data8.2cp
	pi_pos <- data8.2ep
	res <- chain_pseudo(cp_pos, pi_pos, cp_b, pi_b, base_year = 2010)
	tot <- chain_laspeyres(cp_pos, pi_pos, base_year = 2010, output = "measure")[, "Total"]
	neg <- chain_laspeyres(cp_b, pi_b, base_year = 2010, output = "measure")[, "Total"]
	expect_equal(as.numeric(res), as.numeric(tot - neg))
})

test_that("chain_pseudo checks its inputs", {
	expect_error(chain_pseudo(1:10, pi_a, cp_b, pi_b), "must be a time series")
	expect_error(chain_pseudo(cp_a, pi_a, stats::aggregate(cp_b), stats::aggregate(pi_b)),
				 "same frequency")
})
