# for ratio in $(seq 0.3 0.1 1.0); do
#     nonHDR_file="Example_NonHDR.tif"
#     nonHDR_out="Example_NonHDR_${ratio}.heic"
#     swift HDR_iOS17.swift "$nonHDR_file" "$nonHDR_out" "$ratio" "1"
# done
for ratio in $(seq 3 1 10); do
    nonHDR_file="Example_NonHDR.tif"
    formatted_ratio=$(printf "%02d" $ratio)
    nonHDR_out="Example_NonHDR_${formatted_ratio}.heic"
    swift HDR_iOS17.swift "$nonHDR_file" "$nonHDR_out" "0.$ratio" "1"
done

# for ratio in $(seq 6 1 10); do
#     nonHDR_file="Example_HDR"
#     formatted_ratio=$(printf "%02d" $ratio)
#     nonHDR_out="Example_HDR_${formatted_ratio}.heic"
#     swift HDR_iOS17.swift "$nonHDR_file" "$nonHDR_out" "0.$ratio" "1"
# done

for ratio in $(seq 0.6 0.05 1.0); do
    nonHDR_file="Example_HDR.tif"
    formatted_ratio=$(printf "%.2f" $ratio | tr -d '.')
    nonHDR_out="Example_HDR_${formatted_ratio}.heic"
    swift HDR_iOS17.swift "$nonHDR_file" "$nonHDR_out" "$ratio" "6"
done

