-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Sets the leader key. Must happen before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disables the Netrw file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Re-reads the file if it has been changed outside of Vim
vim.o.autoread = true

-- Very long wrapped lines will be visually indented
vim.o.breakindent = true

-- Sync clipboard between OS and Vim
-- Schedule the setting after UiEnter because it can increase startup-time
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Case-insensitive searching unless \C or one or more capitall letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Text replacement appears live as you type
vim.o.inccommand = 'split'

-- Enable mouse mode and single line scrolling
vim.o.mouse = 'a'
vim.o.mousescroll = 'ver:1,hor:0'

-- Highlights the line your cursor is on
vim.o.cursorline = true

-- Shows line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Minimal number of lines to keep above/below cursor
vim.o.scrolloff = 10

-- Shows the current Vim mode
vim.o.showmode = true
vim.o.signcolumn = 'yes'

-- Enables undo/redo changes even after closing the file
vim.o.undofile = true

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- How long it takes to fire the CursorHold event, which is used by many plugins
vim.o.updatetime = 250

-- Time to input a sequence of keys
vim.o.timeoutlen = 300

-- Sets the border type for floating windows
vim.o.winborder = 'rounded'

-- Alternative file extension mappings
vim.filetype.add {
  extension = {
    gdshaderinc = 'gdshader',
  },
  filename = {
    Bogiefile = 'yaml',
  },
}

-- ============================================================
-- SECTION 2: DIAGNOSTIC
-- ============================================================

vim.diagnostic.config {
  severity_sort = true,
  float = { source = 'if_many', max_width = 60 },
  underline = false,
  -- Shows a color on lines with a diagnostic
  signs = {
    text = { '', '', '', '' },
    linehl = { 'DiagnosticLineError', 'DiagnosticLineWarn', 'DiagnosticLineInfo', 'DiagnosticLineHint' },
  },
  virtual_text = { source = 'if_many', spacing = 2, prefix = '' },
}

-- Line highlight colors use the error colors. Runs after each colorscheme change
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    for _, s in ipairs { 'Error', 'Warn', 'Info', 'Hint' } do
      vim.api.nvim_set_hl(0, 'DiagnosticLine' .. s, { bg = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualText' .. s }).bg })
    end
  end,
})

-- Shows all diagnostics on the line when the cursor stops
vim.api.nvim_create_autocmd('CursorHold', {
  group = vim.api.nvim_create_augroup('diagnostic-float', { clear = true }),
  callback = function()
    -- Don't replace an info/signature float that's already open with a diagnostic
    local win = vim.b.lsp_floating_preview
    if win and vim.api.nvim_win_is_valid(win) then return end
    vim.diagnostic.open_float { scope = 'line', focus = false }
  end,
})

vim.keymap.set('n', '<leader>dn', ']d', { remap = true, desc = 'Diagnostic Next' })
vim.keymap.set('n', '<leader>dN', '[d', { remap = true, desc = 'Diagnostic Previous' })

-- ============================================================
-- SECTION 3: GENERAL KEYMAPS & AUTOCMDS
-- ============================================================

-- nohlsearch turns off highlighting from the last search
-- w saves to disk
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><cmd>w<CR>')
vim.keymap.set('n', '<leader>l', function() vim.o.relativenumber = not vim.o.relativenumber end, { desc = 'Toggle Relative Lines' })
vim.keymap.set('n', '<leader>rr', ':%s/', { desc = 'Replace' })
vim.keymap.set('n', '<leader>rc', ':%s/\\C', { desc = 'Replace (Case Sensitive)' })

-- Sets paste to paste and keep register intact
vim.keymap.set('v', 'p', 'P')

-- Flashes the line when you yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.hl_op() end,
})

-- ============================================================
-- SECTION 4: PLUGINS
-- ============================================================

-- This autocommand runs after a plugin is installed or updated and
-- runs the appropriate build command for that plugin if necessary
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end
  end,
})

-- Shorthand for the GitHub sources passed to vim.pack.add
local function gh(repo) return 'https://github.com/' .. repo end

-- Auto Save
-- Saves after the buffer has been modified
vim.pack.add { gh 'okuuva/auto-save.nvim' }
require('auto-save').setup {
  noautocmd = true, -- Keep this on to only format on manual save
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'AutoSaveWritePost',
  group = vim.api.nvim_create_augroup('autosave-notify', {}),
  callback = function(ev)
    if ev.data.saved_buffer ~= nil then vim.notify('Auto-saved at ' .. vim.fn.strftime '%I:%M:%S', vim.log.levels.INFO) end
  end,
})

