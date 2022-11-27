# README

This pair of scripts allow to insert and remove commands to WindowsOS's menu contexts, that is, the menus that appear when right clicking on something.

This is quite useful, for example, to run certain scripts on specific locations. Such as opening powershell7 on the current directory or running an organizer script on a directory so it filters images and videos on two new sub-folders.

## HELP

Help can be seen for both scripts using:

```powershell
    Get-Help scriptname
```

or extended help with:

```powershell
    Get-Help scriptname -Full
```

or examples with:

```powershell
    Get-Help scriptname -Examples
```

## BEWARE

Beware, since both scripts modify windows' registry.

## ADDITIONAL HELP

When setting a command, the parameter passed to the script by the system (be it the file/s or folder/s) is '%V'.
