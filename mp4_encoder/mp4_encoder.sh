mkdir -p "$(pwd)/compressed"

for file in $(pwd)/*; do
	echo "Processing $file"

	if [ -f "$file" ]; then
		ext="${file##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

		case "$ext" in
            mp4|mov)
                echo "Processing video: $file"
				HandBrakeCLI -i "$file" -o "$(pwd)/compressed/$(basename ${file%.*}).mp4" --preset="Fast 1080p30" -e x265 -q 22 -E av_aac --optimize --non-anamorphic
                ;;
            *)
                echo "Skipping non-video file: $file"
                ;;
        esac
	fi
done