-- Blink
-- Code auto-complete
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1' } }
require('blink.cmp').setup {
  signature = { enabled = true, trigger = { show_on_keyword = true } },
  keymap = {
    preset = 'super-tab',
  },
  completion = {
    menu = { border = 'none' },
  },
}

-- Fidget
-- Displays notifications and LSP loading messages in the bottom right
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

-- Gitsigns
-- Displays git symbols on left side bar and enables git hunk and blame features
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
local gitsigns = require 'gitsigns'

vim.keymap.set('n', '<leader>gi', function() gitsigns.preview_hunk_inline() end, { desc = 'Git Inline Preview' })
vim.keymap.set('n', '<leader>gr', function() gitsigns.reset_hunk() end, { desc = 'Git Reset Hunk' })
vim.keymap.set('n', '<leader>gb', function() gitsigns.blame_line() end, { desc = 'Git Blame Line' })
vim.keymap.set('n', '<leader>gn', function() gitsigns.nav_hunk 'next' end, { desc = 'Next Git Hunk' })
vim.keymap.set('n', '<leader>gN', function() gitsigns.nav_hunk 'prev' end, { desc = 'Prev Git Hunk' })

-- Git Conflict
-- Enables features for choosing git conflict changes
vim.pack.add { { src = gh 'akinsho/git-conflict.nvim', version = 'v2.1.0' } }
require('git-conflict').setup {
  default_mappings = false,
}

vim.keymap.set('n', '<leader>cc', '<Plug>(git-conflict-ours)', { desc = 'Conflict: Choose Current' })
vim.keymap.set('n', '<leader>ci', '<Plug>(git-conflict-theirs)', { desc = 'Conflict: Choose Incoming' })
vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)', { desc = 'Conflict: Choose Both' })
vim.keymap.set('n', '<leader>c0', '<Plug>(git-conflict-none)', { desc = 'Conflict: Choose None' })
vim.keymap.set('n', '<leader>cn', '<Plug>(git-conflict-next-conflict)', { desc = 'Conflict: Next' })
vim.keymap.set('n', '<leader>cN', '<Plug>(git-conflict-prev-conflict)', { desc = 'Conflict: Previous' })

-- Disables diagnostics inside the current buffer if there is a conflict to reduce error noise
vim.api.nvim_create_autocmd('User', {
  pattern = 'GitConflictDetected',
  callback = function() vim.diagnostic.enable(false, { bufnr = 0 }) end,
})

-- Enables diagnostics inside the current buffer if the conflicts are resolved
vim.api.nvim_create_autocmd('User', {
  pattern = 'GitConflictResolved',
  callback = function() vim.diagnostic.enable(true, { bufnr = 0 }) end,
})

-- Markdown Preview
-- Displays a markdown file in your web browser
vim.pack.add {
  gh 'selimacerbas/live-server.nvim',
  gh 'selimacerbas/markdown-preview.nvim',
}
require('live_server').setup {}
require('markdown_preview').setup {}

-- Only displays the Markdown Preview toggle if its a markdown file type
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  desc = 'Markdown preview toggle',
  callback = function(ev) vim.keymap.set('n', '<leader>m', '<cmd>MarkdownPreview<CR>', { buffer = ev.buf, desc = 'Markdown Preview' }) end,
})

