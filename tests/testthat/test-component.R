test_that("RemoveSeasonal 计算季节均值与距平", {
  y <- c(10, 20, 30, 40, 12, 22, 32, 42)
  t_mmdd <- c("0101", "0201", "0301", "0401", "0101", "0201", "0301", "0401")

  res <- RemoveSeasonal(y, t_mmdd)

  expect_equal(res$mu, c(11, 21, 31, 41))
  expect_equal(res$anomaly, c(-1, -1, -1, -1, 1, 1, 1, 1))
})

test_that("RemoveSeasonal 计算均值时忽略 NA", {
  y <- c(1, 2, 3, NA, 5, 6)
  t_mmdd <- c("a", "a", "b", "b", "b", "b")

  res <- RemoveSeasonal(y, t_mmdd)

  expect_equal(res$mu, c(1.5, 14 / 3))
  expect_equal(res$anomaly, c(-0.5, 0.5, 3 - 14 / 3, NA, 5 - 14 / 3, 6 - 14 / 3))
})

test_that("LS_OneBreak 无断点时等价于普通线性回归", {
  set.seed(1)
  x <- seq_len(20)
  y <- 3 + 2 * x + rnorm(20, sd = 0.1)

  res <- LS_OneBreak(y, x, NA)
  fit <- lm(y ~ x)

  expect_equal(as.numeric(res$coef), as.numeric(coef(fit)))
  expect_equal(res$fitted, as.numeric(fitted(fit)))
  expect_equal(res$SSE, sum(resid(fit)^2))
})

test_that("LS_OneBreak 能估计水平突变", {
  n <- 30
  x <- seq_len(n)
  Ic <- 15
  y <- c(rep(10, Ic), rep(20, n - Ic))

  res <- LS_OneBreak(y, x, Ic)

  expect_equal(res$fitted, y)
  expect_lt(res$SSE, 1e-10)
})

test_that("LS_MultiBreaks 拟合分段截距", {
  n <- 40
  x <- seq_len(n)
  Ips <- c(10, 25, n)
  y <- c(rep(1, 10), rep(3, 15), rep(6, 15)) + 0.5 * x

  res <- LS_MultiBreaks(y, x, Ips)

  expect_equal(res$fitted, y)
  expect_lt(res$SSE, 1e-10)
})

test_that("LS_MultiBreaks 单段与 LS_OneBreak 无断点结果一致", {
  set.seed(42)
  x <- runif(50)
  y <- 2 + 0.3 * x + rnorm(50, sd = 0.2)

  multi <- LS_MultiBreaks(y, x, length(x))
  single <- LS_OneBreak(y, x, NA)

  expect_equal(multi$fitted, single$fitted)
  expect_equal(multi$SSE, single$SSE)
})

test_that("lm_solve 在 only.SSE = TRUE 时只返回残差平方和", {
  design <- cbind(1, seq_len(10))
  y <- 2 + 3 * seq_len(10)

  res <- lm_solve(design, y, only.SSE = TRUE)

  expect_named(res, "SSE")
  expect_equal(res$SSE, 0)
})
