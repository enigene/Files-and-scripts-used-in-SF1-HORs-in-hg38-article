# Divergence of selected SF1 HORs

Here are the scripts and a step-by-step description of the data preparation process and
the calculation of the divergence for the monomers obtained from the [custom track](../track)
of the UCSC Genome Browser.

![Divergence rate of selected SF1 HORs](SF1-HOR-divergence-rate-boxplot.png)

This is an example of commands that can be used to process sequences from one region
of hg38 assembly [chr6:58692241-59617260](https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&position=chr6%3A58692241-59617260).

1. Currently manual operation. In UCSC Table Browser: choose __group__ Custom Track
and __track__ HMMER SF1 HORs t281 and set filter for specific __name__ (in this example `S1C6H1L*`) and
lenght __(chromEnd - chromStart)__ >= 150, and __output format__ as sequence to file
(in this example __output file__ is named `GJ211907.1-chr6-58692241-59617260.fasta`),
with following __Sequence Retrieval Options__: CDS, One FASTA record per region
with 1 extra base upstream and 0 downstream. __Sequence Formatting Options__: All upper case.

2. Correct FASTA names after export sequences from UCSC Genome Browser
`awk -F"_" '{gsub(/hg38|range=| 5.+$/,"");print $1 $5}' ./GJ211907.1-chr6-58692241-59617260.fasta > ./GJ211907.1-chr6-58692241-59617260-ed1.fasta`

3. From multiline to one line
`awk 'NR==1&&/^>/{printf("%s\n",$0)}NR>1&&/^>/{printf("\n%s\n",$0)}!/^>/{printf("%s",$0)}END{printf"\n"}' ./GJ211907.1-chr6-58692241-59617260-ed1.fasta > ./GJ211907.1-chr6-58692241-59617260-ed2.fasta`

4. Sort FASTA by name _NOTE: BED file exported from UCSC Table Browser are not sorted!_
`cat ./GJ211907.1-chr6-58692241-59617260-ed2.fasta | awk '/^>/{n=1;for(i=1;i<=NF;i++){printf("%s ",$i);if(i==NF)printf"\t"}}n&&!/[^ACGTN-]/{print;n=0}' | sort -k2V - | sed -e 's/ \t/\n/' > ./GJ211907.1-chr6-58692241-59617260-ed2-sorted.fasta`

5. Split FASTA seq to files by name
`for filename in $(find . -name "*-[0-9].fasta"); do dir_name=$(dirname "$filename"); awk '/^>/{n=1;for(i=1;i<=NF;i++){printf("%s ",$i);if(i==NF)printf"\t"}}n&&!/[^ACGTN\-]/{print;n=0}' "$filename" | awk '{n=substr($1,2);gsub(/\//,"_",n);sub(/\t/,"\n");print>>"'$dir_name'/"n".fas"}'; done`

6. Remove extra files
`find . \( -name "S1*.fas" ! -name "S1C6*.fas" -o -name "S1*.*_*.fas" \) -delete`

7. Count FASTA sequences
`find . -name "S1*.fas" -exec awk '/^>/{n++}END{print FILENAME,n}' {} >> seq-count.txt \;`

8. Make alignment
`./align.sh` — in this [script](align.sh) we use [MEGACC](https://www.megasoftware.net/) with [MEGACC analysis options files](MEGACC-analysis-options-files/).

9. Calculate divergence rate with [Divergence rate script](https://github.com/enigene/Divergence-rate)
`find . -name "S1*-aln.fas" -exec sh -c 'awk -v rules=ggs -f "~/git/enigene/Divergence-rate/divergr.awk" {} > $(dirname {})/$(basename {} .fas)-divgr.txt' \;`

10. Create new file starting with line
`echo -e "HORname\tDivergence" > SF1-HOR-divergence-rate.tsv`

11. Gather stats and format file as tsv
`find . -name "*-divgr.txt" -exec sh -c 'awk "\$1~/^[0-9]+$/{num=\$1;name=\$2;div=\$3;printf(\"%s\t%.2f\n\",name,div)}" {} >> ./SF1-HOR-divergence-rate.tsv' \;`

12. Remove text with underscores
`sed -i'' -e 's/_.*_//' ./SF1-HOR-divergence-rate.tsv`

13. Get plot with this [script](divgr-boxplot.R)
`Rscript ./divgr-boxplot.R`
