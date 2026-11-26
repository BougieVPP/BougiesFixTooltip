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
        local number = NumberBeforeTag(text:sub(1, position - 1))
        -- Preserve the original French rule and the plural fallback.
        local useSingular = number ~= nil and ((isFrench and number < 2) or number == 1)
        return useSingular and singular or plural
    end))
end

local function IsForbidden(object)
    return not object or (object.IsForbidden and object:IsForbidden())
end

local function ScanRegions(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if not IsForbidden(region) and region.GetObjectType
            and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if not IsSecret(text) and type(text) == "string" and HasPluralTag(text) then
                local cleaned = CleanText(text)
                if cleaned ~= text then
                    region:SetText(cleaned)
                end
            end
        end
    end
end

local function ScanTooltip(tooltip)
    if IsForbidden(tooltip) or not tooltip.GetRegions then return end
    -- One API call per scan; no temporary table for the returned regions.
    ScanRegions(tooltip:GetRegions())
end

local hooked = setmetatable({}, { __mode = "k" })
local elapsedByTooltip = setmetatable({}, { __mode = "k" })

local function OnShow(tooltip)
    elapsedByTooltip[tooltip] = 0
    ScanTooltip(tooltip)
end

local function OnUpdate(tooltip, elapsed)
    local total = (elapsedByTooltip[tooltip] or 0) + elapsed
    if total >= UPDATE_INTERVAL then
        elapsedByTooltip[tooltip] = 0
        ScanTooltip(tooltip)
    else
        elapsedByTooltip[tooltip] = total
    end
end

local function HookTooltip(tooltip)
    if IsForbidden(tooltip) or hooked[tooltip] or not tooltip.HookScript then return end
    hooked[tooltip] = true
    if not tooltip.HasScript or tooltip:HasScript("OnShow") then
        tooltip:HookScript("OnShow", OnShow)
    end
    if not tooltip.HasScript or tooltip:HasScript("OnUpdate") then
        tooltip:HookScript("OnUpdate", OnUpdate)
    end
end

local tooltipNames = {
    "GameTooltip",
    "ItemRefTooltip",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "EmbeddedItemTooltip",
}

local registeredTypes = {}
local function RegisterTooltips()
    -- Names avoid nil holes in ipairs and support late-loaded Blizzard UI.
    for _, name in ipairs(tooltipNames) do
        HookTooltip(_G[name])
    end

    local processor = TooltipDataProcessor
    local dataTypes = Enum and Enum.TooltipDataType
    if not processor or not processor.AddTooltipPostCall or not dataTypes then return end
    for _, name in ipairs({ "Item", "Spell" }) do
        local dataType = dataTypes[name]
        if dataType ~= nil and not registeredTypes[dataType] then
            processor.AddTooltipPostCall(dataType, ScanTooltip)
            registeredTypes[dataType] = true
        end
    end
end

RegisterTooltips()
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", RegisterTooltips)
