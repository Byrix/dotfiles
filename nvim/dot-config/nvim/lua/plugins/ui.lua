return {
  -- telescope
  -- a nice seletion UI also to find and open files
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-dap.nvim' },
      {
        'byrix/telezot.nvim',
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

  { -- statusline
    -- PERF: I found this to slow down the editor
    'nvim-lualine/lualine.nvim',
    enabled = false,
    config = function()
      local function macro_recording()
        local reg = vim.fn.reg_recording()
        if reg == '' then
          return ''
        end
        return '📷[' .. reg .. ']'
      end

      ---@diagnostic disable-next-line: undefined-field
      require('lualine').setup {
        options = {
          section_separators = '',
          component_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode', macro_recording },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          -- lualine_b = {},
          lualine_c = { 'searchcount' },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        extensions = { 'nvim-tree' },
      }
    end,
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
    enabled = true,
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
    'feline-nvim/feline.nvim',
    enabled=true,
    dependencies = {
      'lewis6991/gitsigns.nvim'
    },
    config = function()
      local VIMODE_COLOURS = {
        ['NORMAL'] = 'blue',
        ['COMMAND'] = 'blue',
        ['INSERT'] = 'green',
        ['REPLACE'] = 'red',
        ['LINES'] = 'mauve',
        ['VISUAL'] = 'mauve',
        ['OP'] = 'yellow',
        ['BLOCK'] = 'yellow',
        ['V-REPLACE'] = 'yellow',
        ['ENTER'] = 'yellow',
        ['SELECT'] = 'yellow',
        ['MORE'] = 'yellow',
        ['SHELL'] = 'yellow',
        ['TERM'] = 'yellow',
        ['NONE'] = 'yellow',
      }
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
      }
      local ICONS = {
        files = {
          read_only = '',
        },
        git = {
          branch = '',
          diff_add = '',
          diff_mod = '',
          diff_rm = '',
          ignored = '',
        },
        lsp = {
          main = '',
          err = '',
          warn = '',
          info = '',
        },
      }

      function tableContains(table, value)
        for i= 1,#table do
          if (table[i]==value) then
            return true
          end
        end
        return false
      end

      -- Custom providers 
      function prov_time()
        return tostring(os.date("%H:%M"))
      end

      function lsp_client()
        local buff_id = vim.api.nvim_get_current_buf()
        local clients = {}

        for _, client in pairs(vim.lsp.get_clients({ bufnr=buff_id })) do
          local cname = client.name
          if tableContains(clients, cname) then
            goto continue
          elseif cname=='null-ls' then
            goto continue
          else
            clients[#clients+1] = cname
          end
          ::continue::
        end

        return table.concat(clients, ' ')
      end

      function prov_fileinfo(components, opts)
        local fileinf = require('feline.providers.file').file_info(components, opts)
        local git_ignored = false 

        if git_ignored then
          ignored_str = opts.file_ignored_icon or ICONS.git.ignored 
          fileinf = fileinf .. ' ' .. ignored_str
        end

        return fileinf
      end

      -- Utils 
      function sep(colour, side, direction, bg, show, icon)
        bg = bg or "bg"
        show = show or false
        icon = icon or nil
        local seperator = {}

        if direction=='up' then
          direction='_2'
        else
          direction=''
        end


        if side=='left' then
          table.insert(seperator, { str='slant_'..side..direction, hl={bg=bg, fg=colour}, always_visible=show })
          table.insert(seperator, { str=' ', hl={bg=colour, fg='NONE'} })
          if icon~=nil then
            table.insert(seperator, { str=icon, hl={bg=colour, fg='bg'} })
          end
        elseif side=='right' then
          if icon~=nil then
            table.insert(seperator, { str=icon, hl={bg=colour, fg='bg'} })
          end
          table.insert(seperator, { str=' ', hl={bg=colour, fg='NONE'} })
          table.insert(seperator, { str='slant_'..side..direction, hl={bg=bg, fg=colour}, always_visible=show })
        else
          table.insert(seperator, { str=' ', hl={bg=colour, fg='NONE'} })
        end

        return seperator
      end

      local comps = {
        vimode = {
          name = 'vi_mode',
          provider = {
            name = 'vi_mode',
            opts = {
              show_mode_name = true,
              padding = 'center',
            }
          },
          hl = function()
            vi_mode = require('feline.providers.vi_mode')
            return {
              -- name = vi_mode.get_mode_highlight_name(),
              bg = vi_mode.get_mode_color(),
              style = 'bold',
              fg = 'bg'
            }
          end,
          right_sep = 'slant_right',
          icon = '',
        },
        seperator = {
          provider = ''
        },
        cursor = {
          name = 'cursor',
          provider = {
            name = 'position',
            opts = { padding = false },
          },
          hl = { bg='overlay', fg='fg', },
          left_sep = sep('overlay', 'left'),
          right_sep = sep('overlay', 'right', 'up')
        },
        file_name = {
          name = 'file_name',
          provider = {
            name = 'file_info',
            opts = {
              type = 'relative',
              file_modified_icon = ICONS.git.diff_mod,
              file_readonly_icon = ICONS.files.read_only,
            }
          },
          hl = { bg='overlay', fg='fg' },
          right_sep = sep('overlay', 'right'),
          left_sep = sep('overlay', 'left'),
        },
        git_branch = {
          name = 'git_branch',
          provider = 'git_branch',
          hl = { bg='flamingo', fg='bg' },
          left_sep = sep('flamingo', 'left', 'up', 'bg', true),
          right_sep = sep('flamingo')
        },
        git_add = {
          name = 'git_added',
          provider = 'git_diff_added',
          hl = { bg = 'teal', fg = 'bg' },
          left_sep = sep('teal', 'left', 'up', 'flamingo', true),
          right_sep = sep('teal'),
          icon = ICONS.git.diff_add .. ' ',
        },
        git_mod = {
          name = 'git_modified',
          provider = 'git_diff_changed',
          hl = { bg = 'yellow', fg = 'bg' },
          left_sep = sep('yellow', 'left', 'up', 'teal', true),
          right_sep = sep('yellow'),
          icon = ICONS.git.diff_mod .. ' ',
        },
        git_rm = {
          name = 'git_removed',
          provider = 'git_diff_removed',
          hl = { bg = 'maroon', fg = 'bg' },
          left_sep = sep('maroon', 'left', 'up', 'yellow', true),
          right_sep = sep('maroon', 'right', 'down', 'bg', true),
          icon = ICONS.git.diff_rm .. ' ',
        },
        lsp_name = {
          name = 'lsp_client',
          provider = lsp_client,
          hl = { bg='flamingo', fg='bg' },
          right_sep = sep('flamingo', 'right', 'up', 'bg', true, ' ' .. ICONS.lsp.main),
          left_sep = sep('flamingo'),
        },
        lsp_info = {
          name = 'lsp_diagnositc_info',
          provider = 'diagnostic_info',
          hl = { bg='teal', fg='bg' },
          left_sep = sep('teal'),
          right_sep = sep('teal', 'right', 'up', 'flamingo', true, ' ' .. ICONS.lsp.info),
          icon = '',
        },
        lsp_warn = {
          name = 'lsp_diagnositc_warn',
          provider = 'diagnostic_warnings',
          hl = { bg='yellow', fg='bg' },
          left_sep = sep('yellow'),
          right_sep = sep('yellow', 'right', 'up', 'teal', true, ' ' .. ICONS.lsp.warn),
          icon = '',
        },
        lsp_err = {
          name = 'lsp_diagnositc_err',
          provider = 'diagnostic_errors',
          hl = { bg='maroon', fg='bg' },
          left_sep = sep('maroon', 'left', 'down', 'bg', true),
          right_sep = sep('maroon', 'right', 'up', 'yellow', true, ' ' .. ICONS.lsp.err),
          icon = '',
        },
        sys_time = {
          name = 'time',
          provider = prov_time,
          hl = { bg='overlay', fg='fg' },
          left_sep = sep('overlay', 'left'),
          right_sep = sep('overlay'),
        },
        word_count = {},
      }

      require('feline').setup({
        theme = COLOURS,
        vi_mode_colors = VIMODE_COLOURS,
        components = {
          active = {
            { -- left
              comps.vimode,
              comps.git_branch,
              comps.git_add,
              comps.git_mod,
              comps.git_rm,
              -- comps.seperator,
            },
            { -- center
              comps.file_name,
              -- comps.seperator,
            },
            { -- right 
              comps.lsp_err,
              comps.lsp_warn,
              comps.lsp_info,
              comps.lsp_name,
              comps.cursor,
              comps.sys_time
            }
          },
          inactive = {},
        }
      })
    end,
  }
}
