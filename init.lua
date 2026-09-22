-- Plugins
vim.pack.add {
  'https://github.com/okuuva/auto-save.nvim',
  'https://github.com/gbprod/nord.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/petertriho/nvim-scrollbar',
  'https://github.com/nvim-pack/nvim-spectre',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/tpope/vim-sleuth',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/selimacerbas/live-server.nvim',
  'https://github.com/selimacerbas/markdown-preview.nvim',
  'https://github.com/mfussenegger/nvim-jdtls',
  'https://github.com/b0o/schemastore.nvim',
  'https://github.com/karb94/neoscroll.nvim',
  'https://github.com/ray-x/lsp_signature.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  { src = 'https://github.com/akinsho/git-conflict.nvim', version = 'v2.1.0' },
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1' },
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '3' },
}

require('auto-save').setup {
  enabled = true,
  noautocmd = true,
}

require('blink.cmp').setup {
  keymap = {
    preset = 'super-tab',
  },
  completion = {
    menu = { border = 'none' },
  },
}

require('fidget').setup {}

local gitsigns = require 'gitsigns'
gitsigns.setup {
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '━━' },
    topdelete = { text = '━━' },
    changedelete = { text = '▎' },
  },
}

require('git-conflict').setup {
  default_mappings = false,
}

require('lsp_signature').setup { hint_enable = false }

require('lualine').setup {
  options = {
    theme = 'nord',
    section_separators = '',
    component_separators = '',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { { 'filename', symbols = { modified = ' ●' } } },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}

-- Dependency of markdown_preview
require('live_server').setup {
  notify = false,
}

require('markdown_preview').setup {
  default_theme = 'dark',
}

require('mini.move').setup()

require('neoscroll').setup()

require('nord').setup {
  on_colors = function(colors) colors.polar_night.origin = '#22262F' end,
}

require('neo-tree').setup {
  default_component_configs = {
    git_status = {
      symbols = {
        added = 'A',
        deleted = 'D',
        modified = 'M',
        renamed = 'R',
        untracked = 'U',
        ignored = 'I',
        unstaged = '',
        staged = '',
        conflict = 'C',
      },
    },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
      never_show_by_pattern = { '*.gd.uid', '*.tscn' },
    },
    hijack_netrw_behavior = 'disabled',
  },
}

local ts_ensure_installed = {
  'bash',
  'diff',
  'gdscript',
  'godot_resource',
  'gdshader',
  'go',
  'gomod',
  'gosum',
  'gotmpl',
  'html',
  'java',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'vue',
  'yaml',
  'xml',
}
local ts_installed = require('nvim-treesitter.config').get_installed()
local ts_to_install = vim.iter(ts_ensure_installed):filter(function(parser) return not vim.tbl_contains(ts_installed, parser) end):totable()
require('nvim-treesitter').install(ts_to_install)

require('scrollbar').setup {
  handlers = { gitsigns = true },
}

require('spectre').setup()

