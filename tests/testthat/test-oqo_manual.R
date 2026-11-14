# Example 8.7 (one-quarter overlap), as printed in the IMF QNA Manual (2017):
# columns A, B and Sum, 2011Q1-2013Q4. Figures are printed with 1 or 2 decimals.
cy_pdf <- cbind(A = c(160.7, 163.4, 166.8, 169.1, 172.9, 179.9, 190.2, 216.0, 222.1, 235.4, 243.7, 247.5),
				B = c(217.8, 214.8, 211.7, 210.6, 206.9, 200.1, 192.0, 170.6, 167.8, 156.4, 147.9, 143.5))
index_pdf <- cbind(A = c(104.38, 106.15, 108.35, 109.84, 110.39, 114.88, 121.49, 137.91, 142.77, 151.33, 156.68, 159.09),
				   B = c(98.27, 96.92, 95.51, 95.04, 94.94, 91.79, 88.09, 78.25, 76.17, 71.01, 67.13, 65.14),
				   Total = c(100.71, 100.61, 100.65, 100.96, 101.13, 101.11, 101.63, 102.56, 103.37, 103.94, 103.92, 103.77))
measure_pdf <- cbind(A = c(156.6, 159.2, 162.5, 164.8, 165.6, 172.3, 182.2, 206.9, 214.2, 227.0, 235.0, 238.6),
					 B = c(221.1, 218.1, 214.9, 213.8, 213.6, 206.5, 198.2, 176.1, 171.4, 159.8, 151.0, 146.6),
					 Total = c(377.7, 377.3, 377.4, 378.6, 379.2, 379.2, 381.1, 384.6, 387.6, 389.8, 389.7, 389.2))
discrepancy_pdf <- c(0, 0, 0, 0, 0, -0.3, -0.7, -1.7, -2.1, -3.0, -3.7, -4.0)

test_that("cp_pi2cy: current year's prices of the example 8.7", {
	cy <- cp_pi2cy(data8.2cp, data8.2ep)
	expect_equal(colnames(cy), c("A", "B"))
	expect_true(all(is.na(window(cy, end = c(2010, 4)))))
	got <- as.matrix(window(cy, start = c(2011, 1)))[1:12, ]
	expect_lt(max(abs(got - cy_pdf)), 0.06)
	# the annual sums are the annual current prices
	ann <- stats::aggregate(window(cy, start = c(2011, 1)), FUN = sum)
	cp_ann <- stats::aggregate(window(data8.2cp, start = c(2011, 1)), FUN = sum)
	expect_equal(as.numeric(ann), as.numeric(cp_ann))
	# single series
	expect_equal(as.numeric(cp_pi2cy(data8.2cp[, "A"], data8.2ep[, "A"])),
				 as.numeric(cy[, "A"]))
})

test_that("one-quarter overlap: chain indices and measures of the example 8.7", {
	idx <- chain_laspeyres(data8.2cp, data8.2ep, method = "oqo", base_year = 2010)
	expect_equal(colnames(idx), c("A", "B", "Total"))
	expect_equal(start(idx), c(2011, 1))
	expect_lt(max(abs(as.matrix(idx) - index_pdf)), 0.01)
	mea <- chain_laspeyres(data8.2cp, data8.2ep, method = "oqo", base_year = 2010,
						   output = "measure")
	expect_lt(max(abs(as.matrix(mea) - measure_pdf)), 0.06)
	# sum of the quarterly values of the total: 1511.0, 1524.1 and 1556.3
	ann <- as.numeric(stats::aggregate(mea[, "Total"], FUN = sum))
	expect_lt(max(abs(ann - c(1511.0, 1524.1, 1556.3))), 0.06)
	# discrepancies (sum of the components minus the total), column of the table
	disc <- chain_discrepancy(mea)
	expect_lt(max(abs(as.numeric(disc) - discrepancy_pdf)), 0.15)
})

test_that("annex 8.1: ratio between the annual overlap and one-quarter overlap series", {
	ao <- chain_laspeyres(data8.2cp, data8.2ep, method = "ao", base_year = 2010,
						  output = "measure")[, "Total"]
	qo <- chain_laspeyres(data8.2cp, data8.2ep, method = "oqo", base_year = 2010,
						  output = "measure")[, "Total"]
	ratio <- as.numeric(ao / qo)
	expect_equal(ratio[1:4], rep(1, 4), tolerance = 1e-8)         # 2011
	expect_equal(ratio[5:8], rep(1.00039, 4), tolerance = 2e-5)  # 2012
	expect_equal(ratio[9:12], rep(1.00250, 4), tolerance = 2e-5) # 2013
})

test_that("contributions of the one-quarter overlap add up exactly on the data of the manual", {
	x <- chain_laspeyres(data8.2cp, data8.2ep, method = "oqo", base_year = 2010,
						 output = "measure")
	for (type in c("period", "yoy")) {
		res <- chain_contrib(x, data8.2cp, method = "oqo", type = type, pi = data8.2ep,
							 extra = "residual")
		expect_lt(max(abs(res[, "Residual"]), na.rm = TRUE), 1e-8)
	}
	# the formulas with the annual deflators (footnote 35) are only approximately additive
	res_ao <- chain_contrib(x, data8.2cp, method = "ao", extra = "residual")
	expect_gt(max(abs(res_ao[, "Residual"]), na.rm = TRUE), 1e-6)
})
