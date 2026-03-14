# Neovim Keymaps Reference

> **Leader** = `Space`

---

## General

| Key | Action |
|-----|--------|
| `jk` | Escape insert mode |
| `;` | Open command mode (`:`) |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<C-S-p>` | Dotnet command palette |
| `-` | Oil: open parent directory |
| `J` (visual) | Move selection down |
| `K` (visual) | Move selection up |
| `<C-d>` / `<C-u>` | Scroll down / up (cursor centred) |
| `n` / `N` | Next / prev search result (centred) |

---

## LSP — Visual Studio Style

| Key | Action | Mode |
|-----|--------|------|
| `F12` | Go to definition | n, v |
| `Shift+F12` | Find all references | n, v |
| `Ctrl+F12` | Go to implementation | n, v |
| `F2` | Rename symbol | n, v |
| `Alt+.` | Code actions | n, v |
| `K` / `Ctrl+Space` | Hover docs | n, v |
| `Ctrl+Shift+Space` | Parameter info / signature help | n |
| `<leader>cf` | Format document / selection | n, v |
| `<leader>ci` | Toggle inlay hints | n |

---

## Diagnostics

| Key | Action |
|-----|--------|
| `F8` | Next diagnostic |
| `Shift+F8` | Prev diagnostic |
| `]d` / `[d` | Next / prev diagnostic |
| `<leader>cd` | Diagnostic float (current line) |
| `<leader>cD` | All diagnostics — buffer (Telescope) |
| `<leader>cE` | Errors — buffer (Telescope) |
| `<leader>cW` | Warnings — buffer (Telescope) |
| `<leader>cx` | All diagnostics — workspace (Telescope) |

---

## Debug (DAP) — Visual Studio Style

| Key | Action |
|-----|--------|
| `F5` | Continue / Start |
| `Shift+F5` | Stop / Terminate |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |

### Leader extras

| Key | Action | Mode |
|-----|--------|------|
| `<leader>dc` | Continue / Start | n |
| `<leader>dx` | Terminate | n |
| `<leader>dl` | Run last config | n |
| `<leader>dr` | Open REPL | n |
| `<leader>du` | Toggle DAP UI | n |
| `<leader>dw` | Watch expression | n, v |
| `<leader>dp` | Peek value under cursor | n, v |

### Breakpoints (`<leader>db`)

| Key | Action |
|-----|--------|
| `<leader>dbt` | Toggle breakpoint |
| `<leader>dbB` | Conditional breakpoint |
| `<leader>dbb` | List all (Telescope) |
| `<leader>dbq` | List all → quickfix |
| `<leader>dbc` | Clear all |

---

## Find / Telescope (`<leader>f`)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fo` | Recent files |
| `<leader>fh` | Help tags |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |
| `<leader>fz` | Zoxide frecent directories |

---

## Git (`<leader>g`)

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status (Fugitive) |
| `<leader>gc` | Git commit |
| `<leader>gP` | Git push |
| `<leader>gl` | Git log (oneline) |
| `<leader>gb` | Git blame |
| `<leader>gd` | Diffview open |
| `<leader>gD` | Diffview close |
| `<leader>gh` | File history (current file) |
| `<leader>gH` | Repo history |
| `]h` / `[h` | Next / prev git hunk |

---

## .NET (`<leader>n`)

### Build & Run

| Key | Action |
|-----|--------|
| `<leader>nb` | Build project |
| `<leader>nB` | Build solution |
| `<leader>nqb` | Build → quickfix |
| `<leader>nc` | Clean |
| `<leader>nR` | Restore packages |
| `<leader>nr` | Run project |
| `<leader>nrp` | Run with launch profile |
| `<leader>nw` | Watch / hot-reload |

### Test

| Key | Action |
|-----|--------|
| `<leader>nt` | Test project |
| `<leader>nts` | Test solution |
| `<leader>nT` | Test runner UI |

### NuGet (`<leader>np`)

| Key | Action |
|-----|--------|
| `<leader>npa` | Add package |
| `<leader>npr` | Remove package |
| `<leader>npo` | Outdated packages |
| `<leader>npv` | Project dependencies |

### Misc

| Key | Action |
|-----|--------|
| `<leader>nD` | Workspace diagnostics |
| `<leader>nS` | User secrets |

---

## Quickfix / Trouble (`<leader>x`)

| Key | Action |
|-----|--------|
| `<leader>xo` | Open quickfix |
| `<leader>xc` | Close quickfix |
| `]q` / `[q` | Next / prev item |
| `<leader>xx` | Trouble: workspace diagnostics |
| `<leader>xd` | Trouble: buffer diagnostics |
| `<leader>xs` | Trouble: symbols |
| `<leader>xl` | Trouble: LSP references / defs |
| `<leader>xq` | Trouble: quickfix list |

---

## Search & Replace — Spectre (`<leader>s`)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>sr` | Open Spectre | n |
| `<leader>sw` | Search word / selection | n, v |
| `<leader>sf` | Search in current file | n |

---

## Surround (mini.surround)

| Key | Action |
|-----|--------|
| `gsa` | Add surrounding |
| `gsd` | Delete surrounding |
| `gsr` | Replace surrounding |
| `gsf` / `gsF` | Find surrounding right / left |

> Example: cursor on word → `gsa"` wraps in quotes, `gsd"` removes, `gsr"'` changes `"` → `'`

---

## Flash (motion)

| Key | Action | Mode |
|-----|--------|------|
| `s` | Jump (type 2 chars) | n, v, o |
| `S` | Treesitter select | n, v, o |
| `r` | Remote flash | o |

---

## Oil (file manager)

| Key | Action |
|-----|--------|
| `-` | Open parent directory |
| `Enter` | Open file / enter directory |
| `Ctrl+s` | Open in vertical split |
| `Ctrl+p` | Preview file |
| `Ctrl+c` | Close Oil |
| `Ctrl+r` | Refresh |
| `g.` | Toggle hidden files |
| `g?` | Show help |