local telescope = require 'telescope'
telescope.setup {
  defaults = {
    file_ignore_patterns = {
      '%.git/',
      'node_modules/',
      '%.DS_Store',
      '__pycache__/',
      '%.o',
      '%.zip',
      '%.tar%.gz',
      '%.jpg',
      '%.png',
      '%.gif',
      '%.pdf',
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
local pack_base = vim.fn.stdpath 'data' .. '/site/pack'
local fzf_paths = vim.fn.glob(pack_base .. '/*/opt/telescope-fzf-native.nvim', true, true)

for _, path in ipairs(fzf_paths) do
  local lib = path .. '/build/libfzf.so'
  if vim.fn.filereadable(lib) == 0 then
    vim.notify('Building telescope-fzf-native...', vim.log.levels.INFO)
    vim.fn.system { 'make', '-C', path }
  end
end
telescope.load_extension 'fzf'
telescope.load_extension 'ui-select'

require('which-key').setup {
  delay = 0,
  icons = {
    mappings = true,
    rules = false,
    separator = '',
  },
  spec = {
    { '<leader>s', group = 'Search', mode = { 'n', 'v' } },
    { '<leader>g', group = 'Git' },
    { '<leader>d', group = 'Split' },
    { '<leader>i', group = 'Info' },
    { '<leader>c', group = 'Conflict' },
    { '<leader>r', group = 'Replace' },
  },
}

-- Formatting
local conform = require 'conform'
conform.setup {
  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == 'java' then return false end
    return { timeout_ms = 2500, lsp_format = 'fallback' }
  end,
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

-- LSP
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

local mason_name = { ruff_fix = 'ruff', ruff_format = 'ruff', ruff_organize_imports = 'ruff' }
local formatters = {}
for _, tools in pairs(conform.formatters_by_ft) do
  for _, tool in ipairs(tools) do
    if type(tool) == 'string' then formatters[mason_name[tool] or tool] = true end
  end
end

local skip = { gdscript = true, gdshader = true }
local ensure_installed = vim.tbl_filter(function(k) return not skip[k] end, vim.tbl_keys(servers or {}))
local prefer_system = { ['clang-format'] = true }
for tool in pairs(formatters) do
  if not (prefer_system[tool] and vim.fn.executable(tool) == 1) then table.insert(ensure_installed, tool) end
end

require('mason').setup {}
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- Options
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.autoread = true
vim.o.breakindent = true
vim.o.cedit = ''
vim.o.clipboard = 'unnamedplus'
vim.o.confirm = true
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.inccommand = 'split'
vim.o.mouse = 'a'
vim.o.mousescroll = 'ver:1,hor:0'
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.winborder = 'rounded'
vim.filetype.add {
  extension = {
    gdshaderinc = 'gdshader',
  },
  filename = {
    Bogiefile = 'yaml',
  },
}

-- Colorscheme
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

-- Keymaps
---- General
function RestoreEsc() vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><cmd>checktime<CR><cmd>w<CR>') end
RestoreEsc()
vim.keymap.set({ 'n', 'i' }, '<F1>', '<Nop>')
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('n', '<leader>#', function() vim.o.relativenumber = not vim.o.relativenumber end, { desc = 'Toggle Relative Lines' })
vim.keymap.set('n', 'q', '<Nop>')
vim.keymap.set('n', '<C-q>', 'q')
vim.keymap.set('n', '<leader>rr', ':%s/', { desc = 'Replace' })
vim.keymap.set('n', '<leader>rc', ':%s/\\C', { desc = 'Replace (Case Sensitive)' })
vim.keymap.set('n', '<leader>rf', function() require('spectre').toggle() end, { desc = 'Replace in Files' })
vim.keymap.set('v', 'p', 'P')

---- Git Conflict
vim.keymap.set('n', '<leader>cc', '<Plug>(git-conflict-ours)', { desc = 'Conflict: Choose Current' })
vim.keymap.set('n', '<leader>ci', '<Plug>(git-conflict-theirs)', { desc = 'Conflict: Choose Incoming' })
vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)', { desc = 'Conflict: Choose Both' })
vim.keymap.set('n', '<leader>c0', '<Plug>(git-conflict-none)', { desc = 'Conflict: Choose None' })
vim.keymap.set('n', '<leader>cn', '<Plug>(git-conflict-next-conflict)', { desc = 'Conflict: Next' })
vim.keymap.set('n', '<leader>cN', '<Plug>(git-conflict-prev-conflict)', { desc = 'Conflict: Previous' })

---- Gitsigns
vim.keymap.set('n', '<leader>gr', function() gitsigns.reset_hunk() end, { desc = 'Git Reset Hunk' })
vim.keymap.set('n', '<leader>gb', function() gitsigns.blame_line() end, { desc = 'Git Blame Line' })
vim.keymap.set('n', '<leader>gn', function() gitsigns.nav_hunk 'next' end, { desc = 'Next Git Hunk' })
vim.keymap.set('n', '<leader>gN', function() gitsigns.nav_hunk 'prev' end, { desc = 'Prev Git Hunk' })

vim.keymap.set('n', '<leader>gD', function()
  gitsigns.diffthis()
  vim.keymap.set('n', '<Esc>', function()
    vim.cmd 'diffoff!'
    vim.cmd 'only'
    RestoreEsc()
  end, { desc = 'Close Diff' })
end, { desc = 'Git Diff' })

vim.keymap.set('n', '<leader>gi', function()
  gitsigns.preview_hunk_inline()
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_exec_autocmds('CursorMoved', { buffer = 0 })
    RestoreEsc()
  end, { desc = 'Dismiss Preview' })
end, { desc = 'Git Preview Inline' })

---- NeoTree
vim.keymap.set(
  'n',
  '<leader>e',
  function()
    require('neo-tree.command').execute {
      action = 'focus',
      source = 'filesystem',
      position = 'float',
      reveal = true,
      dir = vim.fn.getcwd(),
    }
  end,
  { desc = 'Explorer' }
)

---- Telescope
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>sa', builtin.live_grep, { desc = 'Search in All Files' })
vim.keymap.set('n', '<leader>sr', builtin.oldfiles, { desc = 'Search Recent Files' })
vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = 'Search Symbols' })
vim.keymap.set('n', '<leader>sg', builtin.git_status, { desc = 'Search Git Changes' })

-- Autocmds
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local auto_reload = vim.api.nvim_create_augroup('auto-reload', { clear = true })
local function check_file_changed()
  if vim.fn.mode() == 'n' and vim.bo.buftype == '' then vim.cmd 'silent! checktime' end
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' }, {
  desc = 'Reload buffers changed outside of Neovim',
  group = auto_reload,
  callback = check_file_changed,
})

local reload_timer = vim.uv.new_timer()
if reload_timer then reload_timer:start(1000, 1000, vim.schedule_wrap(check_file_changed)) end

vim.api.nvim_create_autocmd('User', {
  pattern = 'AutoSaveWritePost',
  group = vim.api.nvim_create_augroup('autosave-notify', {}),
  callback = function(ev)
    if ev.data.saved_buffer ~= nil then vim.notify('Auto-saved at ' .. vim.fn.strftime '%I:%M:%S', vim.log.levels.INFO) end
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'GitConflictDetected',
  callback = function() vim.diagnostic.enable(false, { bufnr = vim.api.nvim_get_current_buf() }) end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'GitConflictResolved',
  callback = function() vim.diagnostic.enable(true, { bufnr = vim.api.nvim_get_current_buf() }) end,
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  desc = 'Markdown preview toggle',
  callback = function(ev)
    vim.keymap.set('n', '<leader>m', function()
      local mp = require 'markdown_preview'
      if mp._workspace_dir then
        mp.stop()
      else
        mp.start()
      end
    end, { buffer = ev.buf, desc = 'Markdown Preview' })
  end,
})

vim.api.nvim_create_autocmd({ 'CursorHold', 'DiagnosticChanged', 'InsertLeave' }, {
  callback = function(event)
    if event.event ~= 'InsertLeave' and vim.api.nvim_get_mode().mode:match 'i' then return end

    local line = vim.fn.line '.' - 1

    if event.event == 'CursorHold' then
      if vim.b._last_diag_line == line then return end
      vim.b._last_diag_line = line
    end

    local diagnostics = vim.diagnostic.get(0, { lnum = line })

    if #diagnostics > 0 then vim.diagnostic.open_float(nil, { focus = false }) end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = event.buf, desc = 'Go to Definition' })
    vim.keymap.set('n', 'gD', builtin.lsp_references, { buffer = event.buf, desc = 'Go to Declaration' })
    vim.keymap.set('n', '<leader><F2>', vim.lsp.buf.rename, { buffer = event.buf, desc = 'Rename' })
    vim.keymap.set({ 'n', 'x' }, '<leader>.', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'Code Actions' })
    vim.keymap.set('n', '<leader>i', function() vim.lsp.buf.hover { max_width = 60 } end, { buffer = event.buf, desc = 'Show Info' })

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

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

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local jdtls = require 'jdtls'
    local jdtls_setup = require 'jdtls.setup'
    local root_dir = jdtls_setup.find_root {
      '.git',
      'mvnw',
      'gradlew',
      'pom.xml',
      'build.gradle',
      'settings.gradle',
    }

    if not root_dir then return end

    local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name
    local java_home = vim.env.JDTLS_JAVA_HOME or vim.env.JAVA_HOME

    local config = {
      cmd = {
        vim.fn.stdpath 'data' .. '/mason/packages/jdtls/bin/jdtls',
        '--java-executable',
        java_home .. '/bin/java',
        '-data',
        workspace_dir,
      },
      root_dir = root_dir,
      settings = {
        java = {},
      },
      init_options = {},
    }

    jdtls.start_or_attach(config)
  end,
})

-- Godot Server
local paths_to_check = { '/', '/../' }
local is_godot_project = false
local godot_project_path = ''
local cwd = vim.fn.getcwd()

for _, value in pairs(paths_to_check) do
  if vim.uv.fs_stat(cwd .. value .. 'project.godot') then
    is_godot_project = true
    godot_project_path = cwd .. value
    break
  end
end

if is_godot_project then
  local pipe = vim.fs.normalize(godot_project_path .. '/server.pipe')
  local ok, chan = pcall(vim.fn.sockconnect, 'pipe', pipe, { rpc = true })
  if ok and chan ~= 0 then
    pcall(vim.fn.chanclose, chan)
  else
    if vim.uv.fs_stat(pipe) then vim.uv.fs_unlink(pipe) end
    vim.fn.serverstart(pipe)
  end
end

-- Diagnostic
vim.diagnostic.config {
  severity_sort = true,
  float = { source = 'if_many', max_width = 60 },
  underline = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticLineError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticLineWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticLineInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticLineHint',
    },
  },
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    prefix = '',
    format = function(diagnostic)
      local win_width = vim.api.nvim_win_get_width(0)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local max_len = win_width - col - 15
      if max_len < 20 then max_len = 20 end
      local msg = diagnostic.message:gsub('\n', ' ')
      if #msg > max_len then return msg:sub(1, max_len - 3) .. '...' end
      return msg
    end,
  },
}

local function setup_diagnostic_highlights()
  local error_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextError' })
  local warn_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextWarn' })
  local info_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextInfo' })

  vim.api.nvim_set_hl(0, 'DiagnosticLineError', { bg = error_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticLineWarn', { bg = warn_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticLineInfo', { bg = info_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticLineHint', { bg = warn_hl.bg })
  vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint', { fg = warn_hl.fg, bg = warn_hl.bg })
end

vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_diagnostic_highlights })
setup_diagnostic_highlights()
