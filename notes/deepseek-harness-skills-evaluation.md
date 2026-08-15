# DeepSeek Harness 官方 skills 评估

评估基于 `deepseek-ai/deepseek-harness` 的 `master` 分支提交
[`47f9438`](https://github.com/deepseek-ai/deepseek-harness/tree/47f943859bef60e4160492346772ded9b24f765a/.agents/skills)。
上游共有 11 个 skill。以下结论针对当前 dotfiles 仓库与全局 Pi skill 组合，而不是评价这些 skill 在 DeepSeek Harness 自身的质量。

当前仓库的 skills 统一位于 `home/.agents/skills/`，其中已有 `code-simplifier`、`code-review`、`prompt-optimizer`、`writing-great-skills`、`agent-native-hardening` 和 `anti-ai-copy` 等。因此应先扩充现有 owner，避免为相同触发条件再建 skill。

## 建议吸收

### 1. `dsh-find-simplifications`：高价值，提炼方法而非原样安装

最有价值的是它要求先证明生产消费者、所有权和生命周期，再提出删除；同时把依赖替换按“净删除量”评估，而不是把“零依赖”当目标。这和本项目的第一性原理、最小改动以及不为假设场景增加抽象高度一致。

不应照搬 DeepSeek Harness 的 Agent Note、双适配器、包结构等项目专属规则。现有 `code-simplifier` 已覆盖“保持行为不变的局部简化”，而该上游 skill 更适合补充 `agent-native-hardening` 的跨模块审计：

- 按生产调用者、测试/文档调用者、动态入口分类证据；
- 每个抽象、状态和兼容路径都必须映射到当前契约与所有者；
- 对手写基础设施比较成熟依赖时计算净删除量；
- 复杂异步逻辑先画所有权和状态转换，再判断能否合并机制。

来源：[dsh-find-simplifications](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-find-simplifications/SKILL.md)

### 2. `dsh-pre-push-checks`：高价值，改造成通用变更验证

核心原则是“为实际 diff 选择能捕获该回归的最小证据”，而不是条件反射地跑全量测试。它还区分测试选择与覆盖范围，并要求历史改写使用精确的 `--force-with-lease`。

当前仓库默认只本地提交、不主动 push，因此不值得安装一个名为 pre-push 的完整 skill。更适合把以下规则加入通用编码工作流或新建很小的 `change-validation` skill：

- 先确认仓库、分支、基线和完整 diff；
- 每项行为变化至少有一个会因目标回归而失败的检查；
- 不重复刚刚通过、且提交钩子会再次执行的检查；
- 只有跨仓库改动或用户明确要求时才跑全量套件；
- 精确报告已运行、未运行和仍在等待的检查。

来源：[dsh-pre-push-checks](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-pre-push-checks/SKILL.md)

### 3. `dsh-prose-standard` + `dsh-trim-cot-leakage`：高价值，合并进现有 `anti-ai-copy`

两者最有价值的共同原则是：先枚举段落中的完整命题，再删除推理过程、改动叙事、评审对话和重复内容。`trim-cot-leakage` 的 HEAD 可解析性测试尤其好：读者不看会话、PR 线程或未提交草稿，是否仍能解析引用并验证主张。

它们和现有 `anti-ai-copy` 高度重叠，模型可见文字部分也已有 `prompt-optimizer` 负责，不应新增两个相互触发的 skill。建议吸收：

- 保留 actor、条件、时序、义务强度、负面保证、所有权和失败后果；
- 注释只保留代码无法表达的契约、竞态、所有权和非显然理由；
- 当前态文档不用 “used to / now / this PR” 叙述变更过程；
- 诊断信息明确失败对象、违反的规则和可执行修复；
- 模型可见 prompt、工具描述和 UI 文案按行为变更审查。

来源：[dsh-prose-standard](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-prose-standard/SKILL.md)、[dsh-trim-cot-leakage](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-trim-cot-leakage/SKILL.md)

### 4. `dsh-code-review`：中高价值，只补充现有 review skills

当前已有 `code-review` 和 `agent-native-hardening`，完整安装会重复。值得补入的检查是：

- 沿接口两端追踪取消、清理、错误和所有权；
- 检查限制是否覆盖最终输出，而不只是内部片段；
- 验证拒绝路径能否被备用入口绕过；
- 测试是否经过真实 Loader、CLI、worker 或 subprocess 入口；
- 从模型视角检查实际 prompt、tool schema、result 和 diagnostic；
- 区分借用状态与拥有状态，追踪所有缓存和派生视图的权威来源。

来源：[dsh-code-review](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-code-review/SKILL.md)

## 按需借鉴

| Skill | 价值 | 结论 |
| --- | --- | --- |
| `dsh-archive-agent-notes` | 中 | “按未来决策价值保留、归档或删除”的判断适合维护 `AGENTS.md` 项目记忆；三文件归档、封存哈希等机制不适合当前仓库。 |
| `record-browser-gif` | 中，场景限定 | 对 GUI 项目很有价值：同一 commit、真实服务、隔离状态、语义状态截图、编码后复验构成完整证据链。dotfiles 当前没有产品 Web UI，不应常驻启用。 |
| `dsh-merging-stacked-prs` | 低，场景限定 | 只有采用 GitHub 官方 stacked PR 工作流时才有用；当前仓库没有该流程，保留链接即可。 |

来源：[dsh-archive-agent-notes](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-archive-agent-notes/SKILL.md)、[record-browser-gif](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/record-browser-gif/SKILL.md)、[dsh-merging-stacked-prs](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-merging-stacked-prs/SKILL.md)

## 当前没有价值

- `dsh-doc-site-sync`：完全绑定 DeepSeek Harness 的 VitePress 投影、manifest 和双语路由。
- `dsh-doc-standards`：文档层级、预算、双语配对和门禁均绑定 DeepSeek Harness，对当前工作流没有实际价值。
- `dsh-translate-docs`：绑定 `foo.md` / `foo.zh.md` / `foo.i18n.yaml` 三文件协议和专用脚本。

除非未来项目采用相同文档架构，否则移植它们只会增加无消费者的流程。

来源：[dsh-doc-site-sync](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-doc-site-sync/SKILL.md)、[dsh-doc-standards](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-doc-standards/SKILL.md)、[dsh-translate-docs](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/.agents/skills/dsh-translate-docs/SKILL.md)

## 建议顺序

1. 以 `dsh-find-simplifications`、`dsh-prose-standard` 和 `dsh-trim-cot-leakage` 为基础维护通用版 `find-simplifications`、`prose-standard` 和 `trim-cot-leakage`。
2. 其他上游 skill 不复制。
3. 仅当实际出现复杂 GUI PR 或 stacked PR 时，再安装对应的专用 skill。

这样能获得上游最通用的判断框架，同时避免新增四组重叠触发器和 DeepSeek Harness 专属流程。
