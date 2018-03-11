# Tables with analysis of haplotypic position of HOR monomers of the first suprachromosomal family

The data were obtained with the [haplotable](https://github.com/enigene/haplotable) script.

The input data is FASTA alignment of alpha satellite monomers of SF1 HORs divided
into two groups of types A and B. Files with base substitutions in consensus that
were specified during processing are also presented.

Parameters specified during processing are:
```
haplotable.R -t 4 -s -i S1-master-HOR-manual-aln-171-with-div-cons-boxA-sorted-typeCons.fas -b boxA-J1-SF1-subs.tsv
haplotable.R -t 4 -s -i S1-master-HOR-manual-aln-171-with-div-cons-boxB-sorted-typeCons.fas -b boxB-J2-SF1-subs.tsv
```
The threshold for the number of similarities with type consensus is set to 4,
after which the sorting by monomer names was performed.

The output is present as HTML tables.
