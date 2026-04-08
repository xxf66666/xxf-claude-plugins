---
allowed-tools: mcp__plugin_playwright_playwright__browser_navigate, mcp__plugin_playwright_playwright__browser_resize, mcp__plugin_playwright_playwright__browser_take_screenshot, mcp__plugin_playwright_playwright__browser_snapshot, mcp__plugin_playwright_playwright__browser_evaluate, mcp__plugin_playwright_playwright__browser_run_code, mcp__plugin_playwright_playwright__browser_click, mcp__plugin_playwright_playwright__browser_wait_for, mcp__plugin_playwright_playwright__browser_tabs, Bash, Read, Write, Glob
description: Capture screenshots or record interaction videos of a web page using Playwright
user-invocable: true
---

Load the page-capture skill, then capture the target page.

User input: $ARGUMENTS

If no arguments provided, ask the user:
1. Target URL (e.g. http://localhost:3000/some-page)
2. Output directory
3. What to capture: screenshots, interaction video, or both
