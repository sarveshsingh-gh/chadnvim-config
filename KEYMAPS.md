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
| `<C-d>` | Scroll down (cursor centred) |
| `<C-u>` | Scroll up (cursor centred) |
| `n` / `N` | Next/prev search result (cursor centred) |

---

## LSP

| Key | Action | Mode |
|-----|--------|------|
| `gd` / `<leader>/` | Go to definition | n, v |
| `gD` | Go to declaration | n, v |
| `gy` | Go to type definition | n, v |
| `gr` | References (Telescope) | n, v |
| `gR` | References → quickfix | n, v |
| `<F12>` / `<C-'>` | Go to implementation | n, v |
| `K` / `<C-Space>` | Hover docs | n, v |
| `<leader>rr` | Rename symbol | n, v |
| `<C-.>` / `<leader>.` | Code action (Telescope) | n, v |
| `<leader>cf` | Format document / selection | n, v |
| `<leader>cs` | Signature help | n |
| `<leader>ci` | Toggle inlay hints | n |
| `<leader>cd` | Diagnostic float | n |
| `<leader>cD` | All diagnostics — buffer (Telescope) | n |
| `<leader>cE` | Errors — buffer (Telescope) | n |
| `<leader>cW` | Warnings — buffer (Telescope) | n |
| `<leader>cx` | All diagnostics — workspace (Telescope) | n |

---

## Diagnostics Navigation

| Key | Action |
|-----|--------|
| `[d` / `]d` | Prev / next diagnostic |
| `[e` / `]e` | Prev / next error |
| `[w` / `]w` | Prev / next warning |

---

## Find / Telescope

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

## Git

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
| `[h` / `]h` | Prev / next git hunk (gitsigns) |

---

## Debug (DAP)

### F-key shortcuts (IDE-style)

| Key | Action |
|-----|--------|
| `<F5>` | Continue / Start |
| `<S-F5>` | Stop / Terminate |
| `<F9>` | Toggle breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F8>` | Step out |

### Leader shortcuts

| Key | Action | Mode |
|-----|--------|------|
| `<leader>dc` | Continue / Start | n |
| `<leader>dx` | Terminate session | n |
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
| `<leader>dbc` | Clear all breakpoints |

---

## .NET (`<leader>n`)

### Build

| Key | Action |
|-----|--------|
| `<leader>nb` | Build project |
| `<leader>nB` | Build solution |
| `<leader>nqb` | Build → quickfix |
| `<leader>nc` | Clean |
| `<leader>nR` | Restore packages |

### Run

| Key | Action |
|-----|--------|
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
| `]q` / `[q` | Next / prev quickfix item |
| `<leader>xx` | Trouble: workspace diagnostics |
| `<leader>xd` | Trouble: buffer diagnostics |
| `<leader>xs` | Trouble: symbols |
| `<leader>xl` | Trouble: LSP references / defs |
| `<leader>xq` | Trouble: quickfix list |

---

## Search & Replace — Spectre (`<leader>s`)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>sr` | Open Spectre (project replace) | n |
| `<leader>sw` | Search word under cursor | n, v |
| `<leader>sf` | Search in current file | n |

---

## Surround (mini.surround)

| Key | Action |
|-----|--------|
| `gsa` | Add surrounding |
| `gsd` | Delete surrounding |
| `gsr` | Replace surrounding |
| `gsf` | Find surrounding (right) |
| `gsF` | Find surrounding (left) |

> Example: `gsa"` wraps word in quotes, `gsd"` removes quotes, `gsr"'` changes `"` to `'`

---

## Flash (motion)

| Key | Action | Mode |
|-----|--------|------|
| `s` | Flash jump (type 2 chars) | n, v, o |
| `S` | Treesitter select | n, v, o |
| `r` | Remote flash | o |

---

## Oil (file manager)

| Key | Action |
|-----|--------|
| `-` | Open parent directory |
| `<CR>` | Open file / enter directory |
| `<C-s>` | Open in vertical split |
| `<C-p>` | Preview file |
| `<C-c>` | Close Oil |
| `<C-r>` | Refresh |
| `g.` | Toggle hidden files |
| `g?` | Show help |
