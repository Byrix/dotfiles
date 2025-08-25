return {
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
