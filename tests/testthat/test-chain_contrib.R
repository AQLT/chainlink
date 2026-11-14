# Reference values: IMF Quarterly National Accounts Manual, chapter 8, example 8.9
# (sheet "Example 8.9" of data/Chapter 8_Tables_Charts.xlsx).

# Chain measures (annual overlap, base 2010) and current prices, 2011Q1-2013Q4.
vo <- ts(cbind(A = c(156.568627, 159.219512, 162.524272, 164.757282, 165.591634, 172.325865, 182.232021, 206.868964, 214.161149, 226.999237, 235.015224, 238.639321),
               B = c(221.111111, 218.061224, 214.897959, 213.838384, 213.614134, 206.529924, 198.199141, 176.073426, 171.375126, 159.763404, 151.042829, 146.557514)),
         start = c(2011, 1), frequency = 4)
vo_total <- ts(c(377.679739, 377.280737, 377.422231, 378.595665, 379.378942, 379.312612, 381.268576, 384.751023, 388.616393, 390.766361, 390.688109, 390.128386), start = c(2011, 1), frequency = 4)
# Quarterly current prices in 2010 are not in the sheet (only the annual sum:
# 600 and 900); they are spread evenly, only their annual sum matters.
cp <- ts(cbind(A = c(rep(150, 4), 159.7, 163.2, 167.4, 169.7, 174.2, 180.4, 188.9, 215.5, 224.7, 235.8, 242.9, 245.4),
               B = c(rep(225, 4), 218.9, 213.7, 210.6, 211.7, 204.1, 201.4, 192.3, 171.7, 166, 156.3, 148.5, 144.8)),
         start = c(2010, 1), frequency = 4)
expected_q <- cbind(
  A = c(NA, 0.702, 0.876, 0.592, 0.248, 1.817, 2.673, 6.615, 2.081, 3.44, 2.136, 0.966),
  B = c(NA, -0.808, -0.838, -0.281, -0.041, -1.835, -2.158, -5.702, -1.077, -2.887, -2.156, -1.109))
expected_y <- cbind(A = c(2.875, 5.673, 12.808),
                    B = c(-2.139, -4.798, -10.517))


# Annual series of the sheet (the manual's annual measures are not exactly the
# sum of the quarterly ones: see the vignette on example 8.2)
cp_a <- ts(cbind(A = c(600, 660, 759, 948.8), B = c(900, 854.9, 769.5, 615.6)),
           start = 2010, frequency = 1)
vo_a <- ts(cbind(A = c(643.118149, 726.865721, 914.344688), B = c(867.918782, 794.122769, 628.230621)),
           start = 2011, frequency = 1)
vo_total_a <- ts(c(1511.03693, 1524.259998, 1559.181698), start = 2011, frequency = 1)

# The numbers of the sheet are rounded to 3 decimals
tol <- 1e-3

test_that("quarter-to-quarter contributions match example 8.9", {
	res <- chain_contrib(vo, cp, vo_total, method = "ao", type = "period")
	expect_equal(colnames(res), c("A", "B"))
	# same span as the input; the first quarter has no previous quarter
	expect_equal(start(res), c(2011, 1))
	expect_equal(end(res), c(2013, 4))
	expect_true(all(is.na(window(res, end = c(2011, 1)))))
	got <- window(res, start = c(2011, 2))
	exp <- expected_q[-1, ]
	expect_lt(max(abs(got - exp)), tol)
})

test_that("annual contributions match example 8.9", {
	res <- chain_contrib(vo_a, cp_a, vo_total_a, method = "ao", type = "annual")
	expect_equal(start(res), c(2011, 1))
	expect_equal(frequency(res), 1)
	expect_lt(max(abs(res - expected_y)), tol)
	# From quarterly series: annual sums of the quarterly measures differ
	# slightly from the manual's annual measures
	res_q <- chain_contrib(vo, cp, vo_total, method = "ao", type = "annual")
	expect_lt(max(abs(res_q - expected_y)), 3e-2)
})

