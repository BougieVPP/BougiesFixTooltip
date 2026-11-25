local isFrench = (GetLocale and GetLocale() == "frFR")

local function IsSecret(val)
    if issecretvalue and issecretvalue(val) then
        return true
    end
    if canaccessvalue and not canaccessvalue(val) then
        return true
    end
    return false
end

local function ResolvePlural(prefix, numStr, midCodes, sing, plur)
    -- Supprime espaces normaux, espaces insécables UTF-8 et convertit la virgule en point
    local cleanNum = numStr:gsub("[%s\194\160]", ""):gsub(",", ".")
    local numeric = tonumber(cleanNum)
    local isSingular

    if numeric then
        isSingular = isFrench and (numeric < 2) or (numeric == 1)
    else
        isSingular = false
    end

    return prefix .. numStr .. midCodes .. (isSingular and sing or plur)
end

local function CleanText(text)
    if type(text) ~= "string" or IsSecret(text) then
        return text
    end
    if text:find("%$[lL]") then
        -- Cas 1 : précédé d'un nombre (gère décimales, espaces insécables et codes couleur |r / |cXXXXXXXX)
        text = text:gsub("(%f[%d%.%,])([%d%,%.]+)([%s\194\160|cCrR%x]*)%$[lL]([^:;]+):([^;]+);", ResolvePlural)
        -- Cas 2 : balise isolée sans chiffre devant (sécurité)
        text = text:gsub("%$[lL]([^:;]+):([^;]+);", "%2")
    end
    return text
end

local function ProcessRegions(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and not (region.IsForbidden and region:IsForbidden()) then
            if region.GetObjectType and region:GetObjectType() == "FontString" then
                local ok, text = pcall(region.GetText, region)
                if ok and text and not IsSecret(text) and text:find("%$[lL]") then
                    local cleaned = CleanText(text)
                    if cleaned ~= text then
                        pcall(region.SetText, region, cleaned)
                    end
                end
            end
        end
    end
end

local function ScanTooltip(tooltip)
    if not tooltip or (tooltip.IsForbidden and tooltip:IsForbidden()) then return end
    if tooltip.IsShown and not tooltip:IsShown() then return end
    if not tooltip.GetRegions then return end

    ProcessRegions(tooltip:GetRegions())
end

local function HookTooltip(tt)
    if tt and not hooked[tt] and tt.HookScript then
        hooked[tt] = true
        tt:HookScript("OnShow", ScanTooltip)
        tt:HookScript("OnUpdate", ScanTooltip)
    end
end

-- Hook sur les infobulles principales et celles d'ElvUI
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

-- Capture également toute future infobulle initialisée dynamiquement par le jeu
if type(SharedTooltip_SetBackdropStyle) == "function" then
    hooksecurefunc("SharedTooltip_SetBackdropStyle", function(tt)
        HookTooltip(tt)
    end)
end
