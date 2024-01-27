function Convert-All-FFMPEG {
	param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$InputExt,

    [Parameter(Mandatory=$true, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputExt,

    [Parameter(Mandatory=$false, Position=2)]
    [string]$OptionalSettings,

    [Parameter(Mandatory=$false, Position=3)]
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
        if ($OptionalSettings) {
          $ArgumentList = "-i {0} {1} {2}" -f $File.FullName, $OptionalSettings, $NewFile
        }
        else {
          $ArgumentList = "-i {0} {1}" -f $File.FullName, $NewFile
        }
        $Split = $ArgumentList.Split(' ')
        & "ffmpeg.exe" $Split    		
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
