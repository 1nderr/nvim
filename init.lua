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

-- Hides the status bar at the bottom
vim.o.laststatus = 0

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
  callback = function() vim.diagnostic.open_float { scope = 'line', focus = false } end,
})

vim.keymap.set('n', '<leader>dn', ']d', { remap = true, desc = 'Diagnostic Next' })
vim.keymap.set('n', '<leader>dN', '[d', { remap = true, desc = 'Diagnostic Previous' })

-- ============================================================
-- SECTION 3: GENERAL KEYMAPS & AUTOCMDS
-- ============================================================

-- nohlsearch turns off highlighting from the last search
-- checktime checks if there buffer was modified outside of Vim
-- w saves to disk
function RestoreEsc() vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><cmd>checktime<CR><cmd>w<CR>') end
RestoreEsc()

vim.keymap.set('n', '<leader>l', function() vim.o.relativenumber = not vim.o.relativenumber end, { desc = 'Toggle Relative Lines' })
vim.keymap.set('n', '<leader>rr', ':%s/', { desc = 'Replace' })
vim.keymap.set('n', '<leader>rc', ':%s/\\C', { desc = 'Replace (Case Sensitive)' })

-- Sets paste to paste and keep register intact
vim.keymap.set('v', 'p', 'P')

-- Flashes the line when you yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Automatically reloads buffer if changes were made outside of Vim
local function check_file_changed()
  if vim.fn.mode() == 'n' and vim.bo.buftype == '' then vim.cmd 'silent! checktime' end
end

local reload_timer = vim.uv.new_timer()
if reload_timer then reload_timer:start(1000, 1000, vim.schedule_wrap(check_file_changed)) end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' }, {
  desc = 'Reload buffers changed outside of Neovim',
  group = vim.api.nvim_create_augroup('auto-reload', { clear = true }),
  callback = check_file_changed,
})

-- ============================================================
-- SECTION 4: PLUGINS
-- ============================================================

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- This autocommand runs after a plugin is installed or updated and
-- runs the appropriate build command for that plugin if necessary
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, ev.data.path)
      return
    end

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

-- Barbar
-- Tab bar
vim.pack.add { gh 'romgrk/barbar.nvim', gh 'nvim-tree/nvim-web-devicons' }
require('barbar').setup {}

-- Blink
-- Code auto-complete
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1' } }
require('blink.cmp').setup {
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

-- LSP Signature
-- Displays the function signature as you type the function out
vim.pack.add { gh 'ray-x/lsp_signature.nvim' }
require('lsp_signature').setup {
  hint_enable = false,
}

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

-- Neoscroll
-- Enables a very smooth animation when scrolling
vim.pack.add { gh 'karb94/neoscroll.nvim' }
require('neoscroll').setup()

-- Nord
vim.pack.add { gh 'gbprod/nord.nvim' }
require('nord').setup {
  on_colors = function(colors) colors.polar_night.origin = '#22262F' end,
}

vim.cmd.colorscheme 'nord'
vim.api.nvim_set_hl(0, '@comment', { fg = '#616e88', italic = false })
vim.api.nvim_set_hl(0, 'Comment', { fg = '#616e88', italic = false })
vim.api.nvim_set_hl(0, '@property', { fg = '#88C0D0' })
vim.api.nvim_set_hl(0, '@string', { fg = '#A3BE8C' })
vim.api.nvim_set_hl(0, '@variable.parameter', { fg = '#D8DEE9' })
vim.api.nvim_set_hl(0, 'TabLineSel', { fg = '#D8DEE9', bg = '#22262F' })
vim.api.nvim_set_hl(0, 'TabLine', { fg = '#4C566A', bg = '#3B4252' })
vim.api.nvim_set_hl(0, 'TabLineFill', { bg = '#3B4252' })
vim.api.nvim_set_hl(0, 'GitSignsAddPreview', { bg = '#2a3d2e' })
vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = '#3a5e42' })
vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { bg = '#3a5e42' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteVirtLn', { bg = '#3d2a2d' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteVirtLnInLine', { bg = '#5e3a3a' })
vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#2a3d2e' })
vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2a3d2e' })
vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#3d2a2d' })
vim.api.nvim_set_hl(0, 'DiffText', { bg = '#5e3a3a' })
vim.api.nvim_set_hl(0, 'GitConflictCurrent', { bg = '#1d3b35' })
vim.api.nvim_set_hl(0, 'GitConflictIncoming', { bg = '#1d3557' })
vim.api.nvim_set_hl(0, 'GitConflictCurrentLabel', { bg = '#2d6b5e' })
vim.api.nvim_set_hl(0, 'GitConflictIncomingLabel', { bg = '#2d5080' })
vim.api.nvim_set_hl(0, 'Search', { bg = '#3B4252' })
vim.api.nvim_set_hl(0, 'CurSearch', { bg = '#616e88', fg = '#D8DEE9' })
vim.api.nvim_set_hl(0, 'IncSearch', { bg = '#616e88', fg = '#D8DEE9' })

-- NeoTree
-- Enables a file tree floating window for file navigation
vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-tree/nvim-web-devicons',
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '3' },
}
require('neo-tree').setup {
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
      never_show_by_pattern = { '*.gd.uid', '*.tscn' },
    },
  },
}

