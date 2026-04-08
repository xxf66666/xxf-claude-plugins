# xxf-claude-plugins

Claude Code 自定义插件集合。

## 安装

```
# 在 Claude Code 对话中输入：

# 1. 添加 marketplace（首次）
/plugin marketplace add xxf66666/xxf-claude-plugins

# 2. 安装插件
/plugin install page-capture
```

## 插件列表

| 插件 | 说明 | 触发词 |
|------|------|--------|
| **page-capture** | 用 Playwright 截图 + 录制交互视频 | "截图"、"录视频"、"capture page"、"record demo" |
| **jlc-erp-prototype** | JLC ERP 原型页面脚手架 | "新增页面"、"加个页面"、"同步页面"、"做个列表页" |
| **jlc-erp-docs** | JLC ERP 需求文档生成 | "写需求文档"、"梳理需求"、"帮我出个文档" |

### page-capture

通过 Playwright MCP 对 Web 页面进行截图和交互录屏，用于生成需求文档素材。

**核心能力：**

- 内容区域裁剪截图（去掉侧边栏/顶栏）
- 滚动分段截图
- 交互录屏（webm），带可见鼠标指示器
- ECharts canvas 元素的精确点击（图例、坐标轴标签）
- 批量录制多个交互视频

**前置条件：**

- 已安装 Playwright 插件（`playwright@claude-plugins-official`）
- 目标页面可通过 URL 访问
- 录屏需要：`npx playwright install ffmpeg`

## 新增插件

```
plugins/
└── your-plugin/
    ├── .claude-plugin/
    │   └── plugin.json        # name + description
    └── skills/
        └── your-skill/
            ├── SKILL.md       # 核心技能文档
            ├── references/    # 详细参考资料
            └── scripts/       # 工具脚本
```

在 `.claude-plugin/marketplace.json` 的 `plugins` 数组中添加条目，push 后 `/install` 更新即可。
