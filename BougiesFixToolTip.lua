local function CleanText(text)
    if type(text) == "string" and text:find("%$l") then
        -- Cas 1 : précédé d'un chiffre (ex: "7 $lpoint:points;")
        text = text:gsub("(%d+)%s*%$l([^:;]+):([^;]+);", function(num, sing, plur)
            return num .. " " .. (tonumber(num) == 1 and sing or plur)
        end)
        -- Cas 2 : balise isolée restante (sécurité)
        text = text:gsub("%$l([^:;]+):([^;]+);", "%2")
    end
    return text
end

local function ScanTooltip(tooltip)
    if not tooltip or not tooltip.GetRegions then return end
    for _, region in ipairs({ tooltip:GetRegions() }) do
        if region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if text and text:find("%$l") then
                region:SetText(CleanText(text))
            end
        end
    end
end

-- Hook sur les infobulles principales et celles d'ElvUI
local tooltips = {
    GameTooltip,
    ItemRefTooltip,
    ShoppingTooltip1,
    ShoppingTooltip2,
    EmbeddedItemTooltip
}

for _, tt in ipairs(tooltips) do
    if tt then
        tt:HookScript("OnShow", ScanTooltip)
        tt:HookScript("OnUpdate", ScanTooltip)
    end
end
