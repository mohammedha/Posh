# 256-Color Foreground & Background Charts
$esc = $([char]27)
Write-Output "`n$esc[1;4m256-Color Foreground & Background Charts$esc[0m"
foreach ($fgbg in 38, 48) {
    # foreground/background switch
    foreach ($color in 0..255) {
        # color range
        #Display the colors
        $field = "$color".PadLeft(4)  # pad the chart boxes with spaces
        Write-Host -NoNewLine "$esc[$fgbg;5;${color}m$field $esc[0m"
        #Display 6 colors per line
        if ( (($color + 1) % 6) -eq 4 ) { Write-Output "`r" }
    }
    Write-Output `n
}
