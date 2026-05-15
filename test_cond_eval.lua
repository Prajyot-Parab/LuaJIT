#!/usr/bin/env lua
-- Test DynASM conditional evaluation

-- Simulate the map_def with GPR64 defined
local map_def = {
  GPR64 = "1",
  P64 = "1",
  ELFV2 = "1"
}

-- Original cond_eval (broken)
local function cond_eval_old(cond)
  local func, err
  if setfenv then
    func, err = loadstring("return "..cond, "=expr")
  else
    -- No globals. All unknown identifiers evaluate to nil.
    func, err = load("return "..cond, "=expr", "t", {})
  end
  if func then
    if setfenv then
      setfenv(func, {}) -- No globals. All unknown identifiers evaluate to nil.
    end
    local ok, res = pcall(func)
    if ok then
      if res == 0 then return false end -- Oh well.
      return not not res
    end
    err = res
  end
  error("bad condition: "..err)
end

-- New cond_eval (fixed)
local function cond_eval_new(cond)
  local func, err
  -- Create environment with defines available as variables
  local env = {}
  for name, value in pairs(map_def) do
    -- Convert string "1" to boolean true, empty string to false
    if value == "1" or value == "true" then
      env[name] = true
    elseif value == "0" or value == "false" or value == "" then
      env[name] = false
    else
      -- Try to convert to number, otherwise keep as string
      local num = tonumber(value)
      env[name] = num or value
    end
  end
  
  if setfenv then
    func, err = loadstring("return "..cond, "=expr")
  else
    func, err = load("return "..cond, "=expr", "t", env)
  end
  if func then
    if setfenv then
      setfenv(func, env)
    end
    local ok, res = pcall(func)
    if ok then
      if res == 0 then return false end -- Oh well.
      return not not res
    end
    err = res
  end
  error("bad condition: "..err)
end

-- Test cases
local test_cases = {
  "GPR64",           -- After definesubst, this becomes "1"
  "1",               -- Direct value
  "P64",             -- Another define
  "GPR64 and P64",   -- Combined condition
  "not GPR64",       -- Negation
}

print("Testing conditional evaluation:")
print("================================")
for _, cond in ipairs(test_cases) do
  print("\nCondition: " .. cond)
  
  local ok_old, res_old = pcall(cond_eval_old, cond)
  print("  Old: " .. (ok_old and tostring(res_old) or "ERROR: " .. res_old))
  
  local ok_new, res_new = pcall(cond_eval_new, cond)
  print("  New: " .. (ok_new and tostring(res_new) or "ERROR: " .. res_new))
end

-- Made with Bob
