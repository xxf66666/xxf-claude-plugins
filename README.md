# xxf-claude-plugins

Claude Code 自定义插件集合，专注于 JLC SMT ERP 原型开发工作流。

## 安装

```
# 在 Claude Code 对话中输入：

# 1. 添加 marketplace（首次）
/plugin marketplace add xxf66666/xxf-claude-plugins

# 2. 安装全部插件
/plugin install page-capture
/plugin install jlc-erp-prototype
/plugin install jlc-erp-docs

# 更新（有新版本时）
/plugin marketplace update xxf-claude-plugins
```

## 插件列表

| 插件 | 说明 | 触发词 |
|------|------|--------|
| **page-capture** | 页面截图 + 交互录屏 | "截图"、"录视频"、"capture page"、"record demo" |
| **jlc-erp-prototype** | ERP 原型页面脚手架 | "新增页面"、"加个页面"、"同步页面"、"做个列表页" |
| **jlc-erp-docs** | 需求文档生成 | "写需求文档"、"梳理需求"、"帮我出个文档" |

---

### page-capture

通过 Playwright MCP 对 Web 页面进行截图和交互录屏，用于生成需求文档素材。

**核心能力：**

- 内容区域裁剪截图（1920x1080，去掉侧边栏/顶栏，只截内容区）
- 滚动分段截图（一屏截不下的自动分段）
- 交互录屏（webm），注入可见红色鼠标指示器
- ECharts canvas 精确点击（图例切换、坐标轴标签点击、双击复制）
- 批量录制：一个脚本录多段视频，自动重命名

**前置条件：**

- 已安装 Playwright 插件（`playwright@claude-plugins-official`）
- 目标页面可通过 URL 访问（如 `http://localhost:3000`）
- 录屏需要：`npx playwright install ffmpeg`

**包含资源：**

| 文件 | 说明 |
|------|------|
| `SKILL.md` | 截图/录屏完整工作流 |
| `references/echarts-coordinates.md` | ECharts canvas 坐标计算指南 |
| `references/playwright-video-api.md` | Playwright 录屏 API 参考 |
| `scripts/rename-videos.sh` | 批量重命名 Playwright 视频 |

---

### jlc-erp-prototype

为 JLC SMT ERP 原型项目快速生成页面。Vue 3 + Element Plus + ECharts，纯前端 mock 数据。

**页面模板：**

| 模板 | 适用场景 | 参考页面 |
|------|---------|---------|
| 模板A：列表页 | ErpFilter + ErpTable + 弹窗编辑 | `BaseRelationPage.vue` |
| 模板B：卡片页 | 自定义卡片布局 | `RushConfigPage.vue` |
| 模板C：图表页 | ECharts 图表 | `CapacityOverviewPage.vue` |
| 模板D：同步页面 | 从线上 HTML 还原字段和布局 | 用户提供 HTML |

**新增页面三步走：**

1. `src/pages/XxxPage.vue` — 创建页面文件
2. `src/router/index.js` — 注册二级路由（`/模块/页面名`）
3. `src/layout/ErpLayout.vue` — 添加侧边栏菜单（必须在分组 children 下）+ 顶部页签

**编码约定：**

- 路由必须二级路径：`/prod-related/xxx`，不允许一级扁平
- 菜单必须放在分组 children 下，不允许一级菜单直接导航
- scoped CSS、中文界面、数据不可变、不调 API

**包含资源：**

| 文件 | 说明 |
|------|------|
| `SKILL.md` | 4 种页面模板 + 三步注册流程 + 编码约定 |
| `references/component-api.md` | ErpFilter / ErpTable 组件完整 API |

---

### jlc-erp-docs

为 ERP 原型功能生成标准化需求文档，配合 `page-capture` 自动附截图和录屏。

**文档结构（按功能复杂度取舍）：**

| 章节 | 内容 | 何时需要 |
|------|------|---------|
| 1. 背景 | 现状痛点、核心需求、与现有功能关系 | 始终需要 |
| 2. 功能概述 | 页面入口、功能清单表 | 始终需要 |
| 3. 详细设计 | 每个功能模块的布局/交互/数据 + 截图 + 录屏 | 始终需要 |
| 4. 数据联动 | Mermaid 流程图 + 联动规则 | 有联动时 |
| 5. 数据总览 | 当前数据规模和分布 | 有数据时 |
| 6. 使用场景 | 场景-操作对照表 | 复杂功能时 |

**写作原则：**

- 截图配在对应章节旁，不集中放末尾
- 交互录屏每个交互一段视频
- 表格优先，能用表格的不用段落
- 不写虚构 URL、不写技术实现章节、不留空章节
- Mermaid 图不超过 8 个节点，联动细节用文字补充

**输出目录结构：**

```
需求文档/{功能名}/
├── {功能名}.md
└── screenshots/
    ├── 01-xxx.png
    ├── 02-xxx.png
    └── 03-xxx.webm
```

---

## 新增插件

```
plugins/
└── your-plugin/
    ├── .claude-plugin/
    │   └── plugin.json        # name + description
    └── skills/
        └── your-skill/
            ├── SKILL.md       # 核心技能文档（<2000词）
            ├── references/    # 详细参考资料（按需加载）
            └── scripts/       # 工具脚本
```

在根目录 `.claude-plugin/marketplace.json` 的 `plugins` 数组中添加条目，push 后执行：

```
/plugin marketplace update xxf-claude-plugins
/plugin install your-plugin
```
