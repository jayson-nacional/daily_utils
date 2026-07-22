$currentWorkingDirectory = $ExecutionContext.SessionState.Path.CurrentLocation.Path
$encodedTargetPath = Join-Path -Path $currentWorkingDirectory -ChildPath "encoded"
$thumbnailsTargetPath = Join-Path -Path $currentWorkingDirectory -ChildPath "thumbnails"
$compressedTargetPath = Join-Path -Path $currentWorkingDirectory -ChildPath "compressed"

New-Item -ItemType Directory -Path $encodedTargetPath -Force | Out-Null
New-Item -ItemType Directory -Path $thumbnailsTargetPath -Force | Out-Null
New-Item -ItemType Directory -Path $compressedTargetPath -Force | Out-Null

Get-ChildItem -Path . -File | ForEach-Object {
	$fullPath = $_.FullName
	$baseName = $_.BaseName
	$ext = $_.Extension.ToLower()

	switch ($ext) {
		{ $_ -in ".mp4", ".mov" }
		{
			# Encode to mp4 x265
			Write-Host "Processing video: $fullPath"
			HandBrakeCLI -i "$fullPath" -o "$($encodedTargetPath)/$($baseName).mp4" --preset="Fast 1080p30" -e x265 -E av_aac  -q 22 --optimize --non-anamorphic --keep-metadata
			
			# Generate thumbnail
			Write-Host "Processing thumbnail"
			ffmpeg -ss 00:00:01 -i "$($encodedTargetPath)/$($baseName).mp4" -vframes 1 "$($thumbnailsTargetPath)/$($baseName).jpg"
			
			# Embed thumbnail
			ffmpeg -y -i "$($encodedTargetPath)/$($baseName).mp4" -i "$($thumbnailsTargetPath)/$($baseName).jpg" -map 0 -map 1 -c copy -disposition:v:1 attached_pic "$($compressedTargetPath)/$($baseName).mp4"
			
			# Restore metadata
			exiftool -tagsFromFile "$fullPath" -FileCreateDate -FileModifyDate "$($compressedTargetPath)/$($baseName).mp4"
		}
		default
		{
			Write-Host "Will do nothing for file with extension $ext"
		}
	}
}

# Clear temp files
Write-Host "Removing temp files..."
Remove-Item -Path $encodedTargetPath -Recurse -Force
Remove-Item -Path $thumbnailsTargetPath -Recurse -Force
Write-Host "Operation succeeded!"

[console]::beep(2000, 3000)