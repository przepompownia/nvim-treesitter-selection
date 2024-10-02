local api = vim.api
local ts = vim.treesitter

local M = {}

-- Get a compatible vim range (1 index based) from a TS node range.
--
-- TS nodes start with 0 and the end col is ending exclusive.
-- They also treat a EOF/EOL char as a char ending in the first
-- col of the next row.
---comment
---@param range integer[]
---@param buf integer|nil
---@return integer, integer, integer, integer
function M.get_vim_range(range, buf)
  ---@type integer, integer, integer, integer
  local srow, scol, erow, ecol = unpack(range)
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1

  if ecol == 0 then
    -- Use the value of the last col of the previous row instead.
    erow = erow - 1
    if not buf or buf == 0 then
      ecol = vim.fn.col { erow, "$" } - 1
    else
      ecol = #api.nvim_buf_get_lines(buf, erow - 1, erow, false)[1]
    end
    ecol = math.max(ecol, 1)
  end
  return srow, scol, erow, ecol
end

-- Set visual selection to node
-- @param selection_mode One of "charwise" (default) or "v", "linewise" or "V",
--   "blockwise" or "<C-v>" (as a string with 5 characters or a single character)
function M.update_selection(buf, node, selection_mode)
  local start_row, start_col, end_row, end_col = M.get_vim_range({ ts.get_node_range(node) }, buf)

  local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
  selection_mode = selection_mode or "charwise"

  -- Normalise selection_mode
  if vim.tbl_contains(vim.tbl_keys(v_table), selection_mode) then
    selection_mode = v_table[selection_mode]
  end

  -- enter visual mode if normal or operator-pending (no) mode
  -- Why? According to https://learnvimscriptthehardway.stevelosh.com/chapters/15.html
  --   If your operator-pending mapping ends with some text visually selected, Vim will operate on that text.
  --   Otherwise, Vim will operate on the text between the original cursor position and the new position.
  local mode = api.nvim_get_mode()
  if mode.mode ~= selection_mode then
    -- Call to `nvim_replace_termcodes()` is needed for sending appropriate command to enter blockwise mode
    selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)
    api.nvim_cmd({ cmd = "normal", bang = true, args = { selection_mode } }, {})
  end

  api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
  vim.cmd "normal! o"
  api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

return M
