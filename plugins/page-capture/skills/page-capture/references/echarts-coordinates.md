# ECharts Canvas Coordinate Guide

## Overview

ECharts renders charts on HTML5 `<canvas>` elements. To programmatically click on chart elements (legends, axis labels, bars, etc.), compute coordinates relative to the canvas element, then dispatch native MouseEvent.

## Coordinate System

```
Canvas Element (0,0)
┌──────────────────────────────────────────────────────┐
│  Legend area (y ≈ 8-20)                              │
│  [■ Series A]  [■ Series B]  [■ Series C]            │
│                                                      │
│  ┌─ Grid area ────────────────────────────────────┐  │
│  │                                                │  │ ← grid.top
│  │  Y-axis     Plot area                          │  │
│  │  labels                                        │  │
│  │  (x < gridLeft)                                │  │
│  │                                                │  │
│  └────────────────────────────────────────────────┘  │ ← height - grid.bottom
│     ↑                                            ↑   │
│  grid.left                              width - grid.right
└──────────────────────────────────────────────────────┘
```

## Step-by-Step Coordinate Calculation

### 1. Get Container Position (Page Coordinates)

```javascript
() => {
  const el = document.querySelector('.chart-container');
  const rect = el.getBoundingClientRect();
  return {
    left: rect.left,    // page X of canvas top-left
    top: rect.top,      // page Y of canvas top-left
    width: rect.width,  // canvas CSS width
    height: rect.height // canvas CSS height
  };
}
```

### 2. Know the Grid Config

From the ECharts option (check the source code):

```javascript
grid: { left: 160, right: 30, top: 40, bottom: 30 }
```

### 3. Compute Plot Area (Canvas-Relative)

```
plotLeft   = grid.left                    // 160
plotTop    = grid.top                     // 40
plotRight  = canvasWidth - grid.right     // e.g. 1227 - 30 = 1197
plotBottom = canvasHeight - grid.bottom   // e.g. 618 - 30 = 588
plotWidth  = plotRight - plotLeft         // 1037
plotHeight = plotBottom - plotTop         // 548
```

### 4. Category Axis Row Positions

For a category (Y) axis with N categories:

```
rowHeight = plotHeight / N
rowCenter(i) = plotTop + i * rowHeight + rowHeight / 2
```

Example with 18 categories, plotHeight=548:
```
rowHeight = 548 / 18 ≈ 30.4
row 0 center = 40 + 0 * 30.4 + 15.2 = 55.2
row 1 center = 40 + 1 * 30.4 + 15.2 = 85.6
row 4 center = 40 + 4 * 30.4 + 15.2 = 177.0
```

### 5. Legend Item Positions

Legends default to top-center layout:

```
legendY ≈ 8-15 (canvas-relative)
```

For N legend items centered in canvas width:
- Estimate each item width ≈ icon(20px) + text(60-80px) + gap(20px) ≈ 100-120px
- Total legend width ≈ N * 110
- First item X ≈ (canvasWidth - totalWidth) / 2 + 50
- Item spacing ≈ 110-130px

More reliable: take a screenshot, measure pixel positions visually.

### 6. Value Axis Data Positions

For a value (X) axis mapping data values to pixels:

```
pixelX = plotLeft + (value - axisMin) / (axisMax - axisMin) * plotWidth
```

Example: value=51 on axis [0, 200], plotLeft=160, plotWidth=1037:
```
pixelX = 160 + (51 / 200) * 1037 = 160 + 264 = 424
```

## Y-Axis Label Click Area

ECharts `triggerEvent: true` on yAxis makes axis labels clickable. The click detection area covers the rendered text bounding box.

Labels are typically right-aligned to `grid.left`. The clickable area:
```
x: roughly (grid.left - labelWidth) to grid.left
y: rowCenter - fontSize/2 to rowCenter + fontSize/2
```

For reliable clicking, target:
```
canvasX = grid.left - 20   // e.g. 140
canvasY = rowCenter(i)      // computed from row index
```

## Converting Canvas Coords to Page Coords

```
pageX = containerRect.left + canvasX
pageY = containerRect.top + canvasY
```

## devicePixelRatio

If `devicePixelRatio > 1` (high-DPI display), the canvas internal resolution is scaled but CSS coordinates remain 1:1. Playwright's `page.mouse.click()` uses CSS pixels. The `canvasX/canvasY` values above are CSS pixels.

Check with:
```javascript
() => window.devicePixelRatio
```

## Dispatching Click Events

ECharts listens for native DOM events on the canvas. Use `dispatchEvent` with correct `clientX/clientY` (page-level) and `offsetX/offsetY` (canvas-relative):

```javascript
function clickCanvas(canvasElement, canvasX, canvasY) {
  const rect = canvasElement.getBoundingClientRect();
  const clientX = rect.left + canvasX;
  const clientY = rect.top + canvasY;

  for (const type of ['mousedown', 'mouseup', 'click']) {
    canvasElement.dispatchEvent(new MouseEvent(type, {
      bubbles: true,
      cancelable: true,
      view: window,
      clientX,
      clientY,
      offsetX: canvasX,
      offsetY: canvasY,
    }));
  }
}
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Click doesn't register | Wrong coordinates | Take screenshot, verify cursor position visually |
| Legend click no effect | Clicking gap between items | Adjust X by ±20px |
| Y-axis label click no effect | `triggerEvent` not set, or clicking outside text bbox | Verify `triggerEvent: true` in code; move X closer to text |
| Click works in browser but not Playwright | Using `page.mouse.click()` instead of `dispatchEvent` | Use `dispatchEvent` approach for canvas elements |
| Coordinates off on retina display | devicePixelRatio mismatch | Verify `devicePixelRatio === 1`, or scale coordinates |
