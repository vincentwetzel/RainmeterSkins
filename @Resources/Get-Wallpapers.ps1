# Get-Wallpapers.ps1
# Reads the current per-monitor wallpaper through the Windows Desktop Wallpaper
# COM API and returns stable position-name pairs for Rainmeter.

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$scriptTemp = Join-Path $PSScriptRoot ".tmp"
if (-not (Test-Path -LiteralPath $scriptTemp)) {
    New-Item -ItemType Directory -Path $scriptTemp -Force | Out-Null
}
$env:TEMP = $scriptTemp
$env:TMP = $scriptTemp

$signature = @"
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

[StructLayout(LayoutKind.Sequential)]
public struct DesktopRect {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}

[ComImport]
[Guid("B92B56A9-8B55-4E14-9A89-0199BBB6F93B")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IDesktopWallpaper {
    void SetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID, [MarshalAs(UnmanagedType.LPWStr)] string wallpaper);
    [return: MarshalAs(UnmanagedType.LPWStr)]
    string GetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID);
    [return: MarshalAs(UnmanagedType.LPWStr)]
    string GetMonitorDevicePathAt(uint monitorIndex);
    uint GetMonitorDevicePathCount();
    void GetMonitorRECT([MarshalAs(UnmanagedType.LPWStr)] string monitorID, out DesktopRect displayRect);
}

public class WallpaperMonitor {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
    public double CenterX;
    public double CenterY;
    public string Name;
}

public static class WallpaperReader {
    public static string Read(string[] mappings) {
        Type desktopType = Type.GetTypeFromCLSID(new Guid("C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD"));
        object desktop = Activator.CreateInstance(desktopType);
        IDesktopWallpaper wallpaper = (IDesktopWallpaper)desktop;
        uint count = wallpaper.GetMonitorDevicePathCount();

        List<WallpaperMonitor> monitors = new List<WallpaperMonitor>();
        for (uint i = 0; i < count; i++) {
            string id = wallpaper.GetMonitorDevicePathAt(i);
            DesktopRect rect;
            wallpaper.GetMonitorRECT(id, out rect);
            string path = wallpaper.GetWallpaper(id);

            monitors.Add(new WallpaperMonitor {
                Left = rect.Left,
                Top = rect.Top,
                Right = rect.Right,
                Bottom = rect.Bottom,
                CenterX = (rect.Left + rect.Right) / 2.0,
                CenterY = (rect.Top + rect.Bottom) / 2.0,
                Name = GetWallpaperName(path)
            });
        }

        if (monitors.Count == 0) {
            return "[No monitors found]";
        }

        if (mappings != null && mappings.Length > 0) {
            List<string> pairs = new List<string>();

            foreach (string mapping in mappings) {
                string[] labelAndRect = mapping.Split(new char[] {'='}, 2);
                if (labelAndRect.Length != 2) {
                    continue;
                }

                string label = labelAndRect[0];
                string[] values = labelAndRect[1].Split(',');
                if (values.Length != 4) {
                    continue;
                }

                int left;
                int top;
                int width;
                int height;
                if (!Int32.TryParse(values[0], out left)
                    || !Int32.TryParse(values[1], out top)
                    || !Int32.TryParse(values[2], out width)
                    || !Int32.TryParse(values[3], out height)) {
                    continue;
                }

                int right = left + width;
                int bottom = top + height;
                WallpaperMonitor match = monitors
                    .OrderByDescending(m => OverlapArea(left, top, right, bottom, m.Left, m.Top, m.Right, m.Bottom))
                    .ThenBy(m => Math.Abs(m.CenterX - ((left + right) / 2.0)) + Math.Abs(m.CenterY - ((top + bottom) / 2.0)))
                    .FirstOrDefault();

                if (match != null) {
                    pairs.Add(label + "=" + match.Name);
                }
            }

            if (pairs.Count > 0) {
                return String.Join("|", pairs.ToArray());
            }
        }

        WallpaperMonitor primary = monitors
            .Where(m => m.Left == 0 && m.Top == 0)
            .FirstOrDefault();

        if (primary == null) {
            primary = monitors
            .OrderBy(m => Math.Abs(m.CenterX) + Math.Abs(m.CenterY))
            .First();
        }

        WallpaperMonitor leftMonitor = monitors
            .Where(m => m.CenterX < primary.CenterX)
            .OrderBy(m => m.CenterX)
            .FirstOrDefault();

        WallpaperMonitor rightMonitor = monitors
            .Where(m => m.CenterX > primary.CenterX)
            .OrderByDescending(m => m.CenterX)
            .FirstOrDefault();

        WallpaperMonitor topMonitor = monitors
            .Where(m => m.CenterY < primary.CenterY)
            .OrderBy(m => m.CenterY)
            .FirstOrDefault();

        return "Center=" + primary.Name
            + "|Left=" + (leftMonitor == null ? "[No left monitor]" : leftMonitor.Name)
            + "|Right=" + (rightMonitor == null ? "[No right monitor]" : rightMonitor.Name)
            + "|Top=" + (topMonitor == null ? "[No top monitor]" : topMonitor.Name);
    }

    private static string GetWallpaperName(string path) {
        if (String.IsNullOrWhiteSpace(path)) {
            return "[No wallpaper]";
        }

        return Path.GetFileName(path);
    }

    private static long OverlapArea(int leftA, int topA, int rightA, int bottomA, int leftB, int topB, int rightB, int bottomB) {
        int left = Math.Max(leftA, leftB);
        int top = Math.Max(topA, topB);
        int right = Math.Min(rightA, rightB);
        int bottom = Math.Min(bottomA, bottomB);

        if (right <= left || bottom <= top) {
            return 0;
        }

        return (long)(right - left) * (bottom - top);
    }
}
"@

try {
    if (-not ("WallpaperReader" -as [type])) {
        Add-Type -TypeDefinition $signature
    }

    [WallpaperReader]::Read($args)
} catch {
    "[Wallpaper lookup failed: $($_.Exception.Message)]"
}
