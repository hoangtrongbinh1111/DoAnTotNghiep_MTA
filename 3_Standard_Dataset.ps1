$SESSIONS_COUNT_LIMIT_MIN = 0
$SESSIONS_COUNT_LIMIT_MAX = 60000000
$TRIMED_FILE_LEN = 784

# Arguments
$TYPE = $($args[0])
$SORT = $($args[1])

function processSession($SOURCE_SESSION_DIR) {
    Write-Host "[INFO] If Sessions more than $SESSIONS_COUNT_LIMIT_MAX we only select the largest $SESSIONS_COUNT_LIMIT_MAX."
    Write-Host "[INFO] Finally Selected Sessions:"

    $dirs = Get-ChildItem $SOURCE_SESSION_DIR -Directory
    foreach ($d in $dirs) {
        $files = Get-ChildItem $d.FullName
        $count = $files.count
        if ($count -gt $SESSIONS_COUNT_LIMIT_MIN) {             
            Write-Host "$($d.Name) $count"       
            if ($count -gt $SESSIONS_COUNT_LIMIT_MAX) {
                if ($SORT -eq "-s") {
                    $files = $files | Sort-Object Length -Descending | Select-Object -First $SESSIONS_COUNT_LIMIT_MAX
                }
                elseif ($SORT -eq "-u")  {
                    $files = $files | Select-Object -First $SESSIONS_COUNT_LIMIT_MAX
                }
                $count = $SESSIONS_COUNT_LIMIT_MAX
            }
            $files = $files | Resolve-Path
            $test  = $files | Get-Random -count ([int]($count / 10))
            $train = $files | ?{$_ -notin $test}     

            $path_test  = "Dataset\3_Standard_Dataset\FilteredSession\Test\$($d.Name)"
            $path_train = "Dataset\3_Standard_Dataset\FilteredSession\Train\$($d.Name)"
            Write-Host "[INFO] $path_train"
            New-Item -Path $path_test -ItemType Directory -Force
            New-Item -Path $path_train -ItemType Directory -Force

            Copy-Item $test -destination $path_test        
            Copy-Item $train -destination $path_train
        }
    }

    Write-Host "[INFO] All files will be trimed to $TRIMED_FILE_LEN length and if it's even shorter we'll fill the end with 0x00..."
    
    $paths = @(('Dataset\3_Standard_Dataset\FilteredSession\Train', 'Dataset\3_Standard_Dataset\TrimedSession\Train'), ('Dataset\3_Standard_Dataset\FilteredSession\Test', 'Dataset\3_Standard_Dataset\TrimedSession\Test'))
    foreach ($p in $paths) {
        foreach ($d in Get-ChildItem $p[0] -Directory) {
            New-Item -Path "$($p[1])\$($d.Name)" -ItemType Directory -Force
            foreach ($f in Get-ChildItem $d.fullname) {
                $content = [System.IO.File]::ReadAllBytes($f.FullName)
                $len = $f.length - $TRIMED_FILE_LEN
                # if ($len -gt 0) {        
                #     $content = $content[0..($TRIMED_FILE_LEN - 1)]        
                # }
                # elseif ($len -lt 0) {        
                #     $padding = [Byte[]] (,0x00 * ([math]::abs($len)))
                #     $content = $content += $padding
                # }
                # Set-Content -Value $content -AsByteStream -Path "$($p[1])\$($d.Name)\$($f.Name)"
                if ($len -gt 0) {        
                    $content = $content[0..($TRIMED_FILE_LEN - 1)]    
                    Set-Content -Value $content -AsByteStream -Path "$($p[1])\$($d.Name)\$($f.Name)"      
                }
                elseif (([math]::abs($len)) -lt 300) {        
                    $padding = [Byte[]] (,0x00 * ([math]::abs($len)))
                    $content = $content += $padding
                    Set-Content -Value $content -AsByteStream -Path "$($p[1])\$($d.Name)\$($f.Name)"
                }
            }        
        }
    }
}


if ($($args.Count) -ne 2) {
    Write-Host "[ERROR] Wrong format of command!"
    Write-Host "[INFO] For Linux:   pwsh 2_ProcessSession.ps1 <TYPE>"
    Write-Host "[INFO] <TYPE>: -l (Layer 7)"
    Write-Host "[INFO] <SORT>: -s (Sorting) | -u (No sorting)"
}
else {    
    if ($TYPE -eq "-l") {
        processSession "Dataset\2_Processed_Dataset\PCAP_by_MAC"
    }
    else {
        Write-Host "[ERROR] Wrong format of command!"
        Write-Host "[INFO] For Linux: pwsh 2_ProcessSession.ps1 <TYPE>"
        Write-Host "[INFO] <TYPE>: -l (Layer 7)"
        Write-Host "[INFO] <SORT>: -s (Sorting) | -u (No sorting)"
    }
}