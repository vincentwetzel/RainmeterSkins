﻿using System;
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
    public double CenterX;
    public double CenterY;
    public string Name;
}

public static class WallpaperReader {
    public static string Read() {
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
                CenterX = (rect.Left + rect.Right) / 2.0,
                CenterY = (rect.Top + rect.Bottom) / 2.0,
                Name = GetWallpaperName(path)
            });
        }

        if (monitors.Count == 0) {
            return "[No monitors found]";
        }

        WallpaperMonitor primary = monitors
            .Where(m => m.Left == 0 && m.Top == 0)
            .FirstOrDefault();

        if (primary == null) {
            primary = monitors
            .OrderBy(m => Math.Abs(m.CenterX) + Math.Abs(m.CenterY))
            .First();
        }

        WallpaperMonitor left = monitors
            .Where(m => m.CenterX < primary.CenterX)
            .OrderByDescending(m => m.CenterX)
            .FirstOrDefault();

        WallpaperMonitor right = monitors
            .Where(m => m.CenterX > primary.CenterX)
            .OrderBy(m => m.CenterX)
            .FirstOrDefault();

        WallpaperMonitor top = monitors
            .Where(m => m.CenterY < primary.CenterY)
            .OrderByDescending(m => m.CenterY)
            .FirstOrDefault();

        return "Center=" + primary.Name
            + "|Left=" + (left == null ? "[No left monitor]" : left.Name)
            + "|Right=" + (right == null ? "[No right monitor]" : right.Name)
            + "|Top=" + (top == null ? "[No top monitor]" : top.Name);
    }

    private static string GetWallpaperName(string path) {
        if (String.IsNullOrWhiteSpace(path)) {
            return "[No wallpaper]";
        }

        return Path.GetFileName(path);
    }
}