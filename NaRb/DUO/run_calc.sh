#!/bin/bash

# --- Script to run DUO with modified checkpoint and linelist paths ---

# 1. Check if an argument (output file name prefix) was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <output_file_name_prefix>"
  echo "Example: $0 run_coupled"
  exit 1
fi

# 2. Assign the first argument to a variable (this is the base name like 'run_coupled')
output_file_name="$1"
# !!! IMPORTANT: Make sure your new input content is saved in this file !!!
input_file="abs.inp"

# 3. Define output directories
out_dir="out"
chk_dir="chk"
linelist_dir="lines" # New directory for linelists

# 4. Create output directories if they don't exist
mkdir -p "$out_dir" "$chk_dir" "$linelist_dir"

# 5. Construct the specific filenames/paths needed
duo_output_file="$out_dir/$output_file_name.out"
# Define the value to be inserted after 'filename' in DUO input (e.g., chk/run_coupled)
duo_chk_filename_value="$chk_dir/$output_file_name"
# Define the value to be inserted after 'linelist' in DUO input (e.g., linelist/run_coupled)
duo_linelist_filename_value="$linelist_dir/$output_file_name"

echo "--- Starting DUO Calculation for prefix: $output_file_name ---"

# 6. Run DUO:
#    - Use sed to replace the 'filename' line in the input file with '$duo_chk_filename_value'
#    - Use sed again to replace the 'linelist' line with '$duo_linelist_filename_value'
#    - Use # as sed delimiter to easily handle / in the paths
#    - Pipe the modified input directly to duo.x
#    - Redirect duo.x output to the designated file
echo "Running DUO..."
echo "  Setting internal checkpoint filename to: $duo_chk_filename_value"
echo "  Setting internal linelist filename to:  $duo_linelist_filename_value"

# Chain the sed commands: first replace filename, then replace linelist
sed "s#^\(\s*filename\s\+\).*#\1$duo_chk_filename_value#" "$input_file" | \
sed "s#^\(\s*linelist\s\+\).*#\1$duo_linelist_filename_value#" | \
../../duo.x > "$duo_output_file"

# Check if DUO ran successfully
if [ $? -ne 0 ]; then
  echo "Error: DUO calculation failed! Check '$duo_output_file' for details."
  exit 1
fi

echo "DUO finished successfully."
echo "Output file: $duo_output_file"
echo "Checkpoint file(s) should be in: $chk_dir (based on prefix '$output_file_name')"
echo "Linelist file(s) should be in:  $linelist_dir (named '$output_file_name.*')"
echo "--- Calculation completed for prefix: $output_file_name ---"

exit 0
