#gets the File To Compile as an external parameter... Defaults to a Test file...
Param( $FileToCompile = "NONE")

#cleans the terminal screen and sets the log file name...
Clear-Host
$LogFile = $FileToCompile + ".log"

#before continue check if the Compile File has any spaces in it...
if ($FileToCompile.Contains(" ")) {
    ""; "";
    Write-Host "ERROR!  Impossible to Compile! Your Filename or Path contains SPACES!" -ForegroundColor Red;
    "";
    Write-Host $FileToCompile -ForegroundColor Red;
    ""; "";
    return;
}

#first of all, kill MT Terminal (if running)... otherwise it will not see the new compiled version of the code...
Get-Process -Name terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Id -gt 0 } | Stop-Process

#fires up the Metaeditor compiler...
& "C:\Program Files (x86)\FPMarkets MT4 Terminal\metaeditor.exe" /compile:"$FileToCompile" /log:"$LogFile" /inc:"C:\Users\Kyle\AppData\Roaming\MetaQuotes\Terminal\B8925BF731C22E88F33C7A8D7CD3190E\MQL4" | Out-Null

#get some clean real state and tells the user what is being compiled (just the file name, no path)...
""; ""; ""; ""; ""
$JustTheFileName = Split-Path $FileToCompile -Leaf
Write-Host "Compiling........: $JustTheFileName"
""

#reads the log file. Eliminates the blank lines. Skip the first line because it is useless.
$Log = Get-Content -Path $LogFile | Where-Object { $_ -ne "" } | Select-Object -Skip 1

#Green color for successful Compilation. Otherwise (error/warning), Red!
$WhichColor = "Red"
$Log | ForEach-Object { if ($_.Contains("0 error(s), 0 warning(s)")) { $WhichColor = "Green" } }

#runs through all the log lines...
$Log | ForEach-Object {
    #ignores the ": information: error generating code" line when ME was successful
    if (-Not $_.Contains("information:")) {
        #common log line... just print it...
        if ($_.Contains(": warning")) {
            Write-Host $_ -ForegroundColor "yellow"
        }
        elseif ($_.Contains(": error")) {
            Write-Host $_ -ForegroundColor "red"
        }
        else {
            Write-Host $_ -ForegroundColor "white"
        }
    }
}

#get the MT Terminal back if all went well...
if ( $WhichColor -eq "Green") { & "C:\Program Files (x86)\FPMarkets MT4 Terminal\terminal64.exe" }