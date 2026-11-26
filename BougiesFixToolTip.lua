local locale = GetLocale and GetLocale() or "enUS"
local isFrench = locale == "frFR"
local isEnglish = locale == "enUS" or locale == "enGB"
local UPDATE_INTERVAL = 0.10

local function IsSecret(value)
    if issecretvalue and issecretvalue(value) then return true end
    if canaccessvalue and not canaccessvalue(value) then return true end
    return false
end

local function HasPluralTag(text)
    return text:find("%$[lL]") ~= nil
end

-- Validate grouping instead of silently removing arbitrary separators.
local function ParseInteger(value, group)
    if value:match("^%d+$") then return value end
    if not group then return nil end

    local first = value:find(group, 1, true)
    if not first then return nil end
    local head = value:sub(1, first - 1)
    if not head:match("^%d%d?%d?$") then return nil end

    local parts = { head }
    local start = first + 1
    while true do
        local nextGroup = value:find(group, start, true)
        local part = value:sub(start, nextGroup and nextGroup - 1 or -1)
        if not part:match("^%d%d%d$") then return nil end
        parts[#parts + 1] = part
        if not nextGroup then break end
        start = nextGroup + 1
    end
    return table.concat(parts)
end

local function ParseLocalizedNumber(token)
    -- The sign does not change the singular/plural decision.
    token = token:gsub("^[+-]", "")
    local decimal, group
    if isFrench then
        -- Accept a dot as an alternative decimal separator (custom servers).
        decimal = token:find(",", 1, true) and "," or "."
        group = " "
    elseif isEnglish then
        decimal = "."
        group = token:find(",", 1, true) and "," or " "
    else
        -- Conservative fallback for other locales; no full grammar support.
        if token:find(",", 1, true) and token:find(".", 1, true) then
            return nil
        end
        decimal = token:find(",", 1, true) and "," or "."
        group = " "
    end

    local integer, fraction = token, nil
    local at = token:find(decimal, 1, true)
    if at then
        integer = token:sub(1, at - 1)
        fraction = token:sub(at + 1)
        if not fraction:match("^%d+$") then return nil end
    end

    local digits = ParseInteger(integer, group)
    if not digits then return nil end
    local numeric = tonumber(fraction and (digits .. "." .. fraction) or digits)
    if not numeric or numeric == math.huge then return nil end
    return numeric
end

-- Examine only the text before a tag. Keep all original formatting in output.
local function NumberBeforeTag(prefix)
    prefix = prefix:gsub("|[cC]%x%x%x%x%x%x%x%x", "")
                   :gsub("|[rR]", "")
                   :gsub("\194\160", " ") -- U+00A0
                   :gsub("\226\128\175", " ") -- U+202F
                   :gsub("[ \t]+$", "")
    prefix = prefix:gsub("%%[ \t]*$", ""):gsub("[ \t]+$", "")

    local start, _, token = prefix:find("([+-]?%d[%d., ]*)$")
    if not token then return nil end
    -- Do not interpret a suffix of another malformed number or identifier.
    local before = prefix:sub(start - 1, start - 1)
    if start > 1 and before:match("[%w_.,+-]") then return nil end
    return ParseLocalizedNumber(token)
end

local function CleanText(text)
    if IsSecret(text) or type(text) ~= "string" or not HasPluralTag(text) then
        return text
    end

    return (text:gsub("()%$[lL]([^:;$\r\n]+):([^:;$\r\n]+);", function(position, singular, plural)