-- Nord
vim.pack.add { gh 'gbprod/nord.nvim' }
require('nord').setup {
  transparent = true,
  on_colors = function(colors) colors.polar_night.origin = '#22262F' end,
  on_highlights = function(hl)
    hl['@comment'] = { fg = '#616e88', italic = false }
    hl.Comment = { fg = '#616e88', italic = false }
    hl['@property'] = { fg = '#88C0D0' }
    hl['@string'] = { fg = '#A3BE8C' }
    hl['@variable.parameter'] = { fg = '#D8DEE9' }
    hl.TabLineSel = { fg = '#D8DEE9', bg = '#22262F' }
    hl.TabLine = { fg = '#4C566A', bg = '#3B4252' }
    hl.TabLineFill = { bg = '#3B4252' }
    hl.GitSignsAddPreview = { bg = '#2a3d2e' }
    hl.GitSignsAddInline = { bg = '#3a5e42' }
    hl.GitSignsChangeInline = { bg = '#3a5e42' }
    hl.GitSignsDeleteVirtLn = { bg = '#3d2a2d' }
    hl.GitSignsDeleteVirtLnInLine = { bg = '#5e3a3a' }
    hl.DiffAdd = { bg = '#2a3d2e' }
    hl.DiffChange = { bg = '#2a3d2e' }
    hl.DiffDelete = { bg = '#3d2a2d' }
    hl.DiffText = { bg = '#5e3a3a' }
    hl.GitConflictCurrent = { bg = '#1d3b35' }
    hl.GitConflictIncoming = { bg = '#1d3557' }
    hl.GitConflictCurrentLabel = { bg = '#2d6b5e' }
    hl.GitConflictIncomingLabel = { bg = '#2d5080' }
    hl.Search = { bg = '#3B4252' }
    hl.CurSearch = { bg = '#616e88', fg = '#D8DEE9' }
    hl.IncSearch = { bg = '#616e88', fg = '#D8DEE9' }
    hl.SnacksPickerDirectory = { fg = '#D8DEE9' }
  end,
}
vim.cmd.colorscheme 'nord'

-- Snacks
-- A collection of small plugins
vim.pack.add { gh 'folke/snacks.nvim', gh 'nvim-tree/nvim-web-devicons' }
local snacks = require 'snacks'
snacks.setup {
  gitbrowse = {}, -- open files in GitHub
  explorer = {}, -- file tree
  image = {}, -- render images
  picker = { -- search tool
    sources = {
      explorer = {
        hidden = true, -- show dotfiles
        ignored = true, -- show gitignored files
        exclude = { '*.gd.uid', '*.tscn' },
        layout = { preset = 'default', preview = true }, -- float instead of sidebar
        jump = { close = true }, -- closes when you open a file
      },
    },
  },
  words = {}, -- highlight word you are hovering over
}

vim.keymap.set('n', '<leader>e', function() snacks.explorer { cwd = vim.fn.getcwd() } end, { desc = 'Explorer' })
vim.keymap.set('n', '<leader>sf', function() snacks.picker.files() end, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>sa', function() snacks.picker.grep { regex = false } end, { desc = 'Search in All Files' })
vim.keymap.set('n', '<leader>sr', function() snacks.picker.recent() end, { desc = 'Search Recent Files' })
vim.keymap.set('n', '<leader>gs', function() snacks.picker.git_status() end, { desc = 'Git Status' })
vim.keymap.set('n', '<leader>sd', function() snacks.picker.diagnostics() end, { desc = 'Search Diagnostics' })
vim.keymap.set('n', '<leader><leader>', function() snacks.picker.buffers() end, { desc = 'Buffers' })
vim.keymap.set('n', 'gd', function() snacks.picker.lsp_definitions() end, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gr', function() snacks.picker.lsp_references() end, { desc = 'References', nowait = true })
vim.keymap.set('n', '<leader>ss', function() snacks.picker.lsp_symbols() end, { desc = 'Search Symbols' })
vim.keymap.set('n', '<leader>go', function() snacks.gitbrowse.open() end, { desc = 'GitHub Open' })

-- Treesitter
-- Managers tree-sitter parsers which turn source code into an AST for syntax highlighting and code actions
vim.pack.add { gh 'nvim-treesitter/nvim-treesitter' }
require('nvim-treesitter').install {
  'bash',
  'css',
  'diff',
  'dockerfile',
  'gdshader',
  'gdscript',
  'go',
  'godot_resource',
  'gomod',
  'gosum',
  'gotmpl',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'regex',
  'scss',
  'typescript',
  'vim',
  'vimdoc',
  'vue',
  'yaml',
  'zsh',
}

-- Autocommand that starts treesitter for the currently opened file type
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Neoscroll
-- Enables a very smooth animation when scrolling
vim.pack.add { gh 'karb94/neoscroll.nvim' }
require('neoscroll').setup()

-- Scrollbar
-- Adds a scrollbar to the right side of the window
vim.pack.add { gh 'petertriho/nvim-scrollbar' }
require('scrollbar').setup {
  handlers = { gitsigns = true },
}

-- Spectre
-- Enables find and replace across multiple files
vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-pack/nvim-spectre',
}
require('spectre').setup {}

vim.keymap.set('n', '<leader>rf', function() require('spectre').toggle() end, { desc = 'Replace in Files' })

-- Which Key
-- Progressively displays keymaps as you type them
vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = {
    -- Turns off icons
    mappings = false,
    separator = '',
  },
  spec = {
    { '<leader>s', group = 'Search', mode = { 'n', 'v' } },
    { '<leader>g', group = 'Git' },
    { '<leader>d', group = 'Diagnostics' },
    { '<leader>c', group = 'Conflict' },
    { '<leader>r', group = 'Replace' },
  },
}

