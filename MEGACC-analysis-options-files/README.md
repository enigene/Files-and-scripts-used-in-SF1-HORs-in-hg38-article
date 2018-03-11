# MEGACC analysis options files

The path to the file `infer_ME_nucleotide.mao` is specified in the options of
MEGACC when creating a Newick tree:
```bash
find . -name "*.fasta" -exec sh -c 'megacc -n -a ~/git/enigene/MEGACC-analysis-options-files/infer_ME_nucleotide.mao -d {} -o {} 1>/dev/null' \;
```

The path to the file `muscle_align_nucleotide.mao` is specified in the options
of MEGACC when aligning the sequences:
```bash
megacc -n -f Fasta -a ~/git/enigene/MEGACC-analysis-options-files/muscle_align_nucleotide.mao -d input.fasta -o output-alignment.fasta 1>/dev/null
```

We use the last command in the script, which before the alignment, temporarily
changes the names of the sequences to avoid problems with the same names:
```bash
#!/bin/bash

for f in $(find . -name "*.fasta"); do

# Get file name without extention
fbase=$(basename "$f" .fasta)
dir_name=$(dirname "$f")

# Add numbers to FASTA names (temporary add numbers to names to prevent troubles with non-unique names)
awk '/^>/{printf("%s.%d\n",$0,++n)}!/[^ACGTN-]/{print}' "$f" > _tmp.fasta

# Align
megacc -n -f Fasta -a ~/git/enigene/MEGACC-analysis-options-files/muscle_align_nucleotide.mao -d _tmp.fasta -o _tmp_aln 1>/dev/null

# From multiline to oneline and remove temporary numbers from names
awk 'NR==1&&/^>/{printf("%s\n",$0)}NR>1&&/^>/{printf("\n%s\n",$0)}!/^>/{printf("%s",$0)}END{printf"\n"}' _tmp_aln.fasta | sed -e "s/.[0-9]\+\$//" - > "$dir_name/$fbase"-aln.fasta

# Remove temporary files
rm _tmp.fasta
rm _tmp_aln.fasta

done
```
