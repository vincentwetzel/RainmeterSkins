# Rainmeter Skins Repository

This repository contains a collection of basic [Rainmeter](https://www.rainmeter.net/) skins, primarily featuring the **illustro** suite. These skins are designed to show some of the capabilities of Rainmeter and provide a good starting point for learning how to edit and create your own desktop widgets.

## Included Skins (illustro suite)

The `illustro` folder contains several pre-configured skins for monitoring system resources and adding desktop utilities:

* **Clock:** Displays the current time (in 24-hour format), day of the week, and date.
* **Disk:** Displays disk usage, showing free and used space. Includes configurations for a single disk (`1 Disk.ini`) or dual disks (`2 Disks.ini`).
* **Google:** A convenient search widget that allows you to query Google directly from your desktop.
* **Network:** Shows your public IPv4 address and current network activity (download and upload speeds).
* **Recycle Bin:** Shows the current state of your Recycle Bin (item count and total size). Left-click to open it; right-click to empty it.
* **System:** Displays basic system stats including average CPU load, RAM usage, and SWAP (pagefile) usage. Left-clicking the title opens the Windows Task Manager.
* **Welcome:** An introductory skin providing links to Rainmeter documentation, skin discovery sites, and community forums.

## Scripts and Utilities

* **`@Resources/Get-Wallpapers.ps1`**  
  A utility PowerShell script that interacts with the Windows Desktop Wallpaper COM API. It identifies multiple monitor layouts and their respective wallpaper paths, returning stable position-name pairs to dynamically assist Rainmeter skins. The script is designed to automatically detect monitors immediately adjacent to your Primary display, ensuring reliable layout mapping even after resuming from system sleep.

## Getting Started

1. **Install Rainmeter:** If you haven't already, download and install Rainmeter.
2. **Add to Skins Folder:** Ensure this folder structure is placed in your Rainmeter Skins directory (typically located at `C:\Users\<YourUser>\Documents\Rainmeter\Skins`).
3. **Load Skins:** 
   * Right-click the Rainmeter tray icon in your Windows taskbar.
   * Select **Refresh All**.
   * Navigate to **illustro** in the context menu and select the `.ini` files you want to display on your desktop.

## Customization

Rainmeter skins are highly customizable. You can modify colors, fonts, and specific behaviors by opening the `.ini` files in any text editor. 

* Variables such as `fontName`, `textSize`, `colorBar`, and `colorText` are typically defined at the top of each `.ini` file under the `[Variables]` section.
* **Note for Network Skin:** To ensure the download/upload bars scale accurately, edit `Network.ini` and change the `maxDownload` and `maxUpload` variables to match your internet connection's maximum speeds in bits.

## License

The included `illustro` skins are licensed under the Creative Commons BY-NC-SA 3.0 license.