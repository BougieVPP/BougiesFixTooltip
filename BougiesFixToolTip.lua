local function IsSecret(val)
    if issecretvalue and issecretvalue(val) then
        return true
    end
    if canaccessvalue and not canaccessvalue(val) then
        return true
    end
    return false
end

local function CleanText(text)
    if type(text) ~= "string" or IsSecret(text) then
        return text
    end
    if text:find("%$[lL]") then
        -- Cas 1 : précédé d'un entier ou décimal (ex: "7 $lpoint:points;" ou "0,5 $lseconde:secondes;"))
        text = text:gsub("([%d%,%.]+)%s*%$[lL]([^:;]+):([^;]+);", function(num, sing, plur)
            local numeric = tonumber((numStr:gsub(",", ".")))
            local word = (numeric and numeric <= 1) and sing or plur
            return numStr .. " " .. word
        end)
        -- Cas 2 : balise isolée restante (sécurité)
        text = text:gsub("%$[lL]([^:;]+):([^;]+);", "%2")
    end
    return text
end

local function ScanTooltip(tooltip)
    if not tooltip or (tooltip.IsForbidden and tooltip:IsForbidden()) then return end
    if tooltip.IsShown and not tooltip:IsShown() then return end
    if not tooltip.GetRegions then return end

    for _, region in ipairs({ tooltip:GetRegions() }) do
        if region and not (region.IsForbidden and region:IsForbidden()) and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if text and not IsSecret(text) and text:find("%$[lL]") then
                local cleaned = CleanText(text)
                if cleaned ~= text then
                    pcall(region.SetText, region, cleaned)
                end
            end
        end
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
    if tt and tt.HookScript then
        tt:HookScript("OnShow", ScanTooltip)
        tt:HookScript("OnUpdate", ScanTooltip)
    end
end