test_that("contributions add up to the growth of the total", {
	res <- chain_contrib(vo, cp, vo_total, method = "ao", type = "period")
	growth <- 100 * (vo_total / stats::lag(vo_total, -1) - 1)
	total <- ts(rowSums(res), start = start(res), frequency = 4)
	gap <- window(total, start = c(2011, 2)) - window(growth, start = c(2011, 2))
	# < 0.001 pp: non-additivity of the example's data (as in the manual's table)
	expect_lt(max(abs(gap)), 2e-3)
	# Annual: exact
	resy <- chain_contrib(vo, cp, vo_total, method = "ao", type = "annual")
	vo_total_y <- aggregate(vo_total, FUN = sum)
	growth_y <- 100 * (window(vo_total_y, start = 2011) /
					   c(1500, window(vo_total_y, start = 2011, end = 2012)) - 1)
	expect_equal(as.numeric(rowSums(resy)), as.numeric(growth_y), tolerance = 1e-6)
})

test_that("a single component (ts) works", {
	cp_total <- ts(rowSums(cp), start = start(cp), frequency = 4)
	res <- chain_contrib(vo[, "A"], cp[, "A"], vo_total, cp_total = cp_total, method = "ao")
	expect_s3_class(res, "ts")
	expect_lt(max(abs(window(res, start = c(2011, 2)) - expected_q[-1, "A"])), tol)
})

test_that("extra columns: total growth and residual", {
	res <- chain_contrib(vo, cp, vo_total, method = "ao", type = "period", extra = c("total", "residual"))
	expect_equal(colnames(res), c("A", "B", "Total", "Residual"))
	growth <- 100 * (vo_total / stats::lag(vo_total, -1) - 1)
	expect_lt(max(abs(window(res[, "Total"], start = c(2011, 2)) -
					  window(growth, start = c(2011, 2)))), 1e-8)
	expect_lt(max(abs(window(res[, "Residual"], start = c(2011, 2)))), 2e-3)
	resy <- chain_contrib(vo, cp, vo_total, method = "ao", type = "annual", extra = "residual")
	expect_equal(colnames(resy), c("A", "B", "Residual"))
	expect_lt(max(abs(resy[, "Residual"])), 1e-6)
})

# ---------------------------------------------------------------------------
# Synthetic data, fully consistent: contributions must add up exactly.
for (method in c("ao", "oqo")) {
	for (f in c(4, 12)) {
		local({
			method <- method
			f <- f
			d <- make_chain(method, f = f)
			for (type in c("period", "yoy", "annual")) {
				local({
					type <- type
					test_that(paste("exact additivity:", method, type, "f =", f), {
						# one-quarter overlap: the overlap period is valued at the average
						# prices of the year
						cp_arg <- if (method == "oqo") d$cy else d$cp
						res <- chain_contrib(d$x, cp_arg, d$z, method = method,
											 type = type, base_year = d$base_year,
											 extra = c("total", "residual"))
						r <- as.numeric(res[, "Residual"])
						r <- r[!is.na(r)]
						expect_gt(length(r), 0)
						expect_lt(max(abs(r)), 1e-8)
						# and the total is not trivially zero
						tot <- as.numeric(res[, "Total"])
						expect_gt(max(abs(tot), na.rm = TRUE), 0.1)
					})
				})
			}
			test_that(paste("chain_link reproduces the synthetic chain:", method, "f =", f), {
				cp_total <- d$cp_total
				idx <- chain_link(d$vo, d$cp, method = method, base_year = d$base_year,
								  output = "measure")
				expect_lt(max(abs(idx - d$x)), 1e-8)
				idx_z <- chain_link(d$vo_total, cp_total, method = method,
									base_year = d$base_year, output = "measure")
				expect_lt(max(abs(idx_z - d$z)), 1e-8)
			})
		})
	}
}

test_that("oqo: one-period contributions need no correction at the first period", {
	d <- make_chain("oqo")
	res <- chain_contrib(d$x, d$cy, d$z, method = "oqo", base_year = d$base_year)
	expect_equal(start(res), c(2011, 1))
	expect_true(all(is.na(window(res, end = c(2011, 1)))))
	expect_false(anyNA(window(res, start = c(2011, 2))))
})

test_that("oqo: annual contributions start in the second year", {
	d <- make_chain("oqo")
	res <- chain_contrib(d$x, d$cy, d$z, method = "oqo", type = "annual",
						 base_year = d$base_year)
	expect_true(all(is.na(window(res, end = 2011))))
	expect_false(anyNA(window(res, start = 2012)))
})

