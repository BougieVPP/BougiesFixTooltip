local isFrench = (GetLocale and GetLocale() == "frFR")

local function IsSecret(val)
    if issecretvalue and issecretvalue(val) then return true end
    if canaccessvalue and not canaccessvalue(val) then return true end
    return false
end

local function ResolvePlural(numStr, midCodes, sing, plur)
    local cleanNum = numStr:gsub("[%s\194\160]", ""):gsub(",", ".")
    local numeric = tonumber(cleanNum)
    local isSingular = false

    if numeric then
        isSingular = isFrench and (numeric < 2) or (numeric == 1)
    end

    return numStr .. midCodes .. (isSingular and sing or plur)
end

local function CleanText(text)
    if type(text) ~= "string" or IsSecret(text) then return text end
    if text:find("%$[lL]") then
        text = text:gsub("([%d%,%.]+)([%s\194\160|cCrR%x]*)%$[lL]([^:;]+):([^;]+);", ResolvePlural)
        text = text:gsub("%$[lL]([^:;]+):([^;]+);", "%2")
    end
    return text
end

local function ScanTooltip(tooltip)
    if not tooltip or (tooltip.IsForbidden and tooltip:IsForbidden()) then return end
    if not tooltip.GetRegions then return end

    for i = 1, select("#", tooltip:GetRegions()) do
        local region = select(i, tooltip:GetRegions())
        if region and not (region.IsForbidden and region:IsForbidden()) then
            if region.GetObjectType and region:GetObjectType() == "FontString" then
                local text = region:GetText()
                if text and not IsSecret(text) and text:find("%$[lL]") then
                    local cleaned = CleanText(text)
                    if cleaned ~= text then
                        region:SetText(cleaned)
                    end
                end
            end
        end
    end
end

local hooked = setmetatable({}, { __mode = "k" })

local function HookTooltip(tt)
    if tt and not hooked[tt] and tt.HookScript then
        hooked[tt] = true
        tt:HookScript("OnShow", ScanTooltip)
        tt:HookScript("OnUpdate", ScanTooltip)
    end
end

local tooltips = {
    GameTooltip,
    ItemRefTooltip,
    ItemRefShoppingTooltip1,
    ItemRefShoppingTooltip2,
    ShoppingTooltip1,
    ShoppingTooltip2,
    EmbeddedItemTooltip
}

for _, tt in ipairs(tooltips) do
    HookTooltip(tt)
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ScanTooltip)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, ScanTooltip)
end
local isFrench = (GetLocale and GetLocale() == "frFR")

local function IsSecret(val)
    if issecretvalue and issecretvalue(val) then return true end
    if canaccessvalue and not canaccessvalue(val) then return true end
    return false
end

local function ResolvePlural(numStr, midCodes, sing, plur)
    local cleanNum = numStr:gsub("[%s\194\160]", ""):gsub(",", ".")
    local numeric = tonumber(cleanNum)
    local isSingular = false

    if numeric then
        isSingular = isFrench and (numeric < 2) or (numeric == 1)
    end

    return numStr .. midCodes .. (isSingular and sing or plur)
end

local function CleanText(text)
    if type(text) ~= "string" or IsSecret(text) then return text end
    if text:find("%$[lL]") then
        text = text:gsub("([%d%,%.]+)([%s\194\160|cCrR%x]*)%$[lL]([^:;]+):([^;]+);", ResolvePlural)
        text = text:gsub("%$[lL]([^:;]+):([^;]+);", "%2")
    end
    return text
end

local function ScanTooltip(tooltip)
    if not tooltip or (tooltip.IsForbidden and tooltip:IsForbidden()) then return end
    if not tooltip.GetRegions then return end

    for i = 1, select("#", tooltip:GetRegions()) do
        local region = select(i, tooltip:GetRegions())
        if region and not (region.IsForbidden and region:IsForbidden()) then
            if region.GetObjectType and region:GetObjectType() == "FontString" then
                local text = region:GetText()
                if text and not IsSecret(text) and text:find("%$[lL]") then
                    local cleaned = CleanText(text)
                    if cleaned ~= text then
                        region:SetText(cleaned)
                    end
                end
            end
        end
    end
end

local hooked = setmetatable({}, { __mode = "k" })

local function HookTooltip(tt)
    if tt and not hooked[tt] and tt.HookScript then
        hooked[tt] = true
        tt:HookScript("OnShow", ScanTooltip)
        tt:HookScript("OnUpdate", ScanTooltip)
    end
end

local tooltips = {
    GameTooltip,
    ItemRefTooltip,
    ItemRefShoppingTooltip1,
    ItemRefShoppingTooltip2,
    ShoppingTooltip1,
    ShoppingTooltip2,
    EmbeddedItemTooltip
}

for _, tt in ipairs(tooltips) do
    HookTooltip(tt)
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ScanTooltip)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, ScanTooltip)
end
