# rexim/dotfiles 可借鉴之处

审阅对象：[rexim/dotfiles](https://github.com/rexim/dotfiles)。结论以仓库当前源码为准，不以配置是否适合 macOS 作为评价标准。

## 最值得学习的做法

### 1. 只收纳正在使用的配置

README 将仓库定义为“actively use”的程序配置，而不是通用装机框架。这条边界很重要：dotfiles 的价值是缩短本人日常路径，不是覆盖所有可能的工具。

我们的仓库已经比它复杂得多，尤其是 Pi 扩展和 skills。后续新增内容时，可以继续用两个问题筛选：

1. 这个配置是否正在被使用？
2. 删除它是否会让日常工作明显变差？

来源：[README](https://github.com/rexim/dotfiles/blob/master/README.md)

### 2. 用显式清单表达部署范围

仓库用 `MANIFEST` 和 `MANIFEST.linux` 区分基础配置与 Linux 配置；每项都明确写出源、操作和目标。这个方案虽然简单，却让“哪些文件会被部署”一眼可见。

我们的 Nix 与 Home Manager 已经是更可靠的实现，不应退回 shell manifest。可借鉴的是**显式 allowlist 和按平台分层**，而不是文件格式本身。只有出现第二台不同角色的机器时，再把当前单一配置拆成共享模块和主机模块；现在无需预先抽象。

来源：[MANIFEST](https://github.com/rexim/dotfiles/blob/master/MANIFEST)、[MANIFEST.linux](https://github.com/rexim/dotfiles/blob/master/MANIFEST.linux)、[deploy.sh](https://github.com/rexim/dotfiles/blob/master/deploy.sh)

### 3. 把编辑器当作个人工作流工具，而不只是插件容器

其 Emacs 配置不仅安装插件，还收纳了作者自己的语言 mode、Org capture、剪贴板命令和自动化流程。`.emacs.local/` 中的 mode 直接服务于作者实际使用的小众语言。

对我们的启发是：当某个编辑或开发动作反复发生时，优先写一个贴近问题的小命令、映射或脚本，不必先寻找大型插件或设计通用框架。

来源：[.emacs](https://github.com/rexim/dotfiles/blob/master/.emacs)、[.emacs.local](https://github.com/rexim/dotfiles/tree/master/.emacs.local)、[org-mode-rc.el](https://github.com/rexim/dotfiles/blob/master/.emacs.rc/org-mode-rc.el)

### 4. 将高频模板沉淀为小型 snippets

仓库保存了大量按语言分类的短 snippet。每个文件只表达一个可复用模板，例如 C 的 `main`，容易查找、修改和删除。这是把重复输入转化为个人知识资产的朴素做法。

我们的 Neovim 暂无同类自定义 snippet。若日后发现稳定、反复输入的模板，可以先收集三到五个真实案例，再使用 Neovim 已有能力实现；不应为了“拥有 snippets”先引入一套庞大插件。

来源：[.emacs.snippets](https://github.com/rexim/dotfiles/tree/master/.emacs.snippets)、[C main snippet](https://github.com/rexim/dotfiles/blob/master/.emacs.snippets/c-mode/main)

### 5. 用小脚本封装完整的个人任务

`bin/` 里的脚本规模很小，并且围绕具体任务命名，例如查询 GCC 搜索路径、录制选区 GIF、准备 PDF 笔记。`prepare-pdf-noting` 又组合 `pdftoppm`、ImageMagick 和另一个本地脚本，符合 Unix 的组合方式。

我们的 `home/bin/` 已经采用类似方向。后续脚本应继续以“完成一个可验证任务”为边界，避免创建只转发参数、没有减少认知负担的包装器。

来源：[bin](https://github.com/rexim/dotfiles/tree/master/bin)、[prepare-pdf-noting](https://github.com/rexim/dotfiles/blob/master/bin/prepare-pdf-noting)

### 6. 为私有或机器特有配置保留明确出口

`.emacs` 最后可选加载未纳入主配置的 `~/.emacs.shadow/shadow-rc.el`。这种边界允许公开仓库保持安全，同时不迫使机器特有设置污染共享配置。

我们的仓库已经明确排除凭据和运行状态。只有当本机确实需要覆盖公开配置时，才值得增加类似的本地入口；否则继续保持当前单一路径更简单。

来源：[.emacs](https://github.com/rexim/dotfiles/blob/master/.emacs)

## 不应照搬的部分

- `deploy.sh` 依赖文本切分且多处未引用 shell 参数，健壮性弱于 Home Manager；我们的部署模型更好。
- Emacs 包在启动时从 MELPA 动态安装，没有版本锁；我们的 `flake.lock`、`lazy-lock.json` 和固定 Pi 包版本更可复现。
- `deploy.ps1` 已注明不支持最新 manifest 格式，说明并行维护多套部署器容易漂移。
- 多处包含硬编码设备名、分辨率、目录和个人身份信息；公开仓库不应复制这种做法。
- 自动保存后执行 `git commit`/`git push` 的功能副作用过大，也绑定旧的 `master` 分支，不适合纳入我们的默认工作流。
- 仓库保留了不少注释掉的配置。显式删除废弃路径比长期注释更适合我们的维护原则。

来源：[deploy.sh](https://github.com/rexim/dotfiles/blob/master/deploy.sh)、[deploy.ps1](https://github.com/rexim/dotfiles/blob/master/deploy.ps1)、[rc.el](https://github.com/rexim/dotfiles/blob/master/.emacs.rc/rc.el)、[autocommit-rc.el](https://github.com/rexim/dotfiles/blob/master/.emacs.rc/autocommit-rc.el)、[screen layouts](https://github.com/rexim/dotfiles/tree/master/.screenlayout)

## 建议优先级

1. **立即采用其筛选原则**：只收纳正在使用、能减少日常摩擦的内容。
2. **继续保持小脚本方向**：发现真实重复任务后再增加脚本。
3. **观察 snippets 需求**：先记录重复模板，不立即新增插件。
4. **暂不拆分主机配置**：等第二台不同角色的机器出现再做。
5. **暂不增加私有 overlay**：等出现公开配置无法表达的真实本机差异再做。

总体上，这个仓库最值得学习的不是某个具体键位或工具，而是它把个人工作流直接、朴素地固化为文件、snippet 和小脚本。我们的仓库在可复现性和部署安全上已经更强，需要吸收的是这种克制，而不是复制它的旧技术栈。
