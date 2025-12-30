-- ~/.config/nvim/lua/config/project_context_wizard.lua
-- 日本語・汎用 PROJECT_CONTEXT 作成ウィザード

local M = {}

-- ---- プロジェクトルート取得 ---------------------------------------------

local function state_file()
  return vim.fn.stdpath("state") .. "/copilot_context_root.txt"
end

local function read_root()
  if vim.g.copilot_context_root and vim.g.copilot_context_root ~= "" then
    return vim.g.copilot_context_root
  end
  local f = state_file()
  if vim.uv.fs_stat(f) then
    local lines = vim.fn.readfile(f)
    if lines and lines[1] and lines[1] ~= "" then
      vim.g.copilot_context_root = lines[1]
      return lines[1]
    end
  end
  return vim.loop.cwd()
end

local function joinpath(a, b)
  return (a:gsub("/+$", "")) .. "/" .. b
end

local function mkdir_p(dir)
  vim.fn.mkdir(dir, "p")
end

local function write_file(path, content)
  mkdir_p(vim.fn.fnamemodify(path, ":h"))
  vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
end

-- ---- UI ヘルパ ------------------------------------------------------------

local function ui_input(prompt, default, cb)
  vim.ui.input({ prompt = prompt, default = default or "" }, function(ans)
    if ans == nil then return cb(nil) end
    cb(vim.trim(ans))
  end)
end

local function ui_select(prompt, items, cb)
  vim.ui.select(items, { prompt = prompt }, function(choice)
    cb(choice)
  end)
end

-- 箇条書きを 1 項目ずつ入力
local function collect_list(title, item_prompt, cb, opts)
  opts = opts or {}
  local items = {}
  local done_label = opts.done_label or "完了"
  local allow_skip = opts.allow_skip ~= false

  local function loop()
    local choices = { "追加する", done_label }
    if allow_skip and #items == 0 then
      table.insert(choices, "スキップ")
    end
    ui_select(title, choices, function(choice)
      if choice == "追加する" then
        ui_input(item_prompt, "", function(v)
          if v and v ~= "" then table.insert(items, v) end
          loop()
        end)
      elseif choice == "スキップ" then
        cb({})
      else
        cb(items)
      end
    end)
  end

  loop()
end

local function bullets(items, fallback)
  if not items or #items == 0 then
    return { "- " .. (fallback or "(未定)") }
  end
  local out = {}
  for _, it in ipairs(items) do
    table.insert(out, "- " .. it)
  end
  return out
end

-- ---- メインウィザード -----------------------------------------------------

