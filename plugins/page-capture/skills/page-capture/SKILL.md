---
name: page-capture
description: This skill should be used when the user asks to "take screenshots", "capture page", "record interaction video", "record a demo", "screenshot the page", "capture the UI", "record webm", "record gif of interactions", or needs to document a web page with screenshots and interaction recordings for requirement docs or demos.
---

# Page Capture — Screenshots & Interaction Recordings

Capture static screenshots and record interaction videos of web pages using Playwright MCP tools. Designed for documenting prototypes, generating requirement doc assets, and recording interactive demos.

## Prerequisites

- Playwright MCP server connected (plugin:playwright)
- Target page accessible via URL (dev server running)
- For video recording: Playwright ffmpeg installed (`npx playwright install ffmpeg`)

## Core Workflow

### 1. Prepare the Page

```
Navigate → Resize viewport → Collapse sidebars → Wait for render
```

- Use `browser_navigate` to go to the target URL
- Use `browser_resize` to set viewport to **1920x1080** (full HD, content fills the screen)
- Collapse sidebars or panels via `browser_evaluate` to maximize content area
- Wait 1-2 seconds for async content (charts, animations) to render

### 2. Take Screenshots

**Content-only screenshot (recommended)** — Crop to the content area, excluding sidebars, headers, and tab bars:

```javascript
// Step 1: Get content area bounding rect
const rect = await page.evaluate(() => {
  const el = document.querySelector('.content-area'); // Adjust selector
  const r = el.getBoundingClientRect();
  return { x: r.left, y: r.top, width: r.width, height: r.height };
});

// Step 2: Screenshot with clip
await page.screenshot({ path: 'output.png', clip: rect });
```

Use `browser_run_code` to execute both steps. This produces clean screenshots focused on the feature content.

**Full viewport screenshot** (includes all chrome):
```
browser_take_screenshot(type: "png", filename: "path/to/output.png")
```

**Scrolled sections** — To capture content below the fold:
```javascript
await page.evaluate(() => document.querySelector('.scroll-container').scrollTop = 700);
await page.waitForTimeout(500);
await page.screenshot({ path: 'section2.png', clip: rect }); // same clip rect
```
Repeat for each section.

**Element screenshot** — Capture a specific element by ref:
```
browser_take_screenshot(type: "png", element: "description", ref: "e123")
```

### 3. Record Interaction Videos

Video recording requires creating a new browser context with `recordVideo` enabled. Use `browser_run_code` to execute the full recording script.

#### Recording Script Structure

```javascript
async (page) => {
  const outputDir = '/absolute/path/to/output';
  const browser = page.context().browser();

  const ctx = await browser.newContext({
    recordVideo: { dir: outputDir, size: { width: 1920, height: 1080 } }
  });
  const p = await ctx.newPage();
  await p.setViewportSize({ width: 1920, height: 1080 });

  // --- Setup ---
  await p.goto('http://localhost:3000/target-page');
  await p.waitForTimeout(1000);
  injectCursor(p);  // See "Visible Cursor" section

  // --- Interactions ---
  await p.mouse.move(x, y);        // Show cursor movement
  await p.waitForTimeout(500);
  await p.mouse.click(x, y);       // Click
  await p.waitForTimeout(1500);     // Pause to show result

  // --- Finish ---
  const videoPath = await p.video().path();
  await p.close();
  await ctx.close();
  return videoPath;
}
```

#### Visible Cursor Indicator

Playwright recordings do not show the mouse cursor. Inject a red dot overlay that follows mouse events:

```javascript
function injectCursor(pg) {
  return pg.evaluate(() => {
    if (document.getElementById('fake-cursor')) return;
    const c = document.createElement('div');
    c.id = 'fake-cursor';
    c.style.cssText = `
      position:fixed; width:24px; height:24px; border-radius:50%;
      background:rgba(255,68,68,0.4); border:3px solid #ff4444;
      pointer-events:none; z-index:999999;
      transform:translate(-50%,-50%);
      transition:left 0.15s ease, top 0.15s ease;
      display:none;
    `;
    document.body.appendChild(c);
    document.addEventListener('mousemove', e => {
      c.style.display = 'block';
      c.style.left = e.clientX + 'px';
      c.style.top = e.clientY + 'px';
    });
  });
}
```

Always call `page.mouse.move(x, y)` before `page.mouse.click(x, y)` so the cursor visually travels to the click target.

### 4. Canvas/ECharts Click Handling

