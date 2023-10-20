# #!/bin/bash

# # Check if the directory path is provided
# if [ "$#" -ne 2 ]; then
#     echo "Usage: $0 directory_path compress_ratio"
#     exit 1
# fi

# # Check if the provided argument is a directory
# if [ ! -d "$1" ]; then
#     echo "Error: $1 is not a directory"
#     exit 1
# fi

# mkdir "$1""/heic"
# # List all files in the directory
# for file in "$1"/*
# do
#     if [ -f "$file" ]; then
#     # Extracting directory part
#         dir="${file%/*}"
#         # Extracting filename without extension (DSC01831)
#         filename="${file##*/}"
#         basename="${filename%.*}"
#         # Extracting extension part (.avif)
#         extension="${filename##*.}"
#         extension=".$extension"
#         # filename="${file%.*}"
#         hdr_name="./$dir/heic/""$basename""_hdr.heic"
#         swift HDR_iOS17.swift $file $hdr_name $2
#     fi
# done

#!/bin/bash

# Check if the directory path is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 directory_path compress_ratio num_of_threads"
    exit 1
fi

# Check if the provided argument is a directory
if [ ! -d "$1" ]; then
    echo "Error: $1 is not a directory"
    exit 1
fi

mkdir -p "$1""/heic"

# Define the function to be run in parallel
process_file() {
    file="$1"
    ratio="$2"
    dir="${file%/*}"
    filename="${file##*/}"
    basename="${filename%.*}"
    hdr_name="./$dir/heic/""$basename""_hdr.heic"
    swift HDR_iOS17.swift "$file" "$hdr_name" "$ratio"
}

export -f process_file

# Find all files in the directory and pass them to xargs
find "$1" -type f | xargs -I {} -P $3 bash -c 'process_file "$@"' _ {} "$2"
