Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:TestDirectory = "akamaipowershell"
$Script:NewDirName = "temp"
$Script:NewFileName = "temp.txt"
$Script:NewFileContent = "new"
$Script:SymlinkFileName = "symlink.txt"
$Script:RenamedFileName = "renamed.txt"

Describe 'Safe NSAPI Tests' {
    BeforeDiscovery {
        ### New-NetstorageDirectory
        $Script:NewDir = New-NetstorageDirectory -Path "/$TestDirectory/$NewDirName"
        it 'New-NetstorageDirectory creates successfully' {
            $NewDir | Should -Match 'successful'
        }

        ### Upload-NetstorageFile
        $NewFileContent | Out-File $NewFileName
        it 'Upload-NetstorageFile lists content' {
            { Upload-NetstorageFile -LocalPath $NewFileName -RemotePath "/$TestDirectory/$NewDirName/$NewFileName" } | Should -Not -Throw
        }
    }

    ### Dir-NetstorageDirectory
    $Script:Dir = Dir-NetstorageDirectory -Path $TestDirectory
    it 'Dir-NetstorageDirectory lists content' {
        $Dir.count | Should -Not -Be 0
    }

    ### List-NetstorageDirectory
    $Script:List = List-NetstorageDirectory -Path $TestDirectory
    it 'List-NetstorageDirectory lists content' {
        $List.count | Should -Not -Be 0
    }

    ### Du-NetstorageDirectory
    $Script:Du = Du-NetstorageDirectory -Path $TestDirectory
    it 'Du-NetstorageDirectory returns stats' {
        $Du.files | Should -Not -BeNullOrEmpty
    }

    ### Symlink-NetstorageFile
    $Script:Symlink = Symlink-NetstorageObject -Path "/$TestDirectory/$NewDirName/$SymlinkFileName" -Target "/$TestDirectory/$NewDirName/$NewFileName"
    it 'Symlink-NetstorageObject creates a symlink' {
        $Symlink | Should -Match 'successful'
    }

    ### Download-NetstorageFile
    it 'Download-NetstorageFile downloads successfully' {
        { Download-NetstorageFile -RemotePath "/$TestDirectory/$NewDirName/$NewFileName" -LocalPath $NewFileName } | Should -Not -Throw
        $DownloadedContent = Get-Content $NewFileName
        $DownloadedContent | Should -Be $NewFileContent
    }

    AfterAll {
        ### Set-NetstorageFileMTime
        $Script:MTime = Set-NetstorageFileMTime -Path "/$TestDirectory/$NewDirName/$NewFileName" -mtime 0
        it 'Set-NetstorageFileMTime sets mtime' {
            $MTime | Should -Match 'successful'
        }

        ### Stat-NetstorageDirectory
        $Script:Stat = Stat-NetstorageObject -Path "/$TestDirectory/$NewDirName/$NewFileName"
        it 'Stat-NetstorageObject gets object stats' {
            $Stat.name | Should -Be $NewFileName
        }

        ### Rename-NetstorageFile
        $Script:Rename = Rename-NetstorageFile -Path "/$TestDirectory/$NewDirName/$NewFileName" -NewFilename $RenamedFileName
        it 'Rename-NetstorageFile renames a file' {
            $Rename | Should -Match 'renamed'
        }

        ### Remove-NetstorageFile
        $Script:RemoveFile = Remove-NetstorageFile -Path "/$TestDirectory/$NewDirName/$SymlinkFileName"
        it 'Remove-NetstorageFile removes a file' {
            $RemoveFile | Should -Match 'deleted'
            { Remove-NetstorageFile -Path "/$TestDirectory/$NewDirName/$RenamedFileName" } | Should -not -Throw
        }

        ### Remove-NetstorageDirectory
        $Script:RemoveDir = Remove-NetstorageDirectory -Path "/$TestDirectory/$NewDirName" -ImReallyReallySure
        it 'Remove-NetstorageDirectory removes a dir' {
            $RemoveDir | Should -Match "quick-delete scheduled"
        }

        Remove-Item $NewFileName -Force
    }
    
}
