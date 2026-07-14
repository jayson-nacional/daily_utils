$null = New-Item -Path (Join-Path $PSScriptRoot "compressed") -ItemType Directory -Force

Get-ChildItem -Path . -File | ForEach-Object {
	$fullPath = $_.FullName
	$baseName = $_.BaseName
	$ext = $_.Extension.ToLower()
	
	switch ($ext) {
		{ $_ -in ".jpg", ".jpeg", ".heic" }
		{
			Write-Host "Processing image: $fullPath"
			magick "$fullPath" -interlace Plane -sampling-factor 4:2:0 -define jpeg:dct-method=float -quality 85 "$($PSScriptRoot)/compressed/$($baseName).jpg"
			
			# Restore metadata
			exiftool -tagsFromFile "$fullPath" -FileCreateDate -FileModifyDate "$($PSScriptRoot)/compressed/$($baseName).jpg"
		}
		default
		{
			Write-Host "Will do nothing for file with extension $ext"
		}
	}
}
Write-Host "Operation succeeded!"

[console]::beep(2000, 3000)% 
