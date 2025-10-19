local M = {}

-- persistent state
local state = {
  floating = { buf = -1, win = -1 },
}

-- Create floating window
-- @params opts { width, height }
local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = (opts.buf and vim.api.nvim_buf_is_valid(opts.buf)) and opts.buf or vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  })

  return { buf = buf, win = win }
end

-- Toggle floating terminal
function M.toggle_terminal()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

-- Setup function
function M.setup()
  vim.api.nvim_create_user_command('Floaterminal', M.toggle_terminal, {})

  vim.keymap.set('n', '<leader>tt', M.toggle_terminal, { desc = 'Toggle floating terminal' })
  vim.keymap.set('n', '<leader>ts', function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd 'J'
    vim.api.nvim_win_set_height(0, 10)
  end, { desc = 'Open terminal split' })

  vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
    callback = function()
      vim.opt.number = false
      vim.opt.relativenumber = false
    end,
  })
end

return M
