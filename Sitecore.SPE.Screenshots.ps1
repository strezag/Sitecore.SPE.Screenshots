$apiKey = "API-KEY-GOES-HERE"
$apiUrl = "http://api.screenshotlayer.com/api/capture?"

function Get-Screenshot {
    Param(
        [Parameter(Mandatory = $True)]
        [string]$PageUrl,
        [Parameter(Mandatory = $False)]
        [string]$Size     
    )
    
    # Build out query parameters for the API, starting with the access_key
    $query = "&access_key=" + $apiKey
    
    # Enable full page capture
    $query += "&fullpage=1" 

    # Set to "1" if you want to force the API to capture a fresh screenshot
    $query += "&force=1"
    
    # If the user selected Mobile, set the view port to a common mobile screen size (eg. 480x800)
    if($Size -eq "Mobile"){
        $query += "&viewport=480x800"
    }else{
        # User expects a Desktop version, set the screen size to a common desktop screen size
        $query += "&viewport=2560x1440"
    }
    
    # Add the page URL
    $query += "&url=" + $PageUrl
    
    # Append the query parameters to the URL endpoint
    $apiUri = $apiUrl + $query

    Write-Host $apiUri -ForegroundColor Blue

    try {
        # Call the API
        $request = [System.Net.WebRequest]::Create($apiUri)
        $response = $request.getResponse() 
        
        # Get the image response stream from the web request response
        $capture = [System.Drawing.Image]::fromStream($response.getResponseStream())
        
        $response.Close()
    } 
    catch [System.Net.WebException] {
        Write-Host 'Error calling API' -ForegroundColor Red
        Write-Host $Error[0] -ForegroundColor Red
    } 
    
    # Check if we have an image stream
    if ($null -ne $capture) {
    
        # Verify a temp folder ('screenshots' folder in the DataFolder
        $folderPath = Join-Path -Path $SitecoreDataFolder -ChildPath "screenshots"
        
        Write-Host "Folder path: $folderPath"
        
        # Check if the temp folder exists
        if (-not(Test-Path -Path $folderPath)) { 
            Write-Host "Could not validate screenshots folder $folderPath" -ForegroundColor Yellow
            
            # Create a 'screenshots' folder in the DataFolder 
            New-Item -Path $SitecoreDataFolder -Name "screenshots" -ItemType "directory" 
            Write-Host "Screenshots folder created $folderPath" -ForegroundColor Yellow
            
            # Check for the temp folder again  
            if (-not(Test-Path -Path $folderPath)) { 
                Write-Host "Could not create 'screenshots' folder in $SitecoreDataFolder" -ForegroundColor Red
                exit
            }
        }    
        
        # Generate a timestamp
        $timestamp = Get-Date -Format "ddMMyyyy-hhmmss"
        
        # Build the file name using the item name and timestamp
        $itemName = $currentItem.Name.Replace(" ", "-").ToLower()
        $fileName = "$folderPath\$itemName-$timestamp.png"
        
        # Save the image in the stream to the 'screenshots' folder
        $capture.Save($fileName, 'png') 
        
        # Flush the image stream
        $capture.dispose() 
        
        # Initialize download file dialog
        Download-File $fileName > $null
        
        # Remove the screenshot file from the screenshots folder. 
        Write-Host "Clearing file"
        Remove-Item $fileName
    }
    else {
        Write-Host "No image..."
    }
}

function Get-ItemUrl {
    [CmdletBinding()]
      param(
          [Parameter(Mandatory = $true, Position = 0)]
          [Sitecore.Data.Items.Item]$Item       
      )
      [Sitecore.Context]::SetActiveSite("website")
      $urlop = New-Object ([Sitecore.Links.UrlOptions]::DefaultOptions)
      $urlop.LanguageEmbedding = "Never"
      $urlop.AddAspxExtension = $false
      $urlop.AlwaysIncludeServerUrl = $true
      $urlop.LowercaseUrls = $true
      $linkUrl = [Sitecore.Links.LinkManager]::GetItemUrl($Item, $urlop)
      $linkUrl
  }
  
  function Assert-HasLayout {
      [CmdletBinding()]
      param(
          [Parameter(Mandatory = $true, Position = 0)]
          [Sitecore.Data.Items.Item]$Item       
      )
      
      # Get the item's Final Layout 
      $layout = Get-Layout -FinalLayout -Item $Item
      
      # If a layout is present, assert true
      if ($layout) {
          return $true
      }
      
      # Item does not have a layout.  Exit
      Write-Host "Item has no layout. Screen capture cannot be executed."
      exit
  }
  
  # Get the current item based on context
  $currentItem = Get-Item "."
  
  # Ensure the item has a layout
  Assert-HasLayout $currentItem > $null
  
  # Get the item's URL using Link Manager
  $itemPageUrl = Get-ItemUrl($currentItem)

$screenshotSize = Show-ModalDialog -Control "ConfirmChoice" -Parameters @{ btn_0 = "Desktop"; btn_1 = "Mobile";  te = "Screenshot size"; cp = "Conditions" } -Height 120 -Width 400

if($screenshotSize -eq "btn_1"){
    $screenshotSize = "Mobile"
}

# Confirm the API key isn't using the default text, and is not empty
if($apiKey -eq "API-KEY-GOES-HERE" -or [String]::Empty){
    Write-Host "Please configure your API key in: `n  > /sitecore/system/Modules/PowerShell/Script Library/Screenshots/Content Editor/Context Menu/Screenshot`n  > /sitecore/system/Modules/PowerShell/Script Library/Screenshots/Content Editor/Ribbon/Presentation/Preview/Screenshot" -ForegroundColor Red
    exit
}
    
if ($itemPageUrl -ne [String]::Empty) {
    Get-Screenshot -PageUrl $itemPageUrl -Size $screenshotSize
}
else {
    Write-Host "Could not get a page URL for:`n> Name: $($currentItem.Name)`n> Path: $($currentItem.Paths.Path)`n> ID: $($currentItem.ID)" -ForegroundColor Red
    throw
}