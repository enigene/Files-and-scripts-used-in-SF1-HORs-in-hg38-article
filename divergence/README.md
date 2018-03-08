This is an example of commands that can be used to process sequences from one region (https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&position=chr6%3A58692241-59617260)

Currently manual operation. In UCSC Table Browser: get sequences from AS HOR track with specific name, export FASTA monomers to file
With filter (chromEnd - chromStart) >= 150
Add extra bases: 1 upstream and 0 downstream (CDS, All upper case)

NOTE: BED file exported from UCSC Table Browser are not sorted!

Correct FASTA names after export sequences from UCSC Genome Browser
`awk -F"_" '{gsub(/hg38|range=| 5.+$/,"");print $1 $5}' ./GJ211907.1-chr6-58692241-59617260.fasta > ./GJ211907.1-chr6-58692241-59617260-ed1.fasta`

From multiline to one line
`awk 'NR==1&&/^>/{printf("%s\n",$0)}NR>1&&/^>/{printf("\n%s\n",$0)}!/^>/{printf("%s",$0)}END{printf"\n"}' ./GJ211907.1-chr6-58692241-59617260-ed1.fasta > ./GJ211907.1-chr6-58692241-59617260-ed2.fasta`

Sort FASTA by name
`cat ./GJ211907.1-chr6-58692241-59617260-ed2.fasta | awk '/^>/{n=1;for(i=1;i<=NF;i++){printf("%s ",$i);if(i==NF)printf"\t"}}n&&!/[^ACGTN-]/{print;n=0}' | sort -k2V - | sed -e 's/ \t/\n/' > ./GJ211907.1-chr6-58692241-59617260-ed2-sorted.fasta`

Split FASTA seq to files by name
`for filename in $(find . -name "*-[0-9].fasta"); do dir_name=$(dirname "$filename"); awk '/^>/{n=1;for(i=1;i<=NF;i++){printf("%s ",$i);if(i==NF)printf"\t"}}n&&!/[^ACGTN\-]/{print;n=0}' "$filename" | awk '{n=substr($1,2);gsub(/\//,"_",n);sub(/\t/,"\n");print>>"'$dir_name'/"n".fas"}'; done`

Remove extra files
`find . \( -name "S1*.fas" ! -name "S1C6*.fas" -o -name "S1*.*_*.fas" \) -delete`

Count FASTA sequences
`find . -name "S1*.fas" -exec awk '/^>/{n++}END{print FILENAME,n}' {} >> seq-count.txt \;`

Make alignment
`./align.sh`

Calculate divergence rate
`find . -name "S1*-aln.fas" -exec sh -c 'awk -v rules=ggs -f "~/git/enigene/Divergence-rate/divergr.awk" {} > $(dirname {})/$(basename {} .fas)-divgr.txt' \;`

Create new file starting with line
`echo -e "HORname\tDivergence" > SF1-HOR-divergence-rate.tsv`

Gather stats and format file as tsv
`find . -name "*-divgr.txt" -exec sh -c 'awk "\$1~/^[0-9]+$/{num=\$1;name=\$2;div=\$3;printf(\"%s\t%.2f\n\",name,div)}" {} >> ./SF1-HOR-divergence-rate.tsv' \;`

Remove text with underscores
`sed -i'' -e 's/_.*_//' ./SF1-HOR-divergence-rate.tsv`

Get plot
`Rscript ./divgr-boxplot.R`
