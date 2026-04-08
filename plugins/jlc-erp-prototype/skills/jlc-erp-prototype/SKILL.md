---
name: jlc-erp-prototype
description: This skill should be used when the user asks to "新增页面", "加个页面", "新建ERP页面", "add a page", "create page", "同步页面", "做个列表页", "做个卡片页", "做个图表页", or mentions adding a new page to the JLC SMT ERP prototype project.
---

# JLC ERP 原型页面脚手架

为嘉立创 SMT ERP 原型项目快速生成页面。纯前端、无后端、全部 mock 数据。

## 项目定位

`D:\Project\vue\JLC-ERP` — Vue 3 + Element Plus + ECharts 原型项目，用于验证页面设计和交互方案。

## 新增页面三步走

每新增一个页面，**必须改三个文件**：

### 1. 创建页面文件

在 `src/pages/` 下创建 `XxxPage.vue`，选择合适的页面模式（见下方模板）。

### 2. 注册路由

在 `src/router/index.js` 的 `// ========== 新页面在这里加 ==========` 注释前添加。

**路由必须使用二级路径**，格式 `/模块/页面名`，不允许一级扁平路径：

```javascript
// 正确 ✓
{ path: '/prod-related/base-relation', ... }
{ path: '/rush-manage/rush-data', ... }
{ path: '/smt-order/query', ... }

// 错误 ✗ 不要用一级路径
{ path: '/base-relation', ... }
{ path: '/rush-data', ... }
```

现有模块前缀参考：

| 模块前缀 | 对应菜单分组 |
|---------|------------|
| `/prod-manage` | 生产流水线管理 |
| `/prod-related` | 生产相关设置 |
| `/capacity` | 产能可视化看板 |
| `/rush-manage` | 订单加急管理 |
| `/smt-order` | SMT订单管理 |

新页面归属不明时，根据业务含义选择最近的分组，或创建新的模块前缀。

### 3. 注册菜单和页签

在 `src/layout/ErpLayout.vue` 中：

**侧边栏菜单** — **必须放在某个分组的 `children` 下**，不允许作为一级菜单项直接导航：

```javascript
// 正确 ✓ 放在分组的 children 里
{
  id: 'prod-related', label: '生产相关设置', icon: 'Tools',
  children: [
    { id: 'base-relation', label: '生产基地对应关系', path: '/prod-related/base-relation' },
    { id: 'new-page', label: '新页面', path: '/prod-related/new-page' },  // ← 加这里
  ],
},

// 错误 ✗ 不要作为一级菜单项
{ id: 'new-page', label: '新页面', icon: 'Document', path: '/new-page' },
```

**顶部页签** — 在 `tabs` 数组中添加：

```javascript
{ label: '页面标题', path: '/prod-related/new-page' }
```

## 页面模板

### 模板A：列表页（最常用）

ErpFilter 筛选栏 + ErpTable 数据表格 + 弹窗编辑。参考 `BaseRelationPage.vue`。

```vue
<template>
  <div class="page-container">
    <h3 class="page-title">页面标题</h3>

    <ErpFilter :filters="filters" @search="onSearch" @reset="onReset" />

    <div class="action-bar">
      <el-button type="primary" @click="onAdd">新增</el-button>
      <el-button type="primary" @click="onEdit">修改</el-button>
    </div>

    <ErpTable
      :columns="columns"
      :data="tableData"
      :total="total"
      :selectable="true"
      v-model:page="page"
      v-model:pageSize="pageSize"
      @selection-change="onSelectionChange"
    />

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <!-- 表单内容 -->
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="onSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import ErpFilter from '../components/ErpFilter.vue'
import ErpTable from '../components/ErpTable.vue'

// 筛选配置
const filters = [
  { key: 'field1', label: '字段1', type: 'select', options: [
    { label: '选项A', value: 'a' },
  ]},
  { key: 'field2', label: '字段2', type: 'input' },
]

// 表格列配置
const columns = [
  { prop: 'name', label: '名称', width: 150 },
  { prop: 'status', label: '状态', render: 'tag' },
  { prop: 'updateTime', label: '更新时间', width: 170 },
]

// Mock 数据
const tableData = ref([/* ... */])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)

function onSearch(params) { /* 筛选逻辑 */ }
function onReset() { /* 重置 */ }
</script>

<style scoped>
.page-container { padding: 20px; }
.page-title { margin: 0 0 16px; font-size: 18px; font-weight: 700; color: #303133; }
.action-bar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>
```

