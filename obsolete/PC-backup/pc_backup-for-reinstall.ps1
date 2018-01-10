#Requires -version 5
$DEST_ROOT  = 'g:\backup'
$Backup_LOG = "$env:TEMP\pc_backup-for-reinstall-backup-$(get-date -Format FileDate).log"
if (Test-Path $Backup_LOG) {
  Remove-Item -Path $Backup_LOG -Force | Out-Null
}


$BACKUP_SRC_FILE = @"
BACKUP_SRC_PATH,BACKUP_DST_PATH
$env:USERPROFILE\.bash*,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\.git*,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\.minttyrc,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\.softlayer*,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\_vimrc,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\_viminfo,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\.viminfo,$DEST_ROOT\USERPROFILE
$env:USERPROFILE\*.ini,$DEST_ROOT\USERPROFILE
$env:APPDATA\ConEmu.xml,$DEST_ROOT\APPDATA
"@ -split "`n" | % { $_.trim() } | ConvertFrom-Csv


$BACKUP_SRC_DIR = @"
BACKUP_SRC_PATH,BACKUP_DST_PATH
$env:USERPROFILE\Documents\Telegram,$DEST_ROOT\USERPROFILE\DOCUMENTS\Telegram
$env:USERPROFILE\Documents\go,$DEST_ROOT\USERPROFILE\DOCUMENTS\go
$env:USERPROFILE\Documents\keepass,$DEST_ROOT\USERPROFILE\DOCUMENTS\keepass
$env:USERPROFILE\Documents\My Received Files,$DEST_ROOT\USERPROFILE\DOCUMENTS\My Received Files
$env:USERPROFILE\Documents\RemoteDesktop,$DEST_ROOT\USERPROFILE\DOCUMENTS\RemoteDesktop
$env:USERPROFILE\Documents\ruby_ssl_certs,$DEST_ROOT\USERPROFILE\DOCUMENTS\ruby_ssl_certs
$env:USERPROFILE\Documents\ScalaProjects,$DEST_ROOT\USERPROFILE\DOCUMENTS\ScalaProjects
$env:USERPROFILE\Documents\SublimeProjects,$DEST_ROOT\USERPROFILE\DOCUMENTS\SublimeProjects
$env:USERPROFILE\Documents\Virtual Machines,$DEST_ROOT\USERPROFILE\DOCUMENTS\Virtual Machines
$env:USERPROFILE\Documents\WindowsPowerShell,$DEST_ROOT\USERPROFILE\DOCUMENTS\WindowsPowerShell

$env:USERPROFILE\Documents\Bitbucket,$DEST_ROOT\USERPROFILE\Documents\Bitbucket
$env:USERPROFILE\Documents\Fiddler2,$DEST_ROOT\USERPROFILE\Documents\Fiddler2
$env:USERPROFILE\Documents\GitHub,$DEST_ROOT\USERPROFILE\Documents\GitHub
$env:USERPROFILE\Favorites,$DEST_ROOT\USERPROFILE\Favorites
$env:USERPROFILE\Dropbox,$DEST_ROOT\USERPROFILE\Dropbox
$env:USERPROFILE\Downloads,$DEST_ROOT\USERPROFILE\Downloads
$env:USERPROFILE\Pictures,$DEST_ROOT\USERPROFILE\Pictures
$env:USERPROFILE\Desktop,$DEST_ROOT\USERPROFILE\Desktop
$env:USERPROFILE\devtools,$DEST_ROOT\USERPROFILE\devtools
$env:USERPROFILE\.ssh,$DEST_ROOT\USERPROFILE\.ssh
$env:USERPROFILE\.aws,$DEST_ROOT\USERPROFILE\.aws
$env:USERPROFILE\.azure,$DEST_ROOT\USERPROFILE\.azure
$env:USERPROFILE\.chef,$DEST_ROOT\USERPROFILE\.chef
$env:USERPROFILE\.CLion2016.3,$DEST_ROOT\USERPROFILE\.CLion2016.3
$env:USERPROFILE\.codeintel,$DEST_ROOT\USERPROFILE\.codeintel
$env:USERPROFILE\.config,$DEST_ROOT\USERPROFILE\.config
$env:USERPROFILE\.DataGrip2017.1,$DEST_ROOT\USERPROFILE\.DataGrip2017.1
$env:USERPROFILE\.docker,$DEST_ROOT\USERPROFILE\.docker
$env:USERPROFILE\.eclipse,$DEST_ROOT\USERPROFILE\.eclipse
$env:USERPROFILE\.gem,$DEST_ROOT\USERPROFILE\.gem
$env:USERPROFILE\.IntelliJIdea2017.1,$DEST_ROOT\USERPROFILE\.IntelliJIdea2017.1
$env:USERPROFILE\.sbt,$DEST_ROOT\USERPROFILE\.sbt
$env:USERPROFILE\.ssh,$DEST_ROOT\USERPROFILE\.ssh
$env:USERPROFILE\.vscode,$DEST_ROOT\USERPROFILE\.vscode
$env:USERPROFILE\.VirtualBox,$DEST_ROOT\USERPROFILE\.VirtualBox
$env:USERPROFILE\IdeaProjects,$DEST_ROOT\USERPROFILE\IdeaProjects
$env:USERPROFILE\ClionProjects,$DEST_ROOT\USERPROFILE\ClionProjects
$env:USERPROFILE\bin,$DEST_ROOT\USERPROFILE\bin
$env:USERPROFILE\vimfiles,$DEST_ROOT\USERPROFILE\vimfiles
$env:USERPROFILE\VirtualBox VMs,$DEST_ROOT\USERPROFILE\VirtualBox VMs
c:\msys64,$DEST_ROOT\msys64
c:\temp,$DEST_ROOT\temp
$env:APPDATA\.emacs.d,$DEST_ROOT\APPDATA\.emacs.d
$env:APPDATA\.kde,$DEST_ROOT\APPDATA\.kde
$env:APPDATA\AC3Filter,$DEST_ROOT\APPDATA\AC3Filter
$env:APPDATA\Atom,$DEST_ROOT\APPDATA\Atom
$env:APPDATA\Code,$DEST_ROOT\APPDATA\Code
$env:APPDATA\CodeBlocks,$DEST_ROOT\APPDATA\CodeBlocks
$env:APPDATA\Dev-Cpp,$DEST_ROOT\APPDATA\Dev-Cpp
$env:APPDATA\Docker,$DEST_ROOT\APPDATA\Docker
$env:APPDATA\FastStone,$DEST_ROOT\APPDATA\FastStone
$env:APPDATA\FileZilla,$DEST_ROOT\APPDATA\FileZilla
$env:APPDATA\Foxit Software,$DEST_ROOT\APPDATA\Foxit Software
$env:APPDATA\ghc,$DEST_ROOT\APPDATA\ghc
$env:APPDATA\GHISLER,$DEST_ROOT\APPDATA\GHISLER
$env:APPDATA\gnupg,$DEST_ROOT\APPDATA\gnupg
$env:APPDATA\GRETECH,$DEST_ROOT\APPDATA\GRETECH
$env:APPDATA\HNC,$DEST_ROOT\APPDATA\HNC
$env:APPDATA\JetBrains,$DEST_ROOT\APPDATA\JetBrains
$env:APPDATA\JGoodies,$DEST_ROOT\APPDATA\JGoodies
$env:APPDATA\KeePass,$DEST_ROOT\APPDATA\KeePass
$env:APPDATA\Kitematic,$DEST_ROOT\APPDATA\Kitematic
$env:APPDATA\LINQPad,$DEST_ROOT\APPDATA\LINQPad
$env:APPDATA\Logishrd,$DEST_ROOT\APPDATA\Logishrd
$env:APPDATA\MarkdownPad 2,$DEST_ROOT\APPDATA\MarkdownPad 2
$env:APPDATA\MediaInfo,$DEST_ROOT\APPDATA\MediaInfo
$env:APPDATA\Mozilla,$DEST_ROOT\APPDATA\Mozilla
$env:APPDATA\MySQL,$DEST_ROOT\APPDATA\MySQL
$env:APPDATA\npm,$DEST_ROOT\APPDATA\npm
$env:APPDATA\NuGet,$DEST_ROOT\APPDATA\NuGet
$env:APPDATA\OpenLiveWriter,$DEST_ROOT\APPDATA\OpenLiveWriter
$env:APPDATA\Opera Software,$DEST_ROOT\APPDATA\Opera Software
$env:APPDATA\packer.d,$DEST_ROOT\APPDATA\packer.d
$env:APPDATA\S3Browser,$DEST_ROOT\APPDATA\S3Browser
$env:APPDATA\slack,$DEST_ROOT\APPDATA\slack
$env:APPDATA\Subversion,$DEST_ROOT\APPDATA\Subversion
$env:APPDATA\terraform.d,$DEST_ROOT\APPDATA\terraform.d
$env:APPDATA\TortoiseSVN,$DEST_ROOT\APPDATA\TortoiseSVN
$env:APPDATA\Typora,$DEST_ROOT\APPDATA\Typora
$env:APPDATA\VanDyke,$DEST_ROOT\APPDATA\VanDyke
$env:APPDATA\vlc,$DEST_ROOT\APPDATA\vlc
$env:APPDATA\VMware,$DEST_ROOT\APPDATA\VMware
$env:APPDATA\WinAuth,$DEST_ROOT\APPDATA\WinAuth
$env:APPDATA\Windows Azure Powershell,$DEST_ROOT\APPDATA\Windows Azure Powershell
$env:LOCALAPPDATA\Atlassian,$DEST_ROOT\LOCALAPPDATA\Atlassian
$env:LOCALAPPDATA\Microsoft\Remote Desktop Connection Manager,$DEST_ROOT\LOCALAPPDATA\Microsoft\Remote Desktop Connection Manager
$ENV:LOCALAPPDATA\slack,$DEST_ROOT\LOCALAPPDATA\slack
$ENV:LOCALAPPDATA\SourceTree,$DEST_ROOT\LOCALAPPDATA\SourceTree
"@ -split "`n" | % { $_.trim() } | ConvertFrom-Csv


