# synCADO v0.4
**SYNteny Comparison Across Diverse Organisms**


## Description
`synCADO` is a data visualization tool designed to quickly depict the arrangement of orthologous genes across multiple genomes.

Prokaryotes often utilize blocks of cotranscribed genes called operons to carry out similar functional tasks. A texbook example of operons (literally) is the *lac* operon of *Escherichia coli*.

synCADO generates a Web-friendly (HTML5) graphic showing the arrangmenet of a user-defined set of orthologous genes across multiple genomes, in order to aid in identifying conservation of synteny. Intervening blocks of genes are compressed to emphasize target genes.


## Requirements
`synCADO` requires three data sets from the user in order to run properly:

1. A tab-delimited text file containing the genomes of interest (*genomes*) as NCBI Nucleotide RefSeq identifiers. Each line contains a single RefSeq ID (required) and a title (optional). **synCADO 1.0 analyzes individual scaffolds/contigs and works best on closed genomes.** It is not possible to assess synteny across unordered contigs in a genome.
1. A file containing the orthologs of interest (*targets*) as NCBI Protein RefSeq identifiers. Each line contains a single RefSeq ID (required), a short text label, and a hex color code. IDs can be derived from any genome included in the input set, even a mixture of genomes. synCADO does the work of identifying the orthologs in other genomes.
1. A file containing the ortholog groups (*families*). `synCADO` accepts orthoDB *tab* format by default, but can be configured to use orthoMCL *end* files as well. 

The software is built in bash and perl and requires no special dependencies except a working internet connection.


