# synCADO v0.3
**SYNteny Comparison Across Diverse Organisms**


## Description
`synCADO` is a data visualization tool designed to quickly depict the arrangement of orthologous genes across multiple genomes.

Prokaryotes often utilize blocks of cotranscribed genes called operons to carry out similar functional tasks. A texbook example of operons (literally) is the *lac* operon of *Escherichia coli*.

synCADO generates a Web-friendly (HTML5) graphic showing the arrangmenet of a user-defined set of orthologous genes across multiple genomes, in order to aid in identifying conservation of synteny. Intervening blocks of genes are compressed to emphasize target genes. .


## Requirements
`synCADO` requires three data sets from the user in order to run properly:

1. A file containing the genomes of interest (*genomes*), as NCBI Nucleotide RefSeq identifiers, one ID per line. **synCADO 1.0 works best on closed genomes.**
2. A file containing the ortholog groups (*families*). `synCADO` accepts orthoDB *tab* format by default, but can be configured to use orthoMCL *end* files as well. 
3. A file containing the orthologs of interest (*targets*), as NCBI Protein RefSeq identifiers, one id per line. IDs can be derived from any genome identified in (1), even a mixture of genomes.

The software is built in bash and perl and requires no special dependencies except a working internet connection.


## Attribution
`synCADO` was written by [Timothy Driscoll](http://www.driscollMML.com/) at West Virginia University, Morgantown, WV USA. The concept for a synteny-aware search algorithm arose from discussions and work with numerous other researchers, most notably Joseph Gillespie and Victoria Verhoeve (University of Maryland), and Adam Pollio (West Virginia University).


## Using synCADO

###### QuickStart

Run the `synCADO` program, passing it the three required files and (if desired) a project name:

`synCADO -g genomes.txt -f familes.txt -t targets.txt -o project_name`

`synCADO ` will produce a single output file, *project_name.html*, that can be opened in any modern Web browser.


## Configuring synCADO input

### _The genomes file_

Use the `-g` argument to pass the file that describes your genomes of interest. Each line of the genomes file contains information for a single genome, as described by either one or two tab-delimited elements. The first element is a required NCBI Nucleotide RefSeq identifier for the genome. The second element is an optional text label to apply to the genome (if absent, the RefSeq ID is used as a label). Lines in the file that begin with a comment mark (#) are ignored. For example:

<table>
<tr><td>#RefSeq_ID</td><td>Label</td></tr>
<tr><td>NC_007109.1</td><td>Rickettsia_felis_URRWXCal2</td></tr>
<tr><td>CP004889.1</td><td>Rickettsia_prowazekii_str._Breinl</td></tr>
<tr><td> CP002428.1</td><td></td></tr>
<tr><td> NC_013532.1</td><td>Anaplasma_centrale_str._Israel</td></tr>
<tr><td>NZ_JFKF01000124.1</td><td> Rickettsia_buchneri_strain_ISO7_contig124</td></tr>
</table>

Note that _synCADO will work with individual contigs/scaffolds from an unclosed genome_, as long as the genome file contains the actual contig accession and **not** the master record.

**IMPORTANT**: since there is no way *ab initio* to determine colinearity of separate contigs, synCADO will treat each contig as if it were a separate genome.


### _The families file_

Use the `-f` argument to pass the file that contains your ortholog groups (OGs, or *families*). By default, synCADO expects OGs in orthoMCL's *end* format, which contains one OG per row. For example:

<table>
<tr><td>ORTHOMCL0 (6 genes,6 taxa):	 seq1(TAX1) seq2(TAX2) seq3(TAX3) seq4(TAX4) seq5(TAX5) seq6(TAX6)</td></tr>
<tr><td>ORTHOMCL1 (5 genes,4 taxa):	 seq7(TAX1) seq8(TAX2) seq9(TAX3) seq10(TAX4) seq11(TAX4)</td></tr>
<tr><td>ORTHOMCL2 (3 genes,3 taxa):	 seq12(TAX1) seq13(TAX2) seq14(TAX3)</td></tr>
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


### _The targets file_

Use the `-t` argument to pass the file that contains your specific ortholog groups of interest (*targets*). Each line of the targets file contains a single target, as described by 1-3 tab-delimited elements. The first element is a required OG identifier. This can be any feature ID from any genome that is found in the OG. The second element is an optional text label for the OG (*e.g.*, the gene locus tag). Labels are optional but highly recomended; if absent, the OG is labeled with its internal id, which is often less than useful. The third element is an optional color for the OG, in RRGGBB hex format (if absent, the OG is colored light gray). Lines in the file that begin with a comment mark (#) are ignored. For example:

<table>
<tr><td>#OG_member</td><td>Label</td><td>Color</td></tr>
<tr><td>WP_012880845.1</td><td>dnaA</td><td>FFD479</td></tr>
<tr><td>WP_012880468.1</td><td>glmS</td><td>330033</td></tr>
<tr><td>WP_011114509.1</td><td>glmM</td><td>11bb11</td></tr>
<tr><td>WP_012880247.1</td><td>glmU</td><td>00EE00</td></tr>
<tr><td>WP_086934965.1</td><td>Tpase</td><td>73FDFF</td></tr>
</table>



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