-- Runs the :Neotree command with the list of arguments
vim.keymap.set('n', '<leader>e', function()
  require('neo-tree.command').execute {
    action = 'focus',
    source = 'filesystem',
    position = 'float',

    -- Opens the tree at the currently open file
    reveal = true,

    -- Without this, the tree would open at the current file's dir. An issue when you are digging into underlying dependencies
    dir = vim.fn.getcwd(),
  }
end, { desc = 'Explorer' })

-- Treesitter
-- Managers tree-sitter parsers which turn source code into an AST for syntax highlighting and code actions
vim.pack.add { gh 'nvim-treesitter/nvim-treesitter' }
require('nvim-treesitter').install {
  'bash',
  'css',
  'csv',
  'diff',
  'dockerfile',
  'editorconfig',
  'gdscript',
  'gdshader',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'go',
  'godot_resource',
  'gomod',
  'gosum',
  'gotmpl',
  'html',
  'ini',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'printf',
  'python',
  'query',
  'regex',
  'requirements',
  'scss',
  'ssh_config',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'vue',
  'xml',
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

-- Telescope
-- Enables fzf search across an entire project
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
-- Since FZF native is written in C, we need to ensure that make is installed before attempting to install it
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end
vim.pack.add(telescope_plugins)

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      '%.git/',
      '%.gd%.uid$',
    },
    path_display = { 'smart' },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>sa', function() builtin.live_grep { additional_args = { '--fixed-strings' } } end, { desc = 'Search in All Files' })
vim.keymap.set('n', '<leader>sr', builtin.oldfiles, { desc = 'Search Recent Files' })
vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = 'Search Symbols' })
vim.keymap.set('n', '<leader>sg', builtin.git_status, { desc = 'Search Git Changes' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })

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
    { '<leader>i', group = 'Info' },
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
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = event.buf, desc = 'Go to Definition' })
    vim.keymap.set('n', 'gD', builtin.lsp_references, { buffer = event.buf, desc = 'Go to Declaration' })
    vim.keymap.set('n', '<leader><F2>', vim.lsp.buf.rename, { buffer = event.buf, desc = 'Rename' })
    vim.keymap.set({ 'n', 'x' }, '<leader>.', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'Code Actions' })
    vim.keymap.set('n', '<leader>i', function() vim.lsp.buf.hover { max_width = 60 } end, { buffer = event.buf, desc = 'Show Info' })

    -- The following autocommands are used to highlight references of the word
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

      -- If cursor is hovering over word, then highlight
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      -- If the cursor moves, then clear highlights
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      -- If the LSP detaches, then clear highlights
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end,
})

vim.pack.add { gh 'b0o/schemastore.nvim' }

local servers = {
  basedpyright = {},

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

-- Godot LSP setup
-- Paths to check for project.godot file in the parent directory
local paths_to_check = { '/', '/../' }
local is_godot_project = false
local godot_project_path = ''
local cwd = vim.fn.getcwd()

-- Iterate over paths and check
for _, value in pairs(paths_to_check) do
  if vim.uv.fs_stat(cwd .. value .. 'project.godot') then
    is_godot_project = true
    godot_project_path = cwd .. value
    break
  end
end

-- Check if server is already running in godot project path and then start the server
local is_server_running = vim.uv.fs_stat(godot_project_path .. '/server.pipe')
if is_godot_project and not is_server_running then vim.fn.serverstart(godot_project_path .. '/server.pipe') end
