# Playwright Video Recording API

## Overview

Playwright supports video recording via browser contexts. Videos are saved as WebM files. This reference covers the API usage within Playwright MCP's `browser_run_code` tool.

## Setup

### Install ffmpeg for Playwright

Playwright requires its own ffmpeg binary (separate from system ffmpeg):

```bash
npx playwright install ffmpeg
```

Without this, `browser.newContext({ recordVideo: ... })` will throw an error about missing ffmpeg.

### Verify Installation

The binary is installed at:
```
%LOCALAPPDATA%\ms-playwright\ffmpeg-1011\ffmpeg-win64.exe   (Windows)
~/.cache/ms-playwright/ffmpeg-1011/ffmpeg-linux               (Linux)
~/Library/Caches/ms-playwright/ffmpeg-1011/ffmpeg-mac          (macOS)
```

## API Reference

### Creating a Recording Context

```javascript
const context = await browser.newContext({
  recordVideo: {
    dir: '/absolute/path/to/output/directory',  // Required
    size: { width: 1400, height: 900 }          // Optional, defaults to viewport
  }
});
```

- `dir` — Output directory (must exist). Videos are saved with random hash filenames.
- `size` — Video resolution. Should match viewport size for 1:1 pixel mapping.

### Getting the Video Path

```javascript
const videoPath = await page.video().path();
```

Returns the absolute path to the video file. Call this BEFORE closing the page.

### Finishing Recording

```javascript
await page.close();      // Stops recording, finalizes video file
await context.close();   // Cleans up context
```

The video file is only fully written after `page.close()`.

## Limitations

| Limitation | Details |
|-----------|---------|
| No cursor | Mouse cursor is not rendered in recordings |
| WebM only | Output format is always WebM (VP8 codec) |
| Random filenames | Files named `page@{hash}.webm` — rename after recording |
| No audio | Audio is not captured |
| Full viewport | Cannot record a specific element, only the full viewport |
| New context required | Cannot start recording on an existing context |
| No pause/resume | Recording runs continuously from context creation to page close |

## Workarounds

### No Cursor → Inject Fake Cursor

See SKILL.md "Visible Cursor Indicator" section. Inject a CSS div that follows mousemove events.

### WebM → GIF Conversion

If GIF output is needed, convert with system ffmpeg:

```bash
ffmpeg -i input.webm -vf "fps=15,scale=700:-1" -loop 0 output.gif
```

Parameters:
- `fps=15` — Frame rate (lower = smaller file)
- `scale=700:-1` — Width 700px, height proportional
- `-loop 0` — Loop forever

### WebM → MP4 Conversion

```bash
ffmpeg -i input.webm -c:v libx264 -preset fast -crf 23 output.mp4
```

### Random Filenames → Descriptive Names

Record the returned path, then rename:

```javascript
const videoPath = await page.video().path();
// After close:
// Use bash: mv "page@hash.webm" "descriptive-name.webm"
```

Or batch rename using the script in `scripts/rename-videos.sh`.

## Multiple Videos in One Session

Create a new context for each video. Each context = one video file:

```javascript
const results = [];

for (const scenario of scenarios) {
  const ctx = await browser.newContext({
    recordVideo: { dir: outputDir, size: { width: 1400, height: 900 } }
  });
  const pg = await ctx.newPage();
  await pg.setViewportSize({ width: 1400, height: 900 });

  // ... perform interactions ...

  results.push(await pg.video().path());
  await pg.close();
  await ctx.close();
}
```

## Timing Considerations

| Action | Recommended Wait |
|--------|-----------------|
| After page load | 1000-2000ms (for async rendering) |
| After mouse.move | 300-600ms (for cursor travel animation) |
| After click action | 1000-2000ms (for viewers to see result) |
| After scroll | 500-1000ms (for content to settle) |
| After chart interaction | 1500ms (for chart re-render) |
| Before close | 500ms (ensure last frame is captured) |

## Error Handling

### "Executable doesn't exist" Error

```
Error: browserContext.newPage: Executable doesn't exist at .../ffmpeg-win64.exe
```

Fix: `npx playwright install ffmpeg`

### "dir does not exist" Error

The output directory must exist before recording starts:

```bash
mkdir -p /path/to/output/dir
```

### Video File Empty or Corrupt

Ensure `page.close()` is called before accessing the video file. The video is finalized on close.

## Access Pattern in Playwright MCP

Since Playwright MCP runs code via `browser_run_code`, access the browser instance through the existing page:

```javascript
async (page) => {
  const context = page.context();
  const browser = context.browser();

  // Create recording context from browser
  const recordCtx = await browser.newContext({
    recordVideo: { dir: outputDir, size: { width: 1400, height: 900 } }
  });

  // ... record ...
}
```

Important: `require()` is not available in the Playwright MCP sandbox. Use only browser APIs.
