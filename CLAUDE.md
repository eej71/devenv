# devenv — Personal Dotfiles Repository

Dotfiles repo managed via stow-style symlinks. Each top-level directory (bash, emacs, git, tmux, terminal, etc.) contains config for that tool.

## Emacs Configuration

### Architecture

`emacs/.emacs.d/init.el` is the entry point. It:
1. Gates on required build features (`--with-native-compilation`, `--with-tree-sitter`, `--with-x`, `--with-rsvg`)
2. Bootstraps `straight.el` + `use-package` (straight is the sole package manager — built-in `package.el` is disabled in `early-init.el`)
3. Loads Org from straight before anything else can pull in built-in Org
4. Loads modular config from `lisp/` via `require`

### Lisp Modules (`emacs/.emacs.d/lisp/`)

Loaded in this order (dependencies flow top-down):

| Module | Purpose |
|---|---|
| `editor-utilities.el` | Utility functions (`eej/prog-mode-setup`, vterm, resize hydra) |
| `ui-chrome.el` | Theme + modeline loading, windmove, ace-window, which-key |
| `completion-framework.el` | Vertico, consult, orderless, marginalia, embark |
| `programming-modes.el` | Tree-sitter, corfu, flymake, rainbow-delimiters, clang-format |
| `version-control.el` | Magit, project.el, git worktree commands |
| `power-user-tools.el` | Avy, expand-region, multiple-cursors, undo-tree, diff-hl, helpful, symbol-overlay |
| `copilot-chat-custom.el` | Copilot Chat persistence, metadata injection, org-id integration |
| `ai-tools.el` | Copilot, gptel, claude-code-ide, minuet, compose buffer |
| `org-custom.el` | Org mode, org-jira, capture templates, agenda, clock |

### Spectral Theme (`emacs/.emacs.d/spectral-theme.el`)

Custom dark theme with an extensive hand-built color palette.

**Color palette naming:** `spectral-{hue}-{number}` where number 01 is lightest and 12 is darkest. Hues: red, orange, yellow, chartreuse, green, springgreen, cyan, azure, blue, violet, magenta, rose. Neutral ramps: `spectral-background-{00..32}` (00=black, 32=white) and `spectral-foreground-{00..32}` (00=white, 32=black — inverted from background). Some hues have extra entries (e.g., `spectral-yellow-00`, `spectral-yellow-00a`, `spectral-yellow-00b`, `spectral-green-tictac-green`, `spectral-azure-00`).

**Per-project modeline coloring:** `eej/modify-modeline-face` in the theme file hashes the project root + hostname to pick a unique foreground/background color pair for `spectral-modeline-project-branch-face` via `face-remap-add-relative`. Runs on `find-file-hook`.

**Face categories defined:**
- Font-lock faces (comment, string, keyword, type, function-name/call, variable-name/use, etc.)
- Modeline faces (`spectral-modeline-*-face`) — used by `modeline.el`
- Org faces (levels, todo keyword faces like `org-todo-todo`, `org-todo-started`, etc.)
- Magit faces (extensive: diff, blame, log, branch, reflog, sequence, bisect)
- Completion UI faces (vertico, orderless, consult, marginalia)
- Rainbow-delimiters faces (7 depth levels)
- Misc: isearch, show-paren, whitespace, compilation, diff, dired, flymake, ack

### Custom Modeline (`emacs/.emacs.d/modeline.el`)

Fully custom `mode-line-format` — not doom-modeline or powerline. Uses a single top-level `(:eval ...)` that dispatches to `spectral-modeline-format-active` or `spectral-modeline-format-inactive` based on `mode-line-window-selected-p`.

**Segments:** kbd-macro indicator, narrow indicator, buffer position (% with modified/saved coloring), read-only state, `{project:branch}`, filename (relative to project root), org clock task, right-aligned ace-window path, flymake counters.

Also sets a `header-line-format` that shows the filename with blue/grey background for active/inactive windows.

All `:eval` constructs are marked `risky-local-variable` to enable evaluation.

### Naming Conventions

- `spectral-*` — theme and modeline functions/faces (the "brand")
- `eej/*` or `eej-*` — personal utility functions and keymaps
- Active/inactive pattern: most modeline segments have paired `-active`/`-inactive` vars, though the active boolean parameter is mostly unused now that `mode-line-window-selected-p` handles dispatch

### Key Bindings Prefix Map

| Prefix | Map | Purpose |
|---|---|---|
| `C-c i` | `eej-ai-map` | AI tools (gptel, claude-code-ide, copilot-chat, codex, auto-suggest toggle) |
| `C-c s` | `eej-consult` | Search (consult-find, grep, ripgrep, line) |
| `C-c j` | `eej-avy-map` | Jump (avy-goto-char, word, line) |
| `C-c w` | `eej-worktree-map` | Git worktrees (create, switch, remove) |
| `C-c m` | — | Multiple cursors |
| `C-c g` | — | Magit file dispatch |
| `C-c v` | — | Multi-vterm |

### Working With This Config

- Emacs is built from source with native-compilation and tree-sitter. Build instructions are in `init.el` header comments.
- Machine-specific config lives in `local/local-config.el` (symlinked into `.emacs.d/`), not tracked in this repo's lisp/ modules.
- The `.dir-locals.el` disables `emacs-lisp-checkdoc` for all elisp files under `.emacs.d/` since these are config, not library code.
- Org files live in `~/org/` (not in this repo). Scaffolding is auto-created by `org-custom.el`.
