# Neovim Keymaps Reference

> **Leader** = `Space`
> **Cheatsheet group** = first word of each description (used by `:NvCheatsheet`)

---

## File

| Key | Action | Mode |
|-----|--------|------|
| `<leader>w` | File save | n |
| `<leader>q` | File quit | n |
| `-` | File open parent (Oil) | n |
| `<leader>?` | Which-key all keymaps (searchable) | n |

---

## Escape

| Key | Action | Mode |
|-----|--------|------|
| `jk` | Escape insert mode | i |

---

## Editor

| Key | Action | Mode |
|-----|--------|------|
| `;` | Editor command mode | n, v |
| `J` | Move selection down | v |
| `K` | Move selection up | v |
| `<C-d>` / `<C-u>` | Scroll down / up (cursor centred) | n |
| `n` / `N` | Next / prev search result (centred) | n |

---

## Lsp

Neovim 0.11+ standard (`gr*` style). `<leader>l` shows the full cheat-sheet in which-key.

| Key | Action | Mode |
|-----|--------|------|
| `grn` | Lsp rename | n |
| `gra` | Lsp code actions | n, v |
| `grA` | Lsp source actions (organize imports etc.) | n, v |
| `grd` | Lsp definition | n |
| `grr` | Lsp references (Telescope) | n |
| `gri` | Lsp implementation | n |
| `grt` | Lsp type definition | n |
| `grq` | Lsp diagnostic → quickfix | n |
| `K` | Lsp hover | n |
| `<C-k>` | Lsp signature help | i |
| `gO` | Lsp document symbols | n |
| `<leader>cf` | Lsp format | n, v |
| `<leader>ci` | Lsp inlay hints (toggle) | n |

---

## Diagnostic

| Key | Action | Mode |
|-----|--------|------|
| `F8` | Diagnostic next | n |
| `Shift+F8` | Diagnostic prev | n |
| `]d` / `[d` | Diagnostic next / prev | n |
| `]e` / `[e` | Diagnostic next error / prev error | n |
| `<leader>cd` | Diagnostic float (current line) | n |
| `<leader>cD` | Diagnostic buffer all (Telescope) | n |
| `<leader>cE` | Diagnostic buffer errors (Telescope) | n |
| `<leader>cW` | Diagnostic buffer warnings (Telescope) | n |
| `<leader>cx` | Diagnostic workspace all (Telescope) | n |

---

## Find (Telescope)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>ff` | Find files | n |
| `<leader>fg` | Find grep (live) | n |
| `<leader>fb` | Find buffers | n |
| `<leader>fo` | Find recent files | n |
| `<leader>fh` | Find help tags | n |
| `<leader>fs` | Find document symbols | n |
| `<leader>fS` | Find workspace symbols | n |
| `<leader>fz` | Find zoxide dirs | n |

---

## Git

| Key | Action | Mode |
|-----|--------|------|
| `<leader>gs` | Git status (Fugitive) | n |
| `<leader>gc` | Git commit | n |
| `<leader>gP` | Git push | n |
| `<leader>gl` | Git log | n |
| `<leader>gb` | Git blame | n |
| `<leader>gd` | Git diff view | n |
| `<leader>gD` | Git diff close | n |
| `<leader>gh` | Git file history (current file) | n |
| `<leader>gH` | Git repo history | n |
| `]h` / `[h` | Git hunk next / prev | n |

---

## Debug (DAP)

### F-key shortcuts

| Key | Action | Mode |
|-----|--------|------|
| `F5` | Debug continue | n |
| `Shift+F5` | Debug stop | n |
| `F9` | Debug breakpoint toggle | n |
| `F10` | Debug step over | n |
| `F11` | Debug step into | n |
| `Shift+F11` | Debug step out | n |

### Leader extras (`<leader>d`)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>dc` | Debug continue | n |
| `<leader>dx` | Debug terminate | n |
| `<leader>dl` | Debug run last | n |
| `<leader>dr` | Debug repl open | n |
| `<leader>du` | Debug ui toggle | n |
| `<leader>dw` | Debug watch expression | n, v |
| `<leader>dp` | Debug peek value | n, v |

### Breakpoints (`<leader>db`)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>dbt` | Debug breakpoint toggle | n |
| `<leader>dbB` | Debug breakpoint conditional | n |
| `<leader>dbb` | Debug breakpoints list (Telescope) | n |
| `<leader>dbq` | Debug breakpoints quickfix | n |
| `<leader>dbc` | Debug breakpoints clear | n |

---

## Dotnet

### Build & Run

| Key | Action | Mode |
|-----|--------|------|
| `<leader>nb` | Dotnet build project | n |
| `<leader>nB` | Dotnet build solution | n |
| `<leader>nqb` | Dotnet build quickfix | n |
| `<leader>nr` | Dotnet run project | n |
| `<leader>nrp` | Dotnet run profile | n |
| `<leader>nw` | Dotnet watch hot-reload | n |

### Test

| Key | Action | Mode |
|-----|--------|------|
| `<leader>nt` | Dotnet test project | n |
| `<leader>nts` | Dotnet test solution | n |
| `<leader>nT` | Dotnet test runner | n |

### Packages / NuGet (`<leader>np`)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>npa` | Dotnet package add | n |
| `<leader>npr` | Dotnet package remove | n |
| `<leader>npo` | Dotnet package outdated | n |
| `<leader>npv` | Dotnet package view | n |

### Misc

| Key | Action | Mode |
|-----|--------|------|
| `<leader>nc` | Dotnet clean project | n |
| `<leader>nR` | Dotnet restore packages | n |
| `<leader>nD` | Dotnet diagnostics workspace | n |
| `<leader>nS` | Dotnet secrets user | n |
| `<M-S-p>` | Dotnet command palette | n |

---

## Quickfix

| Key | Action | Mode |
|-----|--------|------|
| `<leader>xo` | Quickfix open | n |
| `<leader>xc` | Quickfix close | n |
| `]q` / `[q` | Quickfix next / prev | n |

---

## Search / Replace (Spectre)

| Key | Action | Mode |
|-----|--------|------|
| `<leader>sr` | Search toggle spectre | n |
| `<leader>sw` | Search current word | n |
| `<leader>sw` | Search selection | v |
| `<leader>sf` | Search in file | n |

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