test_that("monthly = quarterly replicated three times", {
	# Quarterly values spread over 3 months: contributions are those of the
	# quarter in the first month of each quarter, and 0 in the other months.
	d <- make_chain("ao", f = 4)
	rep3_ts <- function(a) {
		m <- matrix(a, ncol = NCOL(a))
		ts(m[rep(seq_len(nrow(m)), each = 3), , drop = FALSE] / 3,
		   start = c(start(a)[1], 1), frequency = 12)
	}
	xm <- rep3_ts(d$x); colnames(xm) <- colnames(d$x)
	zm <- ts(as.numeric(d$z)[rep(seq_along(d$z), each = 3)] / 3,
			 start = c(start(d$z)[1], 1), frequency = 12)
	cpm <- rep3_ts(d$cp); colnames(cpm) <- colnames(d$cp)
	cq <- chain_contrib(d$x, d$cp, d$z, method = "ao", base_year = d$base_year)
	cm <- chain_contrib(xm, cpm, zm, method = "ao", base_year = d$base_year)
	first_month <- as.numeric(cycle(cm)) %% 3 == 1
	got <- as.matrix(cm)[first_month, , drop = FALSE]
	exp <- as.matrix(cq)
	ok <- !is.na(exp[, 1])
	expect_lt(max(abs(got[ok, ] - exp[ok, ])), 1e-8)
	other <- as.matrix(cm)[!first_month, , drop = FALSE]
	expect_lt(max(abs(other), na.rm = TRUE), 1e-8)
})

test_that("oqo: the formulas of the manual (annual deflators) are not exactly additive", {
	d <- make_chain("oqo")
	exact <- chain_contrib(d$x, d$cy, d$z, method = "oqo", base_year = d$base_year,
						   extra = "residual")
	manual <- chain_contrib(d$x, d$cp, d$z, method = "ao", base_year = d$base_year,
							extra = "residual")
	expect_lt(max(abs(exact[-1, "Residual"])), 1e-8)
	expect_gt(max(abs(manual[-1, "Residual"]), na.rm = TRUE), 1e-6)
})

test_that("oqo: pi gives the values at the average prices of the year", {
	d <- make_chain("oqo")
	# price indices instead of the values at the average prices of the year
	with_pi <- chain_contrib(d$x, d$cp, d$z, method = "oqo", base_year = d$base_year,
							 pi = d$pi, extra = "residual")
	with_cy <- chain_contrib(d$x, d$cy, d$z, method = "oqo", base_year = d$base_year,
							 extra = "residual")
	expect_equal(as.matrix(with_pi), as.matrix(with_cy))
	expect_lt(max(abs(with_pi[-1, "Residual"])), 1e-8)
})

test_that("yoy contributions follow the equation (31) of the manual", {
	res <- chain_contrib(vo, cp, vo_total, method = "ao", type = "yoy")
	x <- as.matrix(vo)
	z <- as.numeric(vo_total)
	# annual chain measures 2010-2013: 2010 = current prices, then annual sums
	year <- rep(1:3, each = 4)
	cp_2010 <- colSums(as.matrix(window(cp, end = c(2010, 4))))
	xch <- rbind(cp_2010, rowsum(x, year))
	zch <- c(sum(cp_2010), as.numeric(rowsum(z, year)))
	cp_y <- rbind(cp_2010, rowsum(as.matrix(window(cp, start = c(2011, 1))), year))
	dx <- cp_y / xch                       # annual chain deflators of the components
	dz <- rowSums(cp_y) / zch              # and of the aggregate
	expected <- matrix(NA_real_, 12, 2)
	for (t in 5:12) {
		r <- 2 + (t - 1) %/% 4              # row of the year of t (1 = 2010)
		rho1 <- dx[r - 1, ] / dz[r - 1]
		rho2 <- dx[r - 2, ] / dz[r - 2]
		expected[t, ] <- 100 * ((x[t, ] - x[t - 4, ]) / z[t - 4] * rho1 +
								(x[t - 4, ] / z[t - 4] - xch[r - 1, ] / zch[r - 1]) *
								(rho1 - rho2))
	}
	expect_lt(max(abs(as.matrix(res)[5:12, ] - expected[5:12, ])), 1e-8)
})
