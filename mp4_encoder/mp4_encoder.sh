mkdir -p "$(pwd)/encoded"
mkdir -p "$(pwd)/thumbnails"
mkdir -p "$(pwd)/compressed"

for file in $(pwd)/*; do
	echo "Processing $file"

	if [ -f "$file" ]; then
		ext="${file##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

		case "$ext" in
            mp4|mov)
				# Encode to mp4 x265
                echo "Processing video: $file"
				HandBrakeCLI -i "$file" -o "$(pwd)/encoded/$(basename ${file%.*}).mp4" --preset="Fast 1080p30" -e x265 -q 22 -E av_aac --optimize --non-anamorphic --keep-metadata

				# Generate thumbnail
				echo "Processing thumbnail"
				ffmpeg -ss 00:00:01 -i "$(pwd)/encoded/$(basename ${file%.*}).mp4" -vframes 1 "$(pwd)/thumbnails/$(basename ${file%.*}).jpg"

				# Embed thumbnail
				ffmpeg -y -i "$(pwd)/encoded/$(basename ${file%.*}).mp4" -i "$(pwd)/thumbnails/$(basename ${file%.*}).jpg" -map 0 -map 1 -c copy -disposition:v:1 attached_pic "$(pwd)/compressed/$(basename ${file%.*}).mp4"

				# Restore metadata
				exiftool -tagsFromFile "$file" -FileCreateDate -FileModifyDate "$(pwd)/compressed/$(basename ${file%.*}).mp4"

				;;
            *)
                echo "Skipping non-video file: $file"
                ;;
        esac
	fi
done

# Clear temp files
echo "Removing temp files..."
rm -r "$(pwd)/encoded"
rm -r "$(pwd)/thumbnails"
echo "Operation succeeded..."
echo -e "\a"