#### ErpFilter 配置说明

`filters` 数组每项：

| 字段 | 说明 |
|------|------|
| `key` | 字段名 |
| `label` | 标签文本 |
| `type` | `select` / `input` / `date` / `daterange` |
| `options` | type=select 时的选项数组 `[{ label, value }]` |
| `width` | 控件宽度（px），默认 150 |
| `default` | 默认值 |

#### ErpTable 列配置说明

`columns` 数组每项：

| 字段 | 说明 |
|------|------|
| `prop` | 数据字段名 |
| `label` | 列标题 |
| `width` / `minWidth` | 列宽 |
| `render` | 渲染模式：`tag`(蓝标签) / `dangerTag`(红标签) / `successTag`(绿标签) / `link`(可点击链接) |
| `sortable` | 是否可排序 |
| `fixed` | 固定列：`'left'` / `'right'` |

### 模板B：卡片页

自定义卡片布局，用于配置类页面。参考 `RushConfigPage.vue`。

```vue
<template>
  <div class="page-container">
    <h3 class="page-title">页面标题</h3>

    <div class="card-row">
      <div v-for="item in list" :key="item.id" class="item-card">
        <div class="card-header">
          <span>{{ item.name }}</span>
          <el-tag size="small">{{ item.status }}</el-tag>
        </div>
        <div class="card-body">
          <!-- 卡片内容 -->
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const list = ref([/* mock 数据 */])
</script>

<style scoped>
.page-container { padding: 20px; }
.page-title { margin: 0 0 16px; font-size: 18px; font-weight: 700; color: #303133; }
.card-row { display: flex; flex-wrap: wrap; gap: 16px; }
.item-card {
  flex: 1; min-width: 280px; max-width: 400px;
  border: 1px solid #e4e7ed; border-radius: 8px; padding: 16px;
}
.card-header { display: flex; justify-content: space-between; margin-bottom: 12px; }
</style>
```

### 模板C：图表页

ECharts 图表，注意 dispose 和 resize。参考 `CapacityOverviewPage.vue`、`BaseDepthMonitorPage.vue`。

```vue
<template>
  <div class="page-container">
    <h3 class="page-title">页面标题</h3>
    <div ref="chartRef" class="chart-box"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'

const chartRef = ref(null)
let chart = null

function initChart() {
  chart = echarts.init(chartRef.value)
  chart.setOption({
    /* ECharts 配置 */
  })
}

function handleResize() { chart?.resize() }

onMounted(() => {
  initChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  chart?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.page-container { padding: 20px; }
.page-title { margin: 0 0 16px; font-size: 18px; font-weight: 700; color: #303133; }
.chart-box { width: 100%; height: 500px; }
</style>
```

### 模板D：同步线上页面

用户提供真实 ERP 系统的 HTML 片段或截图，需要精确还原字段名和布局。

流程：
1. 从 HTML 提取字段名、表头、下拉选项等真实数据
2. 选择合适的页面模板（A/B/C）
3. 用真实字段名填充模板，mock 数据尽量贴近真实值
4. 不要猜测字段名，严格按 HTML 中的文本

## 编码约定

- 中文界面、中文注释
- 所有页面使用 scoped CSS
- 数据不可变：`list.value = list.value.map(...)` 而非直接修改
- Mock 数据直接写在 `ref()` 中或 `src/mock/` 下
- 不调用任何 API，不写 axios/fetch

## Additional Resources

### Reference Files

- **`references/component-api.md`** — ErpFilter 和 ErpTable 组件的完整 API
