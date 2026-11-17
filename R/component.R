#' 去除季节性（按日历日求均值）
#'
#' 对每个不同的月日（MMDD）计算观测均值，并将观测减去对应季节均值，
#' 得到去季节序列。月尺度最多 12 个不同的月日，日尺度最多 366 个。
#'
#' @param y 观测值向量。
#' @param t_mmdd 与 `y` 等长的月日向量，形如 `0101`、`1231`。
#'
#' @return 一个列表：
#' - `mu`：按 `t_mmdd` 升序排列的季节均值；
#' - `anomaly`：`y` 减去对应季节均值后的距平序列。
#' @export
RemoveSeasonal <- function(y, t_mmdd) {
  inds <- sort(unique(t_mmdd)) # 月尺度最多 12 个，日尺度最多 366 个
  mu <- numeric(length(inds))
  anomaly <- numeric(length(y))
  for (i in seq_along(inds)) {
    ind <- which(t_mmdd == inds[i])
    mu[i] <- mean(y[ind], na.rm = TRUE)
    anomaly[ind] <- y[ind] - mu[i]
  }
  list(mu = mu, anomaly = anomaly)
}

#' 多点分段回归（同斜率、不同截距）
#'
#' 构造设计矩阵：截距 + 中心化后的 `X` + 各分段指示变量，
#' 再用最小二乘求解。
#'
#' @param Y 响应值（观测序列）。
#' @param X 自变量（通常为时间序列）。
#' @param Ips 各段末尾的位置，末位为序列长度。
#' @param ... 传给 `lm_solve()`。
#'
#' @return 与 `lm_solve()` 相同的列表：`coef`、`fitted`、`resi`、`SSE`。
#' @export
LS_MultiBreaks <- function(Y, X, Ips, ...) {
  n_breaks <- length(Ips) - 1
  design <- cbind(1, X - mean(X))
  for (i in seq_len(n_breaks)) {
    segment <- numeric(length(Y))
    segment[(Ips[i] + 1):Ips[i + 1]] <- 1
    design <- cbind(design, segment)
  }
  lm_solve(design, Y, ...)
}

#' 单断点分段回归（同斜率、不同截距）
#'
#' @param Y 响应向量。
#' @param X 预测向量。
#' @param Ic 变点位置：`1:Ic` 与 `(Ic+1):n` 对应两段；`NA` 表示无断点。
#' @param ... 传给 `lm_solve()`。
#'
#' @return 与 `lm_solve()` 相同的列表，另含 `SSE`。
#' @export
LS_OneBreak <- function(Y, X, Ic, ...) {
  n <- length(Y)
  design <- cbind(1, X)
  if (!is.na(Ic)) {
    design <- cbind(design, c(rep(0, Ic), rep(1, n - Ic)))
  }
  lm_solve(design, Y, ...)
}

#' 最小二乘求解
#'
#' 基于 [stats::.lm.fit()] 求解 `response ~ design`，返回系数、拟合值、
#' 残差与残差平方和。
#'
#' @param design 设计矩阵。
#' @param response 响应向量。
#' @param only.SSE 是否只返回残差平方和。
#' @param ... 预留参数，未使用。
#'
#' @return 列表：
#' - `coef`：系数；
#' - `fitted`：拟合值；
#' - `resi`：残差；
#' - `SSE`：残差平方和。
#'
#' 当 `only.SSE = TRUE` 时只返回 `SSE`。
#' @keywords internal
lm_solve <- function(design, response, only.SSE = FALSE, ...) {
  l <- stats::.lm.fit(design, as.matrix(response))
  fitted <- design %*% l$coefficients
  SSE <- sum(l$residuals^2)
  if (!only.SSE) {
    list(
      coef = l$coefficients,
      fitted = as.vector(fitted),
      resi = l$residuals,
      SSE = SSE
    )
  } else {
    list(SSE = SSE)
  }
}
