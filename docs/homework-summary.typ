#set page(paper: "a4", margin: (x: 2.2cm, y: 2.2cm))
#set text(font: ("Times New Roman", "SimSun"), size: 11pt, lang: "zh")
#set par(justify: true, leading: 0.65em)
#show raw: set text(font: ("Consolas", "SimSun"), size: 9pt)
#show heading: set block(above: 0.8em, below: 0.4em)

#align(center)[
  #text(size: 18pt, weight: "bold")[R 包实操作业总结]
  #v(0.5em)
  #text(size: 12pt)[班级 046242 · 姓名 黄紫凝]
  #v(0.3em)
  #text(size: 10pt)[
    仓库地址：#link("https://github.com/ningnni/rpkg-component-homework")[github.com/ningnni/rpkg-component-homework]
  ]
]

= 一、操作步骤

+ 下载并打开 R 包模板：通过浏览器从 GitHub 下载 `rpkg.template` 模板的 ZIP 压缩包并解压，得到模板目录。
+ 配置 Pi 与 VS Code：安装并配置 Pi 编码代理与 VS Code 编辑器。
+ 添加 Component.R 函数：获取 RHtests 包 `R/Component.R` 源码，将 `RemoveSeasonal()`、`LS_MultiBreaks()`、`LS_OneBreak()`、`lm_solve()` 四个函数加入本包 `R/component.R`，补充 roxygen 注释，并用 roxygen2 重新生成 `NAMESPACE` 与 `man/` 文档。
+ 编写 Typst 文档与测试：在 `docs/` 下编写中文说明文档，在 `tests/testthat/` 下编写 `test-component.R` 测试。
+ 本地检查：运行 testthat 测试，并执行 `R CMD check --no-manual --no-vignettes`。
+ 上传 GitHub：初始化 Git（分支 `main`），提交作业文件，创建公开仓库并推送。
+ 查看 GitHub Actions：检查 `R-CMD-check`、`test-coverage`、`pkgdown` 三个工作流的运行结果。

= 二、遇到的问题及解决方法

+ `git clone` 连接被重置：改用浏览器下载 ZIP 并解压，绕开命令行网络问题。
+ Pi 扩展重复注册 `vscode_context`：移除重复安装的 npm 包，保留老师提供的 `pi-vscode-context.ts`，成功实时显示选区行数。
+ GitHub CLI 登录时验证码识别失败、网络超时：重新登录授权后成功。
+ Git 提交身份原为老师信息：仅在当前仓库设置本地身份为自己的 GitHub 用户名和 GitHub noreply 邮箱，未修改全局配置。
+ GitHub Actions 首次运行有两个工作流失败，均不是测试失败：
  - `test-coverage` 失败：日志报 `Token required - not valid tokenless upload`，原因是仓库未配置 `CODECOV_TOKEN`，Codecov 上传被拒绝；但其中 `Test coverage` 步骤（运行测试）已成功。
  - `pkgdown` 失败：日志报 `Permission to ningnni/rpkg-component-homework.git denied to github-actions[bot]`，原因是工作流缺少 `contents: write` 权限，无法推送 `gh-pages` 分支。
  - 修复：给 `pkgdown` 任务添加 `permissions: contents: write`；把 `test-coverage` 的 Codecov 上传步骤改为仅在配置了 token 时执行（测试本身仍照常运行）。修复提交为 `3ec74e5`，重新推送后三个工作流全部通过。

= 三、测试和检查结果

== 本地结果

+ testthat：16 条断言全部通过（`test-component.R` 15 条，`test-hello.R` 1 条），0 失败、0 警告、0 跳过。
+ R 包检查：`R CMD check --no-manual --no-vignettes` 结果为 `Status: OK`，0 个错误、0 个警告、0 个提示。

== GitHub Actions 结果（修复后）

#table(
  columns: (auto, auto, 1fr),
  align: (left, center, left),
  inset: 6pt,
  table.header(
    [工作流], [结果], [说明]
  ),
  [R-CMD-check], [成功], [Windows 与 Ubuntu 两个任务均通过，测试在 CI 上真实通过。],
  [test-coverage], [成功], [`Test coverage` 与 `Show testthat output` 步骤成功；`codecov` 上传步骤因未配置 token 被跳过。],
  [pkgdown], [成功], [站点构建并部署到 `gh-pages` 分支成功。],
)

被跳过的步骤：`codecov` 上传（无 token）、以及仅在失败时才运行的 `Upload test results` 步骤，均为预期跳过，不影响测试执行。

= 四、学习体会

通过本次作业，我完整走了一遍 R 包开发与协作流程：从模板入手，把外部源码整理进包结构，补文档、写测试，再到本地检查、上传 GitHub、观察 CI 结果。最大的收获是学会了看日志定位问题——CI 报错往往不是代码逻辑错了，而是权限或密钥这类配置问题。R 包规范（roxygen、NAMESPACE、testthat）和 Git 基本操作也比以前理解得更具体了。今后还需要多加练习，把流程做得更熟练。

= 五、仓库链接

#link("https://github.com/ningnni/rpkg-component-homework")[https://github.com/ningnni/rpkg-component-homework]
