$SOURCE_PCAP_DIR = "Dataset/1_IoT_Trace_Dataset_Public"

if ($($args.Count) -ne 1) {
    Write-Host $($args.Count)
    Write-Host "[ERROR] Wrong format of command!"
    Write-Host "[INFO] For Linux: pwsh 1_Pcap2Session.ps1 <TYPE>"
    Write-Host "[INFO] <TYPE>: -s (session)"
} 
else {
    if ($($args[0]) -eq "-s") {
        Write-Host "[INFO] Spliting the PCAP file into each session"
        foreach ($f in Get-ChildItem $SOURCE_PCAP_DIR) {
            # For Linux
            mono ./Tool/SplitCap_2-1/SplitCap.exe -p 1080 -b 50000 -r $f -o ./Dataset/2_Processed_Dataset/PCAP_by_Session
            Get-ChildItem ./Dataset/2_Processed_Dataset/PCAP_by_Session | ?{$_.Length -eq 0} | Remove-Item
        }

        # Remove duplicate files
        Write-Host "[INFO] Removing duplicate files"

        # For Linux
        fdupes -rdN ./Dataset/2_Processed_Dataset/PCAP_by_Session/
    }
    else {
        Write-Host "[ERROR] Wrong format of command!"
        Write-Host "[INFO] For Windows: .\1_Pcap2Session.ps1 <TYPE>"
        Write-Host "[INFO] For Linux:   pwsh 1_Pcap2Session.ps1 <TYPE>"
        Write-Host "[INFO] <TYPE>:-s (session)"
    }
}