# 共享组件 API 参考

## ErpFilter — 声明式筛选栏

### Props

| Prop | 类型 | 说明 |
|------|------|------|
| `filters` | `Array` | 筛选项配置数组 |

### Events

| Event | 参数 | 说明 |
|-------|------|------|
| `search` | `{ [key]: value }` | 点击查询按钮 |
| `reset` | — | 点击重置按钮 |

### filters 数组每项

```javascript
{
  key: 'fieldName',           // 字段名（必填）
  label: '字段标签',           // 显示文本（必填）
  type: 'select',             // 类型：select / input / date / daterange
  options: [                  // type=select 时必填
    { label: '显示文本', value: '值' }
  ],
  placeholder: '请选择',       // 占位符
  width: 150,                 // 控件宽度（px）
  default: '',                // 默认值
}
```

### 使用示例

```javascript
const filters = [
  {
    key: 'baseName',
    label: '生产基地',
    type: 'select',
    width: 160,
    options: [
      { label: '珠海SMT厂', value: '珠海SMT厂' },
      { label: '韶关SMT厂', value: '韶关SMT厂' },
    ],
  },
  { key: 'orderCode', label: '订单编号', type: 'input', width: 200 },
  { key: 'createDate', label: '创建日期', type: 'date' },
  { key: 'dateRange', label: '时间范围', type: 'daterange', width: 260 },
]
```

---

## ErpTable — 声明式数据表格

### Props

| Prop | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `columns` | `Array` | — | 列配置数组（必填） |
| `data` | `Array` | `[]` | 表格数据 |
| `total` | `Number` | `0` | 总条数（分页用） |
| `page` | `Number` | `1` | 当前页码（v-model） |
| `pageSize` | `Number` | `20` | 每页条数（v-model） |
| `maxHeight` | `Number` | `520` | 表格最大高度（px） |
| `selectable` | `Boolean` | `true` | 是否显示多选列 |
| `showIndex` | `Boolean` | `false` | 是否显示序号列 |
| `sortHint` | `String` | `''` | 底部排序说明文字 |

### Events

| Event | 参数 | 说明 |
|-------|------|------|
| `selection-change` | `rows[]` | 多选变化 |
| `page-change` | `{ page, pageSize }` | 翻页或改变每页条数 |
| `cell-click` | `{ row, col }` | 点击 render=link 的单元格 |

### columns 数组每项

```javascript
{
  prop: 'fieldName',          // 数据字段名（必填）
  label: '列标题',             // 列标题（必填）
  width: 150,                 // 固定列宽（px）
  minWidth: 100,              // 最小列宽（默认 100）
  fixed: 'left',              // 固定列：'left' / 'right'
  sortable: true,             // 是否可排序
  render: 'tag',              // 渲染模式（见下方）
  subProp: 'subField',        // render=link/textWithSub/textWithInfo 时的副文本字段
}
```

### render 渲染模式

| 值 | 效果 | 适用场景 |
|----|------|---------|
| （默认） | 纯文本 | 普通字段 |
| `tag` | 蓝色标签 | 状态、分类 |
| `dangerTag` | 红色标签 | 异常、警告 |
| `successTag` | 绿色标签 | 成功、正常 |
| `link` | 蓝色可点击链接 | 跳转、查看详情 |
| `textWithSub` | 主文本 + 红色副文本 | 主值 + 异常提示 |
| `textWithInfo` | 主文本 + 灰色副文本 | 主值 + 补充说明 |
| `multiLine` | 多行文本（按 `\n` 换行） | 长文本、地址 |

### 使用示例

```javascript
const columns = [
  { prop: 'orderCode', label: 'SMT订单编号', width: 180, render: 'link', fixed: 'left' },
  { prop: 'baseName', label: '生产基地', width: 120, render: 'tag' },
  { prop: 'status', label: '状态', width: 100, render: 'successTag' },
  { prop: 'qty', label: '贴片数量', width: 100, sortable: true },
  { prop: 'estTime', label: '预估完成', render: 'textWithSub', subProp: 'delay' },
  { prop: 'updateTime', label: '更新时间', width: 170 },
]
```

---

## 弹窗表单常用模式

ERP 风格的编辑弹窗使用 `<table class="form-table">` 布局：

```html
<el-dialog v-model="dialogVisible" title="新增" width="820px">
  <table class="form-table">
    <tr>
      <td class="ft-label required">字段1</td>
      <td class="ft-ctrl">
        <el-input v-model="form.field1" />
      </td>
      <td class="ft-label">字段2</td>
      <td class="ft-ctrl">
        <el-select v-model="form.field2" style="width:100%">
          <el-option label="选项" value="val" />
        </el-select>
      </td>
    </tr>
  </table>
  <template #footer>
    <el-button @click="dialogVisible = false">取消</el-button>
    <el-button type="primary" @click="onSave">保存</el-button>
  </template>
</el-dialog>
```

对应 CSS（页面 scoped 内定义）：

```css
.form-table { width: 100%; border-collapse: collapse; }
.form-table td { padding: 8px 10px; border: 1px solid #ebeef5; }
.ft-label { width: 130px; background: #f5f7fa; font-weight: 600; text-align: right; font-size: 13px; }
.ft-label.required::before { content: '*'; color: #f56c6c; margin-right: 4px; }
.ft-ctrl { min-width: 180px; }
```
