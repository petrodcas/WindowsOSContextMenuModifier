<#
    .SYNOPSIS
    Adds a script to Windows' menu context by modifying the registry. Only affects the current user.

    .DESCRIPTION
    The script modifies the registry for the current user to add a new label in the specified context menu.
    Context menus in Windows OS are those that are opened when right clicking.
    This new label, when used, will launch the command specified as argument.

    .PARAMETER contextMenuName
    Specifies the name that will appear in the context menu.

    .PARAMETER registryName
    Specifies the name that will be used on the registry.

    .PARAMETER command
    Specifies the command that will be launched when using the new context menu's label.

    .PARAMETER contextMenuType
    Specifies the type of context menu to include the label in.
    There are three types:
        - OnFile: It will appear when right clicking on any file (not directories).
        - OnDirectory: It will appear when right clicking on a directory.
        - OnDirectoryBackground: It will appear when right clicking on a directory's background.

    .PARAMETER ShowOnShift 
    Specifies whether the label should only be show when combining shift with right click.
    
    .PARAMETER Icon
    Specifies the path to the icon that will be displayed on the label.

    .INPUTS
    Yes. Every parameter can be introduced from a pipeline as a named argument.

    .OUTPUTS
    No. Outputs nothing.

    .EXAMPLE
    PS > .\Add-ScriptToContextMenu.ps1 -contextMenuName "Convertir a MP3" -registryName "toMP3baby" -contextMenuType OnDirectory -command "Powershell.exe -Command `"Get-ChildItem -Path '%V' -File |  foreach-object {`$_.fullname} | C:\Users\Peter\Desktop\scripts\ConvertTo-Extension.ps1 -extension mp3 -outputdirectory `$(Join-Path '%v' 'salida de la conversion')`"" -ShowOnShift
    
    .EXAMPLE
    PS > .\Add-ScriptToContextMenu.ps1 -contextMenuName "Sample Menu Label" -registryName "mySampleContextMenuLabel" -contextMenuType OnFile -command "Powershell.exe -File `"C:\Scripts\Invoke-MyAwesomeScript.ps1`" `"%V`""

    .LINK
    For future reference: https://stackoverflow.com/questions/20449316/how-add-context-menu-item-to-windows-explorer-for-folders
#>

param (
    [ValidateNotNullOrEmpty()]
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$contextMenuName,
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$registryName=$null,
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]$command,
    [ValidateSet('OnFile', 'OnDirectory', 'OnDirectoryBackground')]
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$contextMenuType,
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]$ShowOnShift,
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$Icon=$null
)

begin {
    # Any error should stop the script's execution
    $ErrorActionPreference = 'Stop'

    function Test-IsNullOrEmpty{
        param ([string]$it)
        $it -eq $null -or $it -match "^\s*$"
    }
    $locationForAnyFileContextMenu = 'registry::hkey_current_user\software\classes\*\shell\'
    $locationForDirectoryBackgroundContextMenu = 'registry::hkey_current_user\Software\Classes\directory\Background\shell\'
    $locationForDirectoryContextMenu = 'registry::hkey_current_user\Software\Classes\directory\shell\'

    $initialWorkingDirectory = Get-Location
}

process {
    # If registryName is not set or is empty, then it matches contextMenuName with no spaces
    if (Test-IsNullOrEmpty $registryName) {
        $registryName = $contextMenuName -replace "\s+",""
    }

    $registryLocation = $null

    switch ($contextMenuType) {
        'OnFile' { $registryLocation = $locationForAnyFileContextMenu }
        'OnDirectory' { $registryLocation = $locationForDirectoryContextMenu }
        'OnDirectoryBackground' { $registryLocation = $locationForDirectoryBackgroundContextMenu }
        Default { throw "Unknown ContextMenuType value: $contextMenuType" }
    }
    # Creates the registry key if it does not exist
    if ( -not (Test-Path -LiteralPath $registryLocation) ) {
        New-Item -ItemType Directory -Path $registryLocation | Out-Null
    }
    
    #Creates the keys and properties needed
    Set-Location -LiteralPath $registryLocation | Out-Null
    New-Item -ItemType Directory -Path ".\$registryName" | Out-Null
    Set-Location ".\$registryName" | Out-Null
    New-ItemProperty -Path . -PropertyType String -Name '(default)' -Value $contextMenuName | Out-Null
    if ($ShowOnShift) {
        New-ItemProperty -Path . -PropertyType String -Name 'Extended' -Value $null | Out-Null
    }
    if (-not (Test-IsNullOrEmpty $Icon)) {
        New-ItemProperty -Path . -PropertyType String -Name 'Icon' -Value $Icon | Out-Null
    }   
    New-Item -ItemType Directory -Path ".\command" | Out-Null
    Set-Location ".\command" | Out-Null
    New-ItemProperty -Path . -PropertyType String -Name '(default)' -Value $command | Out-Null
}

end { # cleans up
    Set-Location $initialWorkingDirectory | Out-Null
    $ErrorActionPreference = 'Continue'
}