function Initialize()
    measure = SKIN:GetMeasure("MeasureGetWallpapers")
    lastValue = nil

    targets = {
        Center = "Wallpapers_Center",
        Left = "Wallpapers_Left",
        Right = "Wallpapers_Right",
        Top = "Wallpapers_Top"
    }
end

local function setWallpaper(position, name)
    local skin = targets[position]
    if skin and name and name ~= "" then
        SKIN:Bang('!SetVariable WallpaperName "'..name..'" "'..skin..'"')
        SKIN:Bang('!Update "'..skin..'"')
        SKIN:Bang("!Log", "Pushed "..name.." -> "..skin)
    end
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

    for token in string.gmatch(result, "([^|]+)") do
        local position, name = token:match("^([^=]+)=(.*)$")
        if position and name then
            setWallpaper(position, name)
        end
    end
end