function Start-DirBackup ($SRC_PATH, $DST_PATH) {
  if ( ! (Test-Path $DST_PATH)) { 
    mkdir -Force $DST_PATH | Out-Null 
  }
  if ( ! (Test-Path $SRC_PATH)) { 
     "$SRC_PATH not found" | Out-File -FilePath $Backup_LOG -Append -Encoding ascii -Force
  }
    if ((Test-Path $SRC_PATH) -and (Test-Path $DST_PATH)) {
    robocopy.exe "$SRC_PATH" "$DST_PATH" /mir /timfix /np /nfl /ndl
  } 
  
}

function Start-FileBackup ($SRC_PATH, $DST_PATH) {
  if ( ! (Test-Path $DST_PATH)) { mkdir -Force $DST_PATH | Out-Null }
  Copy-Item -Force "$SRC_PATH" "$DST_PATH" | Out-Null
}



# Folders
$BACKUP_SRC_DIR_num = ($BACKUP_SRC_DIR | Measure-Object).Count
for ( $i=0; $i -lt $BACKUP_SRC_DIR_num; $i++ )
{
  Start-DirBackup $BACKUP_SRC_DIR[$i].BACKUP_SRC_PATH $BACKUP_SRC_DIR[$i].BACKUP_DST_PATH
}


# Files
$BACKUP_SRC_FILE_num = ($BACKUP_SRC_FILE | Measure-Object).Count
for ( $i=0; $i -lt $BACKUP_SRC_FILE_num; $i++ )
{
  Start-FileBackup $BACKUP_SRC_FILE[$i].BACKUP_SRC_PATH $BACKUP_SRC_FILE[$i].BACKUP_DST_PATH
}