function M.run()
  local root = read_root()
  local out_path = joinpath(root, "docs/PROJECT_CONTEXT.md")

  local ctx = {}

  -- 1) プロジェクト種別
  ui_select("このプロジェクトは何ですか？", {
    "Webアプリ",
    "CLIツール",
    "ライブラリ / SDK",
    "研究・機械学習コード",
    "インフラ / DevOps",
    "ゲーム / グラフィックス",
    "その他・混在",
  }, function(project_type)
    ctx.project_type = project_type

    -- 2) 目的
    ui_input("このプロジェクトの目的（1〜2行で）", "", function(goal)
      ctx.goal = goal ~= "" and goal or "(未定)"

      -- 3) やらないこと
      collect_list("今回やらないこと（スコープ外）", "やらないこと：", function(non_goals)
        ctx.non_goals = non_goals

        -- 4) 変更の許容度
        ui_select("どこまで変更してよいですか？", {
          "最小差分のみ（大きな変更は禁止）",
          "振る舞いを変えないリファクタはOK",
          "大きな設計変更もOK（必ず事前確認）",
        }, function(change_policy)
          ctx.change_policy = change_policy

          -- 5) 優先度
          ui_select("何を一番重視しますか？", {
            "可読性・保守性",
            "安全性・正確性",
            "性能",
            "開発スピード",
            "バランス",
          }, function(priority)
            ctx.priority = priority

            -- 6) 使用技術（任意）
            collect_list("使用している技術（任意）", "例：TypeScript / Python / React", function(stack)
              ctx.stack = stack

              -- 7) 絶対に守るルール
              collect_list("絶対に守ってほしいルール（重要）", "ルール：", function(rules)
                ctx.rules = rules

                -- 8) 触ってはいけない場所
                collect_list("変更してはいけない場所（任意）", "例：自動生成コード / public API", function(no_touch)
                  ctx.no_touch = no_touch

                  -- 9) Copilotへの指示
                  ctx.copilot_rules = {
                    "docs/CODE_INDEX.md の責務分離を必ず守る",
                    "不明点があれば推測せず質問する",
                    "理由 → 手順 → 最小差分案 の順で回答する",
                    "大規模な変更は勝手に行わない",
                  }

                  collect_list("Copilotへの追加指示（任意）", "指示：", function(extra)
                    for _, e in ipairs(extra) do table.insert(ctx.copilot_rules, e) end

                    -- ---- Markdown生成 ----------------------------------

                    local lines = {}
                    table.insert(lines, "<!--")
                    table.insert(lines, "このファイルは人間向けドキュメントではありません。")
                    table.insert(lines, "Copilot に前提条件を伝えるための制約リストです。")
                    table.insert(lines, "完璧でなくてOK。いつでも更新してください。")
                    table.insert(lines, "-->")
                    table.insert(lines, "")
                    table.insert(lines, "# Project Context（Copilot用）")
                    table.insert(lines, "")

                    table.insert(lines, "## プロジェクト種別")
                    vim.list_extend(lines, bullets({ ctx.project_type }))
                    table.insert(lines, "")

                    table.insert(lines, "## 目的")
                    vim.list_extend(lines, bullets({ ctx.goal }))
                    table.insert(lines, "")

                    table.insert(lines, "## やらないこと（Non-goals）")
                    vim.list_extend(lines, bullets(ctx.non_goals, "(未定)"))
                    table.insert(lines, "")

                    table.insert(lines, "## 優先度・変更方針")
                    vim.list_extend(lines, bullets({
                      "優先度：" .. ctx.priority,
                      "変更方針：" .. ctx.change_policy,
                    }))
                    table.insert(lines, "")

                    table.insert(lines, "## 使用技術")
                    vim.list_extend(lines, bullets(ctx.stack, "(未定)"))
                    table.insert(lines, "")

                    table.insert(lines, "## 絶対に守るルール")
                    vim.list_extend(lines, bullets(ctx.rules, "(未定)"))
                    table.insert(lines, "")

                    table.insert(lines, "## 変更禁止エリア")
                    vim.list_extend(lines, bullets(ctx.no_touch, "(特になし)"))
                    table.insert(lines, "")

                    table.insert(lines, "## Copilotへの指示")
                    vim.list_extend(lines, bullets(ctx.copilot_rules))
                    table.insert(lines, "")

                    local content = table.concat(lines, "\n")

                    -- プレビュー
                    local buf = vim.api.nvim_create_buf(false, true)
                    vim.api.nvim_buf_set_name(buf, "PROJECT_CONTEXT_PREVIEW")
                    vim.bo[buf].filetype = "markdown"
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { plain = true }))
                    vim.cmd("vsplit")
                    vim.api.nvim_win_set_buf(0, buf)

                    ui_select("PROJECT_CONTEXT.md を保存しますか？", { "保存する", "キャンセル" }, function(choice)
                      if choice == "保存する" then
                        write_file(out_path, content)
                        vim.notify("保存しました: " .. out_path, vim.log.levels.INFO)
                        vim.cmd("edit " .. vim.fn.fnameescape(out_path))
                      else
                        vim.notify("キャンセルしました", vim.log.levels.WARN)
                      end
                    end)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

return M
