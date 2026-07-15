$currentWorkingDirectory = $ExecutionContext.SessionState.Path.CurrentLocation.Path
$compressedTargetPath = Join-Path -Path $currentWorkingDirectory -ChildPath "compressed"
New-Item -ItemType Directory -Path $compressedTargetPath -Force | Out-Null

Get-ChildItem -Path . -File | ForEach-Object {
	$fullPath = $_.FullName
	$baseName = $_.BaseName
	$ext = $_.Extension.ToLower()
	
	switch ($ext) {
		{ $_ -in ".jpg", ".jpeg", ".heic" }
		{
			Write-Host "Processing image: $fullPath"
			magick "$fullPath" -strip -interlace Plane -sampling-factor 4:2:0 -define jpeg:dct-method=float -quality 85 "$($compressedTargetPath)/$($baseName).jpg"
			
			# Restore metadata
			exiftool -tagsFromFile "$fullPath" -FileCreateDate -FileModifyDate "$($compressedTargetPath)/$($baseName).jpg"
		}
		default
		{
			Write-Host "Will do nothing for file with extension $ext"
		}
	}
}
Write-Host "Operation succeeded!"

[console]::beep(2000, 3000)