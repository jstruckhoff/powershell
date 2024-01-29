function Convert-All-FFMPEG {
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$InputExt,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputExt,

    [Parameter(Mandatory = $false, Position = 2)]
    [string]$OptionalSettings,

    [Parameter(Mandatory = $false, Position = 3)]
    [bool]$DeleteOriginalFile
  )

  $Files = Get-ChildItem -Filter ("*." + $InputExt) -Recurse
  if ($Files.Length -eq 0) {
    Write-Host "No files found matching extension" $InputExt -ForegroundColor Yellow
    Return
  }
  $ConvertDirectory = New-Item -Name "Converted" -ItemType "directory" -Force
  foreach ($File in $Files) {
    $NewFile = [io.path]::ChangeExtension($ConvertDirectory.FullName + '\' + $File.Name, ("." + $OutputExt))
    $ArgumentList = [System.Collections.ArrayList]@()
    $ArgumentList.Add("-i")
    $ArgumentList.Add("{0}" -f $File.FullName)
    if ($OptionalSettings -ne "") {
      foreach ($OptionalSetting in $OptionalSettings.Split(" ")) {
        $ArgumentList.Add($OptionalSetting)
      }
    }
    $ArgumentList.Add("{0}" -f $NewFile)
    & "ffmpeg.exe" $ArgumentList    		
    if ($LASTEXITCODE -eq 0) {
      Write-Host "Conversion Successful" -ForegroundColor Green
      if ($DeleteOriginalFile) {
        Remove-Item -Path $File
      }
    }
    else {
      Write-Host "Conversion Failed" -ForegroundColor Red
      Return $LASTEXITCODE
    }
  }
}