## Attribution
`synCADO` was written by [Timothy Driscoll](http://www.driscollMML.com/) at West Virginia University, Morgantown, WV USA. The concept for a synteny-aware search algorithm arose from discussions and work with numerous other researchers, most notably Joseph Gillespie and Victoria Verhoeve (University of Maryland), and Adam Pollio (West Virginia University).


## Using synCADO

###### QuickStart

Run the `synCADO` program, passing it the three required files and (if desired) a project name:

`synCADO -g genomes.txt -t targets.txt -f familes.txt -o project_name`

`synCADO ` will produce a single output file, *project_name.synCADO.html*, that can be opened in any modern Web browser.


## Configuring synCADO input

*Note: please see the demo/ directory in synCADO for examples of the files described below.*

### _The genomes file_

Use the `-g` argument to pass the file that describes your genomes of interest. Each line of the genomes file contains information for a single genome, as described by either one or two tab-delimited elements. The first element is a required NCBI Nucleotide RefSeq identifier for the genome. Alternatively, instead of a RefSeq ID, you can use a path to a local gff3 file for the genome. The second element is an optional text label to apply to the genome (if absent, the RefSeq ID is used as a label). Lines in the file that begin with a comment mark (#) are ignored. For example:

<table>
<tr><td>#RefSeq_ID</td><td>Label</td></tr>
<tr><td>NZ_JFKF01000201.1</td><td>Rickettsia buchneri pREIS2</td></tr>
<tr><td>gff_local/NZ_AP013028.1.gff</td><td>wCle</td></tr>
<tr><td> NC_008011.1</td><td>Lawsonia intracellularis str. PHE/MN1-00</td></tr>
<tr><td> NC_007797.1</td><td>Anaplasma phagocytophilum HZ</td></tr>
<tr><td>NC_000913.3</td><td>Escherichia coli str. K-12 substr. MG1655</td></tr>
</table>

Note that _synCADO will work with individual contigs/scaffolds from an unclosed genome_ as long as your genome file contains the actual contig accession and **not** the master record.

**IMPORTANT**: since there is no way *ab initio* to determine colinearity of separate contigs, synCADO will treat each contig as if it were a separate genome. However, you can safely include multiple contigs from the same genome.


### _The targets file_

Use the `-t` argument to pass the file that contains your specific ortholog groups of interest (*targets*). Each line of the targets file contains a single target, as described by 1-3 tab-delimited elements. The first element is the ID of a feature in the family of interest (required). **This must be a feature ID from any genome in the input set**. The second element is an optional text label for the target (*e.g.*, the gene locus tag). Labels are optional but highly recomended; if absent, the family is labeled with its internal id which is not very useful. The third element is an optional color for the family in RRGGBB hex format (if absent, the family is colored F3F3F3, or light gray). For example:

<table>
<tr><td>#family_member</td><td>label</td><td>color</td></tr>
<tr><td>WP_011526084.1</td><td>DnaA</td><td>FF8AD8</td></tr>
<tr><td>WP_015353734.1</td><td>BioB</td><td>0096FF</td></tr>
<tr><td>WP_011526506.1</td><td>BioF</td><td>FF9300</td></tr>
<tr><td>WP_011526507.1</td><td>BioH</td><td>008F00</td></tr>
<tr><td>WP_011526508.1</td><td>BioC</td><td>73FDFF</td></tr>
<tr><td>WP_011526509.1</td><td>BioD</td><td>D4FB79</td></tr>
<tr><td>WP_011526510.1</td><td>BioA</td><td>FF2600</td></tr>
</table>

Note: Lines in the file that begin with a comment mark (#) are ignored.


### _The families file_

Use the `-f` argument to pass the file that contains your ortholog groups (*families*). This file must be a tab-delimited text file, with each family on a separate row. The first column contains a unique family ID, with subsequent columns containing the feature IDs that comprise the family. For example:

<table>
<tr><td>0</td><td>FEATURE_1</td><td>FEATURE_2</td><td>FEATURE_3</td><td>FEATURE_4</td></tr>
<tr><td>1</td><td>FEATURE_4</td><td>FEATURE_5</td><td>FEATURE_6</td></tr>
<tr><td>2</td><td>FEATURE_7</td><td>FEATURE_8</td><td>FEATURE_9</td><td>FEATURE_10</td></tr>
</table>

`synCADO` can also be configured to accept orthoDB's *tab* format by including the -c flag anywhere on the command line:

`synCADO -g genomes.txt -f orthoDB_familes.txt -t targets.txt -o project_name -c`

orthoDB's *tab* format is a more expanded format that contains one **feature** (gene or protein) per row:

<table>
<tr><td>og_id</td><td>og_name</td><td>level_taxid</td><td>organism_taxid</td><td>organism_name</td><td>int_prot_id</td><td>pub_gene_id</td><td>description</td></tr>
<tr><td>1331at780</td><td>IS110 family transposase</td><td>780</td><td>783_0</td><td>Rickettsia rickettsii</td><td>783_0:000304</td><td>RSA_RS04180</td><td>IS110 family transposase</td></tr>
<tr><td>1331at780</td><td>IS110 family transposase</td><td>780</td><td>1105111_0</td><td>Rickettsia amblyommatis str. GAT-30V</td><td>1105111_0:0002c8</td><td>H8K5S6_RICAG</td><td>H8K5S6_RICAG</td></tr>
</table>

NOTE: the `-c` flag calls the perl script `synCADO_convert_OGs.pl`; this script can also be run separately to interconvert between the formats outside of the full synCADO program.



## All arguments

> ##### -g \<*filepath*\>
> **REQUIRED**. Path to a tab-delimited **genome file** describing the genomes to be analyzed.

> ##### -f \<*filepath*\>
> **REQUIRED**. Path to a **families file** containing the constructed ortholog groups, in orthoMCL .end format.

> ##### -t \<*filepath*\>
> **REQUIRED**. Path to a **targets file** describing the target OGs to be highlighted in the synCADO output.

> ##### -o \<*string*\>
> *OPTIONAL*. String to label the output html file. [default: synCADO_p]

> ##### -a \<*string*\>
> *OPTIONAL*. Any feature ID to identify an OG to use as the anchor point for each genome. This OG will be added to the list of targets (if necessary) and used to anchor the start (left) of the graphic.

> ##### -c
> *OPTIONAL*. Enables the use of an orthoDB-formatted families file as input. 



## Release
For detailed information about synCADO versions, please see the RELEASE file included in the top-level **synCADO** directory of every release.



## License
`synCADO` is released under the GNU GPL v3 license. Please see the LICENSE file included in the top-level **synCADO** directory of every release.
