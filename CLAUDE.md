# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Repository-wide guidance (commands, architecture, conventions) lives in
[`AGENT.md`](AGENT.md) — it's written to be tool-agnostic so it applies equally to Claude Code
and other AI agents. Read it before making changes here.

Deeper architectural detail (the tagging engine's range bookkeeping, IME/marked-text handling,
SwiftUI↔UIKit sync) is in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), linked from `AGENT.md`.

This project also has a Serena project index (`.serena/`) with memories covering the same ground
in a denser, agent-oriented form (`core`, `tech_stack`, `suggested_commands`, `conventions`,
`task_completion`, `tagging_engine`) — read those first if the Serena MCP tools are available in
this session.
