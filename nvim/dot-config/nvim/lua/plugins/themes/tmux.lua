return {
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
        surface0 = '#363a4f'
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
          read_only = '',
          modified = '󰏫',
          unnamed = '[?]',
          newfile = '',
        },
        format = {
          unix = '',
          dos = '',
          mac = '',
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

      -- Providers 
      local function lsp_client()
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

        return table.concat(clients,'')
      end
      local function git_branch()
        local gitsigns = vim.b.gitsigns_head
        local fugitive = vim.fn.exists("*FugitiveHead")==1 and vim.fn.FugitiveHead() or ""
        local branch = gitsigns or fugitive
        if branch == nil or branch=="" then
          return ICONS.git.branch
        else
          return ICONS.git.branch .. ' ' .. branch
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
      local function diagnostic_colour(level, colour)
        local count = #vim.diagnostic.get(0, { severity = level })
        return { fg=(count==0) and COLOURS.green or colour, bg='none', gui='bold' }
      end

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
          color = { fg=COLOURS.surface0, bg='NONE', gui='bold' },
          padding = { left=1, right=1 }
        }
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
              fmt = function(str)
                return str:sub(1,1)
              end,
              color = vi_colour(),
              padding = { left=1, right=0 }
            }
          },
          lualine_b = {
            sep(),
            {
              git_branch,
              color = get_colour(COLOURS.green),
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
              padding = { left=1, right=0 },
            }
          },
          lualine_c = {
            sep(),
            {
              'filetype',
              icon_only = true,
              colored = false,
              color = get_colour(COLOURS.blue),
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
              color = get_colour(COLOURS.blue),
              padding = { left=1, right=0 },
            },
            sep(),
            {
              lsp_client,
              color = get_colour(COLOURS.yellow),
              padding = { left=0, right=0 },
            },
          },
          lualine_x = {
            {
              'fileformat',
              color = get_colour(COLOURS.yellow),
              symbols = {
                unix=ICONS.format.unix,
                dos=ICONS.format.dos,
                mac=ICONS.format.mac,
              },
              padding = { left=0, right=0 },
            },
            {
              'encoding',
              color = get_colour(COLOURS.yellow),
              padding = { left=1, right=0 },
            },
            sep(),
            {
              file_size,
              color = get_colour(COLOURS.blue),
              padding = { left=0, right=0 },
            },
          },
          lualine_y = {
            sep(),
            {
              'diagnostics',
              sources = { 'nvim_diagnostic', 'coc' },
              sections = { 'error', 'warn', 'info' },
              diagnostics_color = {
                error = diagnostic_colour(vim.diagnostic.severity.ERROR, COLOURS.red),
                warn = diagnostic_colour(vim.diagnostic.severity.WARN, COLOURS.yellow),
                info = diagnostic_colour(vim.diagnostic.severity.INFO, COLOURS.teal),
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
          },
          lualine_z = {
            sep(),
            {
              'progress',
              color = get_colour(COLOURS.red),
              padding = { left=0, right=0 },
            },
            {
              'location',
              color = get_colour(COLOURS.red),
              padding = { left=1, right=0 }
            },
          },
        }
      })
    end,
  }
}
