#set page(paper: "a4", margin: 2.5cm)
#set par(justify: true)

#align(center)[
  #text(size: 20pt, weight: "bold")[Component.R 函数说明]
  #v(0.4em)
  #text(size: 11pt)[（改编自 RHtests 包 `R/Component.R`）]
]

= 概述

本包从 RHtests 的 `R/Component.R` 引入四个函数，用于时间序列的季节性剔除与分段线性回归。
其中 `RemoveSeasonal()`、`LS_MultiBreaks()`、`LS_OneBreak()` 对外导出，`lm_solve()` 为内部最小二乘求解器。

== 函数一览

- `RemoveSeasonal(y, t_mmdd)`：去除季节性。
- `LS_MultiBreaks(Y, X, Ips, ...)`：多点分段回归（同斜率、不同截距）。
- `LS_OneBreak(Y, X, Ic, ...)`：单断点分段回归（同斜率、不同截距）。
- `lm_solve(design, response, only.SSE = FALSE, ...)`：最小二乘求解（内部函数）。

= RemoveSeasonal：去除季节性

== 用途

对每个不同的月日（`MMDD`）计算观测均值，并将观测减去对应的季节均值，得到去季节序列。
月尺度最多有 12 个不同的月日，日尺度最多有 366 个。

== 参数

- `y`：观测值向量。
- `t_mmdd`：与 `y` 等长的月日向量，形如 `0101`、`1231`。

== 返回值

返回一个列表：

- `mu`：按 `t_mmdd` 升序排列的季节均值；
- `anomaly`：`y` 减去对应季节均值后的距平序列。

== 使用示例

```r
y <- c(10, 20, 30, 40, 12, 22, 32, 42)
t_mmdd <- c("0101", "0201", "0301", "0401", "0101", "0201", "0301", "0401")

RemoveSeasonal(y, t_mmdd)
# $mu
# [1] 11 21 31 41
#
# $anomaly
# [1] -1 -1 -1 -1  1  1  1  1
```

= LS_MultiBreaks：多点分段回归

== 用途

构造设计矩阵（截距 + 中心化后的 `X` + 各分段指示变量），再用最小二乘求解，
拟合同斜率、不同截距的分段线性模型。

== 参数

- `Y`：响应值（观测序列）。
- `X`：自变量（通常为时间序列）。
- `Ips`：各段末尾的位置，末位为序列长度。
- `...`：传给 `lm_solve()`。

== 返回值

与 `lm_solve()` 相同，返回列表：`coef`、`fitted`、`resi`、`SSE`。

== 使用示例

```r
n <- 40
x <- seq_len(n)
Ips <- c(10, 25, n)
y <- c(rep(1, 10), rep(3, 15), rep(6, 15)) + 0.5 * x

res <- LS_MultiBreaks(y, x, Ips)
res$SSE   # 残差平方和
res$coef  # 系数
```

= LS_OneBreak：单断点分段回归

== 用途

在指定位置 `Ic` 处引入一个水平突变（截距变化），拟合同斜率、不同截距的两段线性模型；
`Ic = NA` 时退化为普通线性回归。

== 参数

- `Y`：响应向量。
- `X`：预测向量。
- `Ic`：变点位置，`1:Ic` 与 `(Ic+1):n` 对应两段；`NA` 表示无断点。
- `...`：传给 `lm_solve()`。

== 返回值

与 `lm_solve()` 相同，返回列表：`coef`、`fitted`、`resi`、`SSE`。

== 使用示例

```r
n <- 30
x <- seq_len(n)
y <- c(rep(10, 15), rep(20, n - 15))

LS_OneBreak(y, x, Ic = 15)
```

= lm_solve：最小二乘求解（内部函数）

== 用途

基于 `stats::.lm.fit()` 求解 `response ~ design`，返回系数、拟合值、残差与残差平方和。
该函数为内部实现细节，供 `LS_MultiBreaks()` 与 `LS_OneBreak()` 调用。

== 参数

- `design`：设计矩阵。
- `response`：响应向量。
- `only.SSE`：是否只返回残差平方和，默认 `FALSE`。
- `...`：预留参数，未使用。

== 返回值

默认返回列表：

- `coef`：系数；
- `fitted`：拟合值；
- `resi`：残差；
- `SSE`：残差平方和。

当 `only.SSE = TRUE` 时只返回 `SSE`。
