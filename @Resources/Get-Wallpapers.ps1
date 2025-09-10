# Get-Wallpapers.ps1
# Collects current wallpaper filenames from the 4 TranscodedImageCache registry values
# and outputs them as a single pipe-separated string for Rainmeter.

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$keys = "TranscodedImageCache_000","TranscodedImageCache_001","TranscodedImageCache_002","TranscodedImageCache_003"
$regPath = "HKCU:\Control Panel\Desktop"

$results = @()

foreach ($k in $keys) {
    try {
        $val = Get-ItemProperty -Path $regPath -Name $k -ErrorAction Stop
        $bin = $val.$k
        $str = [System.Text.Encoding]::Unicode.GetString($bin)

        # Split on nulls and filter for image paths
        $segments = $str -split "`0"
        foreach ($segment in $segments) {
            if ($segment -match '\.(jpg|png|bmp)$') {
                $filename = Split-Path $segment -Leaf
                $results += $filename
                break
            }
        }
    } catch {
        $results += "[[$k missing or unreadable]]"
    }
}

if ($results.Count -gt 0) {
    [string]::Join('|', $results)
} else {
    "[No wallpapers found]"
}