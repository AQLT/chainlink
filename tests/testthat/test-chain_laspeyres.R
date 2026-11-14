test_that("chain_laspeyres (annual overlap) = cp_pi2vol + laspeyres + chain_link", {
	cp_t <- ts(rowSums(data8.2cp), start = start(data8.2cp), frequency = 4)
	vo <- cp_pi2vol(data8.2cp, data8.2ep)
	vo_t <- laspeyres(data8.2cp, data8.2ep, output = "index")
	exp_idx <- chain_link(ts.union(vo, vo_t), ts.union(data8.2cp, cp_t),
						  method = "ao", base_year = 2010)
	res <- chain_laspeyres(data8.2cp, data8.2ep, method = "ao", base_year = 2010)
	expect_equal(colnames(res), c("A", "B", "Total"))
	expect_equal(as.numeric(as.matrix(res)), as.numeric(as.matrix(exp_idx)))
})

test_that("chain_laspeyres (one-quarter overlap) values the overlap period at the average prices", {
	d <- make_chain("oqo")
	res <- chain_laspeyres(d$cp, d$pi, method = "oqo", base_year = d$base_year,
						   output = "measure")
	expect_equal(colnames(res), c("A", "B", "C", "Total"))
	expect_equal(unname(as.matrix(res)[, 1:3]), unname(as.matrix(d$x)))
	expect_equal(as.numeric(res[, "Total"]), as.numeric(d$z))
	# the same indices as cp_pi2vol / laspeyres when the overlap period is the
	# annual average (first year): the first year is linked with the annual overlap
	ao <- chain_laspeyres(d$cp, d$pi, method = "ao", base_year = d$base_year)
	oqo <- chain_laspeyres(d$cp, d$pi, method = "oqo", base_year = d$base_year)
	expect_equal(as.numeric(window(oqo, end = c(2011, 4))[, 1]),
				 as.numeric(window(ao, end = c(2011, 4))[, 1]))
})

test_that("chain_laspeyres: monthly data = quarterly data spread over three months", {
	spread <- function(a, scale = 1) {
		m <- as.matrix(a)
		res <- ts(m[rep(seq_len(nrow(m)), each = 3), , drop = FALSE] * scale,
				  start = c(start(a)[1], 1), frequency = 12)
		colnames(res) <- colnames(a)
		res
	}
	cp_m <- spread(data8.2cp, 1 / 3)
	pi_m <- spread(data8.2ep)
	for (method in c("ao", "oqo")) {
		x_q <- chain_laspeyres(data8.2cp, data8.2ep, method = method, base_year = 2010)
		x_m <- chain_laspeyres(cp_m, pi_m, method = method, base_year = 2010)
		expect_equal(start(x_m), c(2011, 1))
		expect_equal(frequency(x_m), 12)
		expect_equal(as.numeric(as.matrix(x_m)), as.numeric(as.matrix(spread(x_q))))
		# measures: each month is a third of the quarter
		m_q <- chain_laspeyres(data8.2cp, data8.2ep, method = method, base_year = 2010,
							   output = "measure")
		m_m <- chain_laspeyres(cp_m, pi_m, method = method, base_year = 2010,
							   output = "measure")
		expect_equal(as.numeric(as.matrix(m_m)),
					 as.numeric(as.matrix(spread(m_q, 1 / 3))))
	}
})

test_that("chain_laspeyres works with a single component", {
	res <- chain_laspeyres(data8.2cp[, "A"], data8.2ep[, "A"], base_year = 2010)
	expect_equal(ncol(res), 2)
	expect_equal(colnames(res), c("V1", "Total"))
	expect_equal(as.numeric(res[, 1]), as.numeric(res[, 2]))
})
