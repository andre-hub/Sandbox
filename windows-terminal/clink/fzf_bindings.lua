-- fzf key bindings for clink 1.9
-- Ctrl+R : history search  → pastes selected command into prompt
-- Ctrl+T : file/folder search in cwd → pastes selected path into prompt

local fzf_exe = "fzf"
local hist_file = (os.getenv("LOCALAPPDATA") or "") .. "\\clink\\clink_history"

function fzf_history(rl_buffer)
    local tmp_out = os.getenv("TEMP") .. "\\clink_fzf_hist.txt"

    -- clink_history: skip internal marker lines starting with '|'
    local tmp_in = os.getenv("TEMP") .. "\\clink_fzf_hist_in.txt"
    local src = io.open(hist_file, "r")
    local dst = io.open(tmp_in, "w")
    if src and dst then
        for line in src:lines() do
            if line:sub(1,1) ~= "|" and #line > 0 then
                dst:write(line .. "\n")
            end
        end
        src:close()
        dst:close()
    end

    os.execute(string.format(
        'type "%s" | %s --tac --no-sort --prompt="history> " > "%s" 2>nul',
        tmp_in, fzf_exe, tmp_out
    ))

    local f = io.open(tmp_out, "r")
    if f then
        local sel = f:read("*l")
        f:close()
        if sel and #sel > 0 then
            rl_buffer:setline(sel)
        end
    end

    os.remove(tmp_in)
    os.remove(tmp_out)
    rl_buffer:refreshline()
end

function fzf_files(rl_buffer)
    local tmp_out = os.getenv("TEMP") .. "\\clink_fzf_files.txt"

    os.execute(string.format(
        'dir /b /s . 2>nul | %s --prompt="files> " > "%s" 2>nul',
        fzf_exe, tmp_out
    ))

    local f = io.open(tmp_out, "r")
    if f then
        local sel = f:read("*l")
        f:close()
        if sel and #sel > 0 then
            rl_buffer:insert('"' .. sel .. '"')
        end
    end

    os.remove(tmp_out)
    rl_buffer:refreshline()
end

rl.setbinding("\\C-r", "luafunc:fzf_history")
rl.setbinding("\\C-t", "luafunc:fzf_files")