-- Sleuth
-- Auto indenting
vim.pack.add { gh 'tpope/vim-sleuth' }

-- Tmux Navigator
-- Enables seamless jumping between Vim and other tmux panes
vim.pack.add { gh 'christoomey/vim-tmux-navigator' }

-- Conform
-- Code formatter
vim.pack.add { gh 'stevearc/conform.nvim' }
local conform = require 'conform'
conform.setup {
  format_on_save = function() return { timeout_ms = 500, lsp_format = 'fallback' } end,
  formatters_by_ft = {
    bash = { 'shfmt' },
    gdscript = { 'gdscript-formatter' },
    gdshader = { 'clang-format' },
    go = { 'golines', 'goimports', 'gofumpt' },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    json = { 'prettierd', 'prettier', stop_after_first = true },
    lua = { 'stylua' },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
    sh = { 'shfmt' },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    vue = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
    zsh = { 'shfmt' },
  },
}

-- ============================================================
-- SECTION 5: LSP
-- Server configs, Mason, tool installation
-- ============================================================

-- This function gets executed every time a new file is opened that is associated with an LSP
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, { buffer = event.buf, desc = 'Rename' })
    vim.keymap.set({ 'n', 'x' }, '<leader>.', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'Code Actions' })
    vim.keymap.set('n', '<leader>i', function() vim.lsp.buf.hover { max_width = 60 } end, { buffer = event.buf, desc = 'Show Info' })
  end,
})

vim.pack.add { gh 'b0o/schemastore.nvim' }

local servers = {
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'standard',
        },
      },
    },
  },

  bashls = {
    filetypes = { 'sh', 'bash', 'zsh' },
  },

  gdscript = {
    cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(os.getenv 'GDScript_Port' or '6005')),
    filetypes = { 'gd', 'gdscript', 'gdscript3' },
    root_markers = { 'project.godot', '.git' },
  },

  -- https://github.com/Dead-Shrimp-Studio/gdshader-lsp-cpp
  gdshader = {
    cmd = { vim.fn.expand '~/.local/bin/gdshader-lsp', '--stdio' },
    filetypes = { 'gdshader' },
    root_markers = { 'project.godot', '.git' },
  },

  gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },

  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },

  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
  },

  vtsls = {
    filetypes = { 'typescript', 'javascript', 'vue' },
    settings = {
      vtsls = {
        autoUseWorkspaceTsdk = true,
        tsserver = {
          globalPlugins = {
            {
              name = '@vue/typescript-plugin',
              location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin',
              languages = { 'vue' },
              configNamespace = 'typescript',
              enableForWorkspaceTypeScriptVersions = true,
            },
          },
        },
      },
      typescript = {
        inlayHints = {
          parameterNames = { enabled = 'all' },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
      javascript = {
        inlayHints = {
          parameterNames = { enabled = 'all' },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },

  vue_ls = { init_options = { typescript = { tsdk = vim.fn.getcwd() .. '/node_modules/typescript/lib' } } },

  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = '' },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  },
}

-- Some LSPs/formatters are installed using the same binary, so this map helps with that
local mason_name = { ruff_fix = 'ruff', ruff_format = 'ruff', ruff_organize_imports = 'ruff' }

-- Builds a set of Mason package names by looking through the configured Conform formatters
local formatters = {}
for _, tools in pairs(conform.formatters_by_ft) do
  for _, tool in ipairs(tools) do
    if type(tool) == 'string' then formatters[mason_name[tool] or tool] = true end
  end
end

-- Prefers the system installed C language formatter
local prefer_system = { ['clang-format'] = true }

-- A list of LSPs that Mason should not install since they may be installed elsewhere
local skip = { gdscript = true, gdshader = true }

-- Builds the final list of formatters and LSPs to install
local ensure_installed = vim.tbl_filter(function(k) return not skip[k] end, vim.tbl_keys(servers or {}))
for tool in pairs(formatters) do
  if not (prefer_system[tool] and vim.fn.executable(tool) == 1) then table.insert(ensure_installed, tool) end
end

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {}
require('mason-lspconfig').setup {
  automatic_enable = false,
}
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
