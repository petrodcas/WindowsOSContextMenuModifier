<#
    .SYNOPSIS
    Removes a script from Windows' menu context by modifying the registry. Only affects the current user.

    .DESCRIPTION
    The script modifies the registry for the current user to remove a matching (and existing) label in the specified context menu.
    Context menus in Windows OS are those that are opened when right clicking.

    .PARAMETER contextMenuName
    Specifies the name that appears in the context menu.

    .PARAMETER registryName
    Specifies the name that is used on the registry.

    .PARAMETER contextMenuType
    Specifies the type of context menu to remove the label from.
    There are three types:
        - OnFile: It appears when right clicking on any file (not directories).
        - OnDirectory: It appears when right clicking on a directory.
        - OnDirectoryBackground: It appears when right clicking on a directory's background.

    .INPUTS
    Yes. Every parameter can be introduced from a pipeline as a named argument.

    .OUTPUTS
    No. Outputs nothing.

    .EXAMPLE
    PS > .\Remove-ScriptFromContextMenu.ps1 -contextMenuName "Convertir a MP3" -registryName "toMP3baby" -contextMenuType OnDirectory 

    .EXAMPLE
    PS > .\Remove-ScriptFromContextMenu.ps1 -contextMenuName "Sample Menu Label" -contextMenuType OnFile

    .EXAMPLE
    PS > .\Remove-ScriptFromContextMenu.ps1 -registryName "toMP3baby" -contextMenuType OnDirectoryBackground

    .LINK
    For future reference: https://stackoverflow.com/questions/20449316/how-add-context-menu-item-to-windows-explorer-for-folders
#>

param (
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='FindByContextMenuName')]
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='StrictFind')]
    [string]$contextMenuName,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='FindByRegistryName')]
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='StrictFind')]
    [string]$registryName,
    [ValidateSet('OnFile', 'OnDirectory', 'OnDirectoryBackground')]
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [string]$contextMenuType
)

begin {
    # Any error should stop the script's execution
    $ErrorActionPreference = 'Stop'

    $registryPrefix = 'registry::'
    $defaultProperty = '(default)'
    $locationForAnyFileContextMenu = 'registry::hkey_current_user\software\classes\*\shell\'
    $locationForDirectoryBackgroundContextMenu = 'registry::hkey_current_user\Software\Classes\directory\Background\shell\'
    $locationForDirectoryContextMenu = 'registry::hkey_current_user\Software\Classes\directory\shell\'

}

process {

    [string]$usedParameterSet = $PSCmdlet.ParameterSetName
    $registryLocation = $null

    switch ($contextMenuType) {
        'OnFile' { $registryLocation = $locationForAnyFileContextMenu }
        'OnDirectory' { $registryLocation = $locationForDirectoryContextMenu }
        'OnDirectoryBackground' { $registryLocation = $locationForDirectoryBackgroundContextMenu }
        Default { throw "Unknown ContextMenuType value: $contextMenuType" }
    }

    switch($usedParameterSet){
        'FindByContextMenuName' {
            (Get-ChildItem -LiteralPath $registryLocation) | Where-Object { (Get-ItemProperty -LiteralPath "$registryPrefix$_").$defaultProperty -eq $contextMenuName } | Remove-Item
        }
        'FindByRegistryName' {
            (Get-ChildItem -LiteralPath $registryLocation) | Where-Object { "$registryPrefix$($_.name)" -eq $(Join-Path $registryLocation $registryName) } | Remove-Item
        }
        'StrictFind' {
            (Get-ChildItem -LiteralPath $registryLocation) | Where-Object { 
                "$registryPrefix$($_.name)" -eq $(Join-Path $registryLocation $registryName) `
                -and (Get-ItemProperty -LiteralPath "$registryPrefix$_").$defaultProperty -eq $contextMenuName
            } | Remove-Item
        }
    }

}

end {}