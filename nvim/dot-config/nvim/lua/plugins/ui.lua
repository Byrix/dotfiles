return {
  -- telescope
  -- a nice seletion UI also to find and open files
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-dap.nvim' },
      { 'byrix/telezot.nvim',
        enabled = true,
        dev = false,
        dependencies = {
          { 'kkharji/sqlite.lua' },
        },
        config = function()
          vim.keymap.set('n', '<leader>fz', ':Telescope zotero<cr>', { desc = '[z]otero' })
        end,
      },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local previewers = require 'telescope.previewers'
      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)
        vim.loop.fs_stat(filepath, function(_, stat)
          if not stat then
            return
          end
          if stat.size > 100000 then
            return
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end)
      end

      local telescope_config = require 'telescope.config'
      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
      -- I don't want to search in the `docs` directory (rendered quarto output).
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!docs/*')

      telescope.setup {
        defaults = {
          buffer_previewer_maker = new_maker,
          vimgrep_arguments = vimgrep_arguments,
          file_ignore_patterns = {
            'node_modules',
            '%_cache',
            '.git/',
            'site_libs',
            '.venv',
            'env',
            'presentation_files'
          },
          layout_strategy = 'flex',
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<esc>'] = actions.close,
              ['<c-j>'] = actions.move_selection_next,
              ['<c-k>'] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = false,
            find_command = {
              'rg',
              '--files',
              '--hidden',
              '--glob',
              '!.git/*',
              '--glob',
              '!**/.Rpro.user/*',
              '--glob',
              '!_site/*',
              '--glob',
              '!docs/**/*.html',
              '-L',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = 'smart_case',       -- or "ignore_case" or "respect_case"
          },
        },
      }
      telescope.load_extension 'fzf'
      telescope.load_extension 'ui-select'
      telescope.load_extension 'dap'
      telescope.load_extension 'zotero'
    end,
  },

  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { 
      signs = true,
    },
  },

  { -- edit the file system as a buffer
    'stevearc/oil.nvim',
    opts = {
      keymaps = {
        ['<C-s>'] = false,
        ['<C-h>'] = false,
        ['<C-l>'] = false,
      },
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-',          ':Oil<cr>', desc = 'oil' },
      { '<leader>ef', ':Oil<cr>', desc = 'edit [f]iles' },
    },
    cmd = 'Oil',
  },
  { -- nicer-looking tabs with close icons
    'nanozuki/tabby.nvim',
    enabled = false,
    config = function()
      require('tabby.tabline').use_preset 'tab_only'
    end,
  },

  { -- scrollbar
    'dstein64/nvim-scrollview',
    enabled = true,
    opts = {
      current_only = true,
    },
  },

  { -- highlight occurences of current word
    'RRethy/vim-illuminate',
    enabled = false,
  },

  {
    "NStefan002/screenkey.nvim",
    lazy = false,
  },
  { -- filetree
    'nvim-tree/nvim-tree.lua',
    enabled = true,
    keys = {
      { '<c-b>', ':NvimTreeToggle<cr>', desc = 'toggle nvim-tree' },
    },
    config = function()
      require('nvim-tree').setup {
        disable_netrw = true,
        update_focused_file = {
          enable = true,
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        diagnostics = {
          enable = true,
        },
      }
    end,
  },

  -- or a different filetree
  {
    'nvim-neo-tree/neo-tree.nvim',
    enabled = false,
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<c-b>', ':Neotree toggle<cr>', desc = 'toggle nvim-tree' },
    },
  },

  -- show keybinding help window
  {
    'folke/which-key.nvim',
    enabled = true,
    config = function()
      require('which-key').setup {}
      require 'config.keymap'
    end,
  },

  { -- show tree of symbols in the current file
    'hedyhli/outline.nvim',
    cmd = 'Outline',
    keys = {
      { '<leader>lo', ':Outline<cr>', desc = 'symbols outline' },
    },
    opts = {
      providers = {
        priority = { 'markdown', 'lsp',  'norg' },
        -- Configuration for each provider (3rd party providers are supported)
        lsp = {
          -- Lsp client names to ignore
          blacklist_clients = {},
        },
        markdown = {
          -- List of supported ft's to use the markdown provider
          filetypes = { 'markdown', 'quarto' },
        },
      },
    },
  },

  { -- or show symbols in the current file as breadcrumbs
    'Bekaboo/dropbar.nvim',
    enabled = function()
      return vim.fn.has 'nvim-0.10' == 1
    end,
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      -- turn off global option for windowline
      vim.opt.winbar = nil
      vim.keymap.set('n', '<leader>ls', require('dropbar.api').pick, { desc = '[s]ymbols' })
    end,
  },

  { -- terminal
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
    },
  },

  { -- show diagnostics list
    -- PERF: Slows down insert mode if open and there are many diagnostics
    'folke/trouble.nvim',
    enabled = false,
    config = function()
      local trouble = require 'trouble'
      trouble.setup {}
      local function next()
        trouble.next { skip_groups = true, jump = true }
      end
      local function previous()
        trouble.previous { skip_groups = true, jump = true }
      end
      vim.keymap.set('n', ']t', next, { desc = 'next [t]rouble item' })
      vim.keymap.set('n', '[t', previous, { desc = 'previous [t]rouble item' })
    end,
  },

  { -- show indent lines
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    main = 'ibl',
    opts = {
      indent = { char = '│' },
    },
  },

  { -- highlight markdown headings and code blocks etc.
    'lukas-reineke/headlines.nvim',
    enabled = false,
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('headlines').setup {
        quarto = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
          treesitter_language = 'markdown',
        },
        markdown = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
        },
      }
    end,
  },

  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = false,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    cond = function()
      -- Disable on Windows system
       return vim.fn.has 'win32' ~= 1 
    end,
    dependencies = {
       'leafo/magick', -- that's a lua rock
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt install lua5.1
      -- sudo apt install luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            -- only_render_image_at_cursor_mode = "popup",
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 30,
        kitty_method = 'normal',
      }

      local function clear_all_images()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images { buffer = bufnr }
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images { buffer = buf }
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = vim.api.nvim_create_buf(false, true)
        local win_width = vim.api.nvim_get_option_value('columns', {})
        local win_height = vim.api.nvim_get_option_value('lines', {})
        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          style = 'minimal',
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })
        vim.keymap.set('n', 'q', function()
          vim.api.nvim_win_close(win, true)
          img.global_state.options.max_height_window_percentage = og_max_height
        end, { buffer = buf })
        return { buf = buf, win = win }
      end

      local handle_zoom = function(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then
          return
        end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      vim.keymap.set('n', '<leader>io', function()
        local bufnr = vim.api.nvim_get_current_buf()
        handle_zoom(bufnr)
      end, { buffer = true, desc = 'image [o]pen' })

      vim.keymap.set('n', '<leader>ic', clear_all_images, { desc = 'image [c]lear' })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    enabled = true,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local COLOURS = {
        fg = '#cad3f5',
        bg = '#24273a',
        blue = '#8aadf4',
        red = '#ed8796',
        yellow = '#eed49f',
        orange = '#f5a97f',
        mauve = '#c6a0f6',
        flamingo = '#f0c6c6',
        green = '#a6da95',
        overlay = '#494d64',
        teal = '#8bd5ca',
        maroon = '#ee99a0',
        overlay0 = '#6e738d'
      }
      local VIMODE_COLOURS = {
        ['n'] = 'blue',
        ['c'] = 'blue',
        ['i'] = 'green',
        ['R'] = 'red',
        ['v'] = 'mauve',
        ['V'] = 'mauve',
      }
      local ICONS = {
        files = {
          read_only = ' ',
          modified = '󰏫 ',
          unnamed = '[?]',
          newfile = ' ',
        },
        format = {
          unix = '',
          dos = '',
          mac = '',
        },
        git = {
          branch = ' ',
          diff_add = ' ',
          diff_mod = ' ',
          diff_rm = ' ',
          ignored = ' ',
        },
        lsp = {
          main = ' ',
          err = ' ',
          warn = ' ',
          info = ' ',
        },
        loc = {
          buffer = ' ',
          location = ' ',
        },
      }

      -- Utils 
      local function tableContains(table, value)
        for i=1,#table do
          if (table[i]==value) then
            return true
          end
        end
        return false
      end
      local function sep()
        return {
          function()
            return "|"
          end,
          color = { fg=COLOURS.overlay, bg='NONE', gui='bold' },
          padding = { left=1, right=1 }
        }
      end
      local function diagnostic_colour(level, colour)
        local count = #vim.diagnostic.get(0, { severity = level })
        return { fg=(count==0) and COLOURS.green or colour, bg='none', gui='bold' }
      end
      local function vi_colour()
        local mode = vim.fn.mode():sub(1,1)
        local colour
        if tableContains(VIMODE_COLOURS, mode) then
          colour=VIMODE_COLOURS[mode]
        else
          colour=COLOURS.green
        end
        return { fg=colour, bg='none', gui='bold' }
      end
      local function get_colour(colour)
        return { fg=colour, bg='none', gui='bold' }
      end

      -- Providers 
      local function lsp_client()
        local buff_id = vim.api.nvim_get_current_buf()
        local clients = {}
        local active_clients = vim.lsp.get_clients({ bufnr=buff_id })

        for _,client in ipairs(active_clients) do
          local cname = client.name
          if tableContains(clients, cname) then
            -- clients[#clients+1] = 'E' .. cname
            goto continue
          elseif cname=='null-ls' then
            goto continue
          else
            clients[#clients+1] = cname
          end
          ::continue::
        end

        if #clients>0 then
          return table.concat(clients, ', ')
        else
          return "No LSP"
        end
      end

      local function git_branch()
        local gitsigns = vim.b.gitsigns_head
        local fugitive = vim.fn.exists("*FugitiveHead")==1 and vim.fn.FugitiveHead() or ""
        local branch = gitsigns or fugitive
        if branch == nil or branch=="" then
          return ICONS.git.branch
        else
          return ICONS.git.branch .. branch
        end
      end

      local function file_size()
        local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
        if size<0 then
          return '-'
        else
          if size < 1024 then
            return size..'B'
          elseif size < math.pow(1024, 2) then
            return string.format("%.1fK", size/1024)
          elseif size < math.pow(1024, 3) then
            return string.format("%.1fM", size/math.pow(1024,2))
          else
            return string.format("%.1G", size/math.pow(1024,3))
          end
        end
      end

      local function prov_buffer()
        local bufnr_list = vim.fn.getbufinfo({ buflisted = 1 })
        local total = #bufnr_list
        local current_bufnr = vim.api.nvim_get_current_buf()
        local current_index = 0

        for i,buf in ipairs(bufnr_list) do
          if buf.bufnr == current_bufnr then
            current_index = i
            break
          end
        end

        return string.format(ICONS.loc.buffer .. ' %d/%d', current_index, total)
      end

      require('lualine').setup({
        options = {
          section_separators = '',
          component_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              -- fmt = function(str)
              --   return str:sub(1,1)
              -- end,
              color = vi_colour(),
              padding = { left=1, right=0 }
            }
          },
          lualine_b = {
            sep(),
            {
              'filetype',
              icon_only = true,
              colored = false,
              color = get_colour(COLOURS.red),
              padding = { left=0, right=0 },
            },
            {
              'filename',
              file_status = true,
              path = 0,
              shorting_target = 20,
              symbols = {
                modified = ICONS.files.modified,
                readonly = ICONS.files.read_only,
                unnamed = '[?]',
                newfile = ICONS.files.newfile,
              },
              color = get_colour(COLOURS.red),
              padding = { left=0, right=0 },
            },
          },
          lualine_c = {
            sep(),
            {
              git_branch,
              color = get_colour(COLOURS.blue),
              padding = { left=0, right=0 },
            },
            {
              'diff',
              colored = true,
              diff_color = {
                added = { fg=COLOURS.teal, bg='none', gui='none' },
                modified = { fg=COLOURS.yellow, bg='none', gui='none' },
                removed = { fg=COLOURS.red, bg='none', gui='none' },
              },
              symbols = {
                added=ICONS.git.diff_add,
                modified=ICONS.git.diff_mod,
                removed=ICONS.git.diff_rm,
              },
              source = nil,
              padding = { left=2, right=0 },
            }
          },
          lualine_x = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic', 'coc' },
              sections = { 'error', 'warn', 'info' },
              diagnostics_color = {
                error = { fg=COLOURS.red, bg='none', gui='none' },
                warn = { fg=COLOURS.yellow, bg='none', gui='none' },
                info = { fg=COLOURS.teal, bg='none', gui='none' },
              },
              symbols = {
                error = ICONS.lsp.err,
                warn = ICONS.lsp.warn,
                info = ICONS.lsp.info,
              },
              colored = true,
              update_in_insert = true,
              padding = { left=0, right=0 },
            },
            {
              lsp_client,
              color = get_colour(COLOURS.blue),
              padding = { left=2, right=0 },
            },
          },
          lualine_y = {
            -- {
            --   'fileformat',
            --   color = get_colour(COLOURS.yellow),
            --   symbols = {
            --     unix=ICONS.format.unix,
            --     dos=ICONS.format.dos,
            --     mac=ICONS.format.mac,
            --   },
            --   padding = { left=0, right=0 },
            -- },
            -- {
            --   'encoding',
            --   color = get_colour(COLOURS.yellow),
            --   padding = { left=1, right=0 },
            -- },
            sep(),
            {
              file_size,
              color = get_colour(COLOURS.red),
              padding = { left=0, right=0 },
            },
          },
          lualine_z = {
            sep(),
            {
              prov_buffer,
              color = get_colour(COLOURS.green),
              padding = { left=0, right=0 },
            },
            {
              'progress',
              icon = ICONS.loc.location,
              icons_enabled = true,
              color = get_colour(COLOURS.green),
              padding = { left=2, right=0 },
            },
            {
              'location',
              color = get_colour(COLOURS.green),
              padding = { left=1, right=0 }
            },
          },
        }
      })
    end,
  }
}
