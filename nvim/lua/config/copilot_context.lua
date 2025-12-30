-- ~/.config/nvim/lua/config/copilot_context.lua
-- Ask CopilotChat with docs context (PROJECT_CONTEXT + CODE_INDEX)

local M = {}

local function state_file()
  return vim.fn.stdpath("state") .. "/copilot_context_root.txt"
end

local function read_state()
  local f = state_file()
  if vim.uv.fs_stat(f) then
    local lines = vim.fn.readfile(f)
    if lines and lines[1] and lines[1] ~= "" then
      return lines[1]
    end
  end
  return nil
end

local function write_state(path)
  vim.fn.mkdir(vim.fn.fnamemodify(state_file(), ":h"), "p")
  vim.fn.writefile({ path }, state_file())
end

local function normalize_dir(path)
  if not path or path == "" then return nil end
  path = vim.fn.expand(path)
  path = path:gsub("/+$", "")
  return path
end

local function file_exists(p)
  return vim.uv.fs_stat(p) ~= nil
end

local function read_file(p)
  local ok, lines = pcall(vim.fn.readfile, p)
  if not ok then return nil end
  return table.concat(lines, "\n")
end

local function ensure_root()
  if vim.g.copilot_context_root and vim.g.copilot_context_root ~= "" then
    return vim.g.copilot_context_root
  end
  local saved = read_state()
  if saved then
    vim.g.copilot_context_root = saved
    return saved
  end
  return nil
end

function M.set_root()
  vim.ui.input({
    prompt = "Copilot context root dir (project path): ",
    default = ensure_root() or vim.loop.cwd(),
    completion = "dir",
  }, function(input)
    local dir = normalize_dir(input)
    if not dir then return end
    if not vim.uv.fs_stat(dir) then
      vim.notify("Directory not found: " .. dir, vim.log.levels.ERROR)
      return
    end
    vim.g.copilot_context_root = dir
    write_state(dir)
    vim.notify("Copilot context root set: " .. dir, vim.log.levels.INFO)
  end)
end

local function build_context(root)
  local p1 = root .. "/docs/PROJECT_CONTEXT.md"
  local p2 = root .. "/docs/CODE_INDEX.md"

  local parts = {}
  table.insert(parts, "You must follow the project context below as the source of truth.")
  table.insert(parts, "")

  if file_exists(p1) then
    table.insert(parts, "## docs/PROJECT_CONTEXT.md")
    table.insert(parts, "```markdown")
    table.insert(parts, read_file(p1) or "")
    table.insert(parts, "```")
  else
    table.insert(parts, "## docs/PROJECT_CONTEXT.md (NOT FOUND)")
    table.insert(parts, "Expected: " .. p1)
  end

  table.insert(parts, "")

  if file_exists(p2) then
    table.insert(parts, "## docs/CODE_INDEX.md")
    table.insert(parts, "```markdown")
    table.insert(parts, read_file(p2) or "")
    table.insert(parts, "```")
  else
    table.insert(parts, "## docs/CODE_INDEX.md (NOT FOUND)")
    table.insert(parts, "Expected: " .. p2)
  end

  table.insert(parts, "")
  table.insert(parts, "When you answer, respect responsibilities, constraints, and naming conventions from these docs.")
  return table.concat(parts, "\n")
end

local function send_to_copilotchat(prompt)
  -- Preferred: use CopilotChat.nvim API if available
  local ok, chat = pcall(require, "CopilotChat")
  if ok and type(chat) == "table" and type(chat.ask) == "function" then
    -- Many setups support: require("CopilotChat").ask(prompt, opts)
    chat.ask(prompt, { selection = false })
    return true
  end

  -- Fallback: open chat and put prompt into clipboard
  vim.fn.setreg("+", prompt)
  vim.cmd("CopilotChat")
  vim.notify("Copied prompt to clipboard (+). Paste into CopilotChat and send.", vim.log.levels.WARN)
  return false
end

function M.ask_with_context(opts)
  opts = opts or {}
  local root = opts.root or ensure_root()
  if not root then
    vim.notify("Context root not set. Run :CopilotContextSet first.", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "Ask (with docs context): " }, function(q)
    if not q or q == "" then return end

    local ctx = build_context(root)
    local prompt = table.concat({
      ctx,
      "",
      "## Question",
      q,
    }, "\n")

    send_to_copilotchat(prompt)
  end)
end

-- --- Visual selection helper ----------------------------------------------



local function get_visual_selection()
  -- Visualモードの開始/終了位置

  local _, ls, cs = unpack(vim.fn.getpos("'<"))

  local _, le, ce = unpack(vim.fn.getpos("'>"))



  if ls == 0 or le == 0 then
    return nil
  end



  -- 行を取得（1-indexed）

  local lines = vim.fn.getline(ls, le)

  if not lines or #lines == 0 then
    return nil
  end



  -- 端の切り取り（同一行選択も対応）

  if #lines == 1 then
    lines[1] = string.sub(lines[1], cs, ce)
  else
    lines[1] = string.sub(lines[1], cs)

    lines[#lines] = string.sub(lines[#lines], 1, ce)
  end



  -- 空白だけなら無視

  local text = table.concat(lines, "\n")

  if text:gsub("%s+", "") == "" then
    return nil
  end

  return text
end



local function guess_lang_from_ft()
  local ft = vim.bo.filetype

  if not ft or ft == "" then return "" end

  -- markdown の fenced code の言語名にそのまま使う

  return ft
end



function M.ask_with_context_and_selection(opts)
  opts = opts or {}

  local root = opts.root or ensure_root()

  if not root then
    vim.notify("Context root not set. Run :CopilotContextSet first.", vim.log.levels.WARN)

    return
  end



  local sel = get_visual_selection()

  if not sel then
    vim.notify("No visual selection found. Select code in Visual mode and run again.", vim.log.levels.WARN)

    return
  end



  vim.ui.input({ prompt = "Ask (with docs + selection): " }, function(q)
    if not q or q == "" then return end



    local ctx = build_context(root)

    local lang = guess_lang_from_ft()

    local prompt = table.concat({

      ctx,

      "",

      "## Selected code",

      ("```%s"):format(lang),

      sel,

      "```",

      "",

      "## Question",

      q,

    }, "\n")



    send_to_copilotchat(prompt)
  end)
end

return M
