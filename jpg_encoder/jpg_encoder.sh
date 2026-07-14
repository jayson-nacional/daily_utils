mkdir -p "$(pwd)/compressed"

for file in $(pwd)/*; do
	echo "Processing $file"

	if [ -f "$file" ]; then
		ext="${file##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

		case "$ext" in
            jpg|jpeg|heic)
                echo "Processing image: $file"
				magick "$file" -interlace Plane -sampling-factor 4:2:0 -define jpeg:dct-method=float -quality 85 "$(pwd)/compressed/$(basename ${file%.*}).jpg"

				# Restore metadata
				exiftool -tagsFromFile "$file" -FileCreateDate -FileModifyDate "$(pwd)/compressed/$(basename ${file%.*}).jpg"
				;;
            *)
                echo "Skipping non-image file: $file"
                ;;
        esac
	fi
done
