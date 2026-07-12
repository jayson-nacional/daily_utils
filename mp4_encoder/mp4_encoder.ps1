$null = New-Item -Path (Join-Path $PSScriptRoot "compressed") -ItemType Directory -Force

Get-ChildItem -Path . -File | ForEach-Object {
	$fullPath = $_.FullName
	$baseName = $_.BaseName
	$ext = $_.Extension

	switch ($ext) {
		{ $_ -in ".mp4", "mov"}
		{
			Write-Host "Processing file: $fullPath"
			HandBrakeCLI -i "$fullPath" -o "$($PSScriptRoot)/compressed/$($baseName).mp4" --preset="Fast 1080p30" -e x265 -E av_aac  -q 22 --optimize --non-anamorphic
		}
		default
		{
			Write-Host "Will do nothing for file with extension $ext"
		}
	}
}
