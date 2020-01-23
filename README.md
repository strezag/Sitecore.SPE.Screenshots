# Sitecore SPE Screenshots using ScreenshotLayer API
Reviving the Screenshots button in Sitecore using ScreenshotLayer API and PowerShell

# Demo
![demo](/img/demo-fast.gif "Screenshots")

# Installation
Download `Sitecore.SPE.Screenshots.zip` and install to Sitecore.  Follo

## Post-Installation Steps

1) Replace API-KEY-GOES-HERE with your own key from https://screenshotlayer.com/ in the following location:
> `/sitecore/system/Modules/PowerShell/Script Library/Screenshots/Content Editor/Ribbon/Presentation/Preview/Screenshot`


2) Rebuild Integration SPE Points
    - Open a new ISE session
    - Select the `Sync Library Content Editor Ribbon` sub-option of the `Rebuild All` button under the `Settings` tab

## Compatibility 
Tested with `9.3.0`, but should generally work across most versions where `Sitecore PowerShell Extensions` is installed. 