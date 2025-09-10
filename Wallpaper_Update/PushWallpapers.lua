function Initialize()
    measure = SKIN:GetMeasure("MeasureGetWallpapers")
    lastValue = nil

    -- Match the correct order here
    targets = {
        -- parts[1]
        "Wallpapers_Center",
        -- parts[2]
        "Wallpapers_Left",
        -- parts[3]
        "Wallpapers_Right",
        -- parts[4]
        "Wallpapers_Top"
    }
end

function Update()
    SKIN:Bang("!Log", "PushWallpapers.lua Update() triggered")

    local result = measure:GetStringValue() or ""
    result = result:gsub("%s+$", "")

    SKIN:Bang("!Log", "Raw wallpaper string: " .. result)

    if result == lastValue or result == "" then
        return
    end
    lastValue = result

    local parts = {}
    for token in string.gmatch(result, "([^|]+)") do
        table.insert(parts, token)
    end

    -- Loop through parts and push to matching skins
    for i, skin in ipairs(targets) do
        if parts[i] then
            SKIN:Bang('!SetVariable WallpaperName "'..parts[i]..'" "'..skin..'"')
            SKIN:Bang('!Update "'..skin..'"')
            SKIN:Bang("!Log", "Pushed "..parts[i].." → "..skin)
        end
    end
end
