#!/bin/bash

for f in $(find . -name "S1*.fas"); do

# Get file name without extention
fbase=$(basename "$f" .fas)
dir_name=$(dirname "$f")

# Add numbers to FASTA names (temporary add numbers to names to prevent troubles with non-unique names)
awk '/^>/{printf("%s.%d\n",$0,++n)}!/[^ACGTN-]/{print}' "$f" > _tmp.fas

# Align
megacc -n -f Fasta -a ~/t/megacc/muscle_align_nucleotide.mao -d _tmp.fas -o _tmp_aln 1>/dev/null

# From multiline to oneline and remove temporary numbers from names
awk 'NR==1&&/^>/{printf("%s\n",$0)}NR>1&&/^>/{printf("\n%s\n",$0)}!/^>/{printf("%s",$0)}END{printf"\n"}' _tmp_aln.fasta | sed -e "s/.[0-9]\+\$//" - > "$dir_name/$fbase"-aln.fas

# Remove temporary files
rm _tmp.fas
rm _tmp_aln.fasta

done