Standard `page.mouse.click()` may not trigger ECharts internal events (legend toggle, axis label clicks). Use `dispatchEvent` on the canvas element instead:

```javascript
function canvasClick(pg, canvasSelector, canvasX, canvasY) {
  return pg.evaluate(({sel, x, y}) => {
    const container = document.querySelector(sel);
    const canvas = container.querySelector('canvas');
    const r = canvas.getBoundingClientRect();
    const pageX = r.left + x, pageY = r.top + y;
    for (const type of ['mousedown', 'mouseup', 'click']) {
      canvas.dispatchEvent(new MouseEvent(type, {
        bubbles: true, cancelable: true, view: window,
        clientX: pageX, clientY: pageY,
        offsetX: x, offsetY: y,
      }));
    }
    // Move fake cursor to click position
    const fc = document.getElementById('fake-cursor');
    if (fc) {
      fc.style.display = 'block';
      fc.style.left = pageX + 'px';
      fc.style.top = pageY + 'px';
    }
  }, {sel: canvasSelector, x: canvasX, y: canvasY});
}
```

#### Coordinate Calculation for ECharts

To find click targets within an ECharts chart:

1. Get the container's bounding rect via `browser_evaluate`
2. Use the ECharts grid config (left, top, bottom, right) to compute the plot area
3. Calculate row positions: `y = gridTop + rowIndex * rowHeight + rowHeight/2`
4. Legend items are at `y ≈ 12` (canvas-relative), spread horizontally across center

```javascript
// Get chart position
() => {
  const el = document.querySelector('.chart-container');
  const r = el.getBoundingClientRect();
  return { left: r.left, top: r.top, width: r.width, height: r.height };
}
```

### 5. Output File Management

Playwright generates video filenames with random hashes. Rename them after recording:

```bash
mv "page@abc123.webm" "descriptive-name.webm"
```

Organize output into a structured directory:

```
screenshots/
├── 01-page-overview.png
├── 02-feature-section.png
├── 03-interaction-legend.webm
└── 04-interaction-scroll.webm
```

## Recording Best Practices

| Practice | Details |
|----------|---------|
| **Move before click** | Always `mouse.move()` then wait 300-600ms before clicking, so the cursor travel is visible |
| **Pause after action** | Wait 1000-2000ms after each interaction so viewers can see the result |
| **One interaction per video** | Keep each video focused on a single feature for clarity |
| **Scroll to show effects** | After hiding/toggling something, scroll to show downstream effects (e.g., density chart updates) |
| **Restore state** | End each video by restoring the original state (unhide, scroll back) |
| **Collapse sidebars** | Maximize content area before capture |
| **Wait for charts** | Wait 2000ms after page load for ECharts/async content to render |

## Common Patterns

### Multiple Videos in One Script

Record multiple videos sequentially within a single `browser_run_code` call to avoid repeated setup:

```javascript
async (page) => {
  const browser = page.context().browser();
  const results = [];

  for (const scenario of scenarios) {
    const ctx = await browser.newContext({
      recordVideo: { dir: outputDir, size: { width: 1920, height: 1080 } }
    });
    const p = await ctx.newPage();
    // ... setup and interactions ...
    results.push(await p.video().path());
    await p.close();
    await ctx.close();
  }

  return results.join('\n');
}
```

### Sidebar Collapse

```javascript
// Via JS evaluation (avoids coordinate guessing)
() => { document.querySelector('.sidebar-toggle-btn').click() }
```

### Scroll Capture Sequence

```javascript
const scrollPositions = [0, 700, 1400];
for (const pos of scrollPositions) {
  await pg.evaluate((s) => {
    document.querySelector('.scroll-container').scrollTop = s;
  }, pos);
  await pg.waitForTimeout(500);
  // Take screenshot at each position
}
```

## Embedding in Documents

Reference screenshots and videos in Markdown docs:

```markdown
**Screenshot:**
![Feature overview](screenshots/01-overview.png)

**Interaction demo:**
[Click to view demo](screenshots/02-interaction.webm)
```

## Additional Resources

### Reference Files

- **`references/echarts-coordinates.md`** — Detailed guide for computing ECharts canvas coordinates (grid layout, legend positions, axis label hit areas)
- **`references/playwright-video-api.md`** — Playwright video recording API details and limitations

### Scripts

- **`scripts/rename-videos.sh`** — Batch rename Playwright video files from hashes to descriptive names
