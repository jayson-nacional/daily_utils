$null = New-Item -Path (Join-Path $PSScriptRoot "encoded") -ItemType Directory -Force
$null = New-Item -Path (Join-Path $PSScriptRoot "thumbnails") -ItemType Directory -Force
$null = New-Item -Path (Join-Path $PSScriptRoot "compressed") -ItemType Directory -Force

Get-ChildItem -Path . -File | ForEach-Object {
	$fullPath = $_.FullName
	$baseName = $_.BaseName
	$ext = $_.Extension.ToLower()

	switch ($ext) {
		{ $_ -in ".mp4", ".mov" }
		{
			# Encode to mp4 x265
			Write-Host "Processing video: $fullPath"
			HandBrakeCLI -i "$fullPath" -o "$($PSScriptRoot)/encoded/$($baseName).mp4" --preset="Fast 1080p30" -e x265 -E av_aac  -q 22 --optimize --non-anamorphic --keep-metadata
			
			# Generate thumbnail
			Write-Host "Processing thumbnail"
			ffmpeg -ss 00:00:01 -i "$($PSScriptRoot)/encoded/$($baseName).mp4" -vframes 1 "$($PSScriptRoot)/thumbnails/$($baseName).jpg"
			
			# Embed thumbnail
			ffmpeg -y -i "$($PSScriptRoot)/encoded/$($baseName).mp4" -i "$($PSScriptRoot)/thumbnails/$($baseName).jpg" -map 0 -map 1 -c copy -disposition:v:1 attached_pic "$($PSScriptRoot)/compressed/$($baseName).mp4"
			
			# Restore metadata
			exiftool -tagsFromFile "$fullPath" -FileCreateDate -FileModifyDate "$($PSScriptRoot)/compressed/$($baseName).mp4"
		}
		default
		{
			Write-Host "Will do nothing for file with extension $ext"
		}
	}
}

# Clear temp files
Write-Host "Removing temp files..."
Remove-Item -Path (Join-Path $PSScriptRoot "encoded") -Recurse -Force
Remove-Item -Path (Join-Path $PSScriptRoot "thumbnails") -Recurse -Force
Write-Host "Operation succeeded!"

[console]::beep(2000, 3000)
