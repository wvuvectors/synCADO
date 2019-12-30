# synCADO v1.0
**SYNteny Comparison Across Diverse Organisms**


## Description
`synCADO` is a data visualization tool designed to quickly depict the arrangement of orthologous genes across multiple genomes.

Prokaryotes often utilize blocks of cotranscribed genes called operons to carry out similar functional tasks. A texbook example of operons (literally) is the *lac* operon of *Escherichia coli*.

synCADO generates a Web-friendly (HTML5) graphic showing the arrangmenet of a user-defined set of orthologous genes across multiple genomes, in order to aid in identifying conservation of synteny. Intervening blocks of genes are compressed to emphasize target genes.


## Requirements
`synCADO` requires three data sets from the user in order to run properly. See the "Configuring synCADO input" section below for more detailed information about each set.

1. A plain text file containing the genomes of interest (*genomes*), as NCBI Nucleotide RefSeq identifiers. **synCADO 1.0 analyzes individual scaffolds/contigs and works best on closed genomes.** Although multiple contigs from an unclosed genome can be depicted in `synCADO`, it is not possible to assess synteny across unordered contigs in a genome.
1. A plain text file containing the families of particular interest (*targets*), as NCBI Protein RefSeq identifiers.
1. A plain-text file containing the ortholog groups (*families*). 

The software is built in bash and perl and requires no special dependencies.


## Attribution
`synCADO` was written by [Timothy Driscoll](http://www.driscollMML.com/) at West Virginia University, Morgantown, WV USA. The concept for a synteny-aware search algorithm arose from discussions and work with numerous other researchers, most notably Joseph Gillespie and Victoria Verhoeve (University of Maryland), and Adam Pollio (West Virginia University).


## Using synCADO

###### QuickStart

Run the `synCADO` program, passing it the three required files and (if desired) a project name:

`synCADO -g genomes.txt -t targets.txt -f familes.txt -o project_name`

The primary output of `synCADO ` is an HTML file (*project_name*.html) visually depicting the targets of interest in the context of each genome. This HTML file that can be opened in any modern Web browser. Several additional text files are also generated (see below for more information). All synCADO ouput files are written to a single output directory (*project_name*).


## Configuring synCADO input

*Note: please see the demo/ directory in synCADO for examples of the files described below.*

### _The genomes file_

Use the `-g` argument to pass the path to a file that describes your genomes of interest. Each line of the genomes file contains information for a single genome, as described by either one or two tab-delimited elements. The first element is a required NCBI Nucleotide RefSeq identifier for the genome. Alternatively, instead of a RefSeq ID, you can supply the path to a local gff3 file for the genome. The second element on each line is an optional text label to apply to the genome (if absent, the RefSeq ID is used as a label). Blank lines and lines in the file that begin with a comment mark (#) are ignored. For example:

<table>
<tr><td>#RefSeq_ID</td><td>Label</td></tr>
<tr><td>NZ_JFKF01000201.1</td><td>Rickettsia buchneri pREIS2</td></tr>
<tr><td>gff_local/NZ_AP013028.1.gff</td><td>wCle</td></tr>
<tr><td> NC_008011.1</td><td>Lawsonia intracellularis str. PHE/MN1-00</td></tr>
<tr><td> NC_007797.1</td><td>Anaplasma phagocytophilum HZ</td></tr>
<tr><td>NC_000913.3</td><td>Escherichia coli str. K-12 substr. MG1655</td></tr>
</table>

Note that **synCADO 1.0 analyzes individual scaffolds/contigs and works best on closed genomes.** _synCADO **will indeed** work with individual contigs/scaffolds from an unclosed genome_, as long as your genome file contains the actual contig accession and **not** the master record.

**IMPORTANT**: since there is no way *ab initio* to determine colinearity of separate contigs, synCADO will treat each individual contig or scaffold as if it were a separate genome. However, you can safely include multiple contigs from the same genome.


### _The targets file_

Use the `-t` argument to pass the path to a file that contains your specific families of interest (*targets*). Each line of the targets file contains a single target, as described by 1-3 tab-delimited elements. The first element is the ID of any feature in the family of interest (required). **This can be a feature ID from any genome in the input set**. `synCADO` will automatically extract the orthologs from all other input genomes and label them accordingly.

The second element on each line is an optional text label for the target (*e.g.*, the gene locus tag). Labels are optional but highly recomended; if absent, the family is labeled with its internal id which is not very useful.

The third element on each line is an optional color for the family in RRGGBB hex format (if absent, the family is colored F3F3F3, or light gray). For example:

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

Note: Blank lines and lines in the targets file that begin with a comment mark (#) are ignored.


### _The families file_

Use the `-f` argument to pass the path to a file that contains your ortholog groups (*families*). Each line of the families file contains all of the IDs within a single family, separated by tabs. The first element of each line must be a unique family ID. For example:

<table>
<tr><td>#family_id</td><td>member_1</td><td>member_2</td><td>member_3</td><td>member_4</td><td>...</td></tr>
<tr><td>0</td><td>FEATURE_1</td><td>FEATURE_2</td><td>FEATURE_3</td><td>FEATURE_4</td></tr>
<tr><td>1</td><td>FEATURE_5</td><td>FEATURE_6</td><td>FEATURE_7</td></tr>
<tr><td>2</td><td>FEATURE_8</td><td>FEATURE_9</td><td>FEATURE_10</td><td>FEATURE_11</td></tr>
</table>

`synCADO` v1.0 includes several tools for converting data from other software into the *families* format. First, [orthoMCL](https://orthomcl.org/orthomcl/) data can be converted for synCADO using the `synCADO_convert_from_orthomcl.pl` script (in the sbin/perl directory):

`synCADO_convert_from_orthomcl.pl < orthomcl_output.end > syncado_families.txt`

Alternatively, ortholog groups can be generated in synCADO format using `synCADOfb`, which relies on API access to [orthoDB](https://www.orthodb.org/), [NCBI](https://www.ncbi.nlm.nih.gov/), and [EBI](https://www.ebi.ac.uk/) (for ID conversion). See below for more information about using the `synCADOfb` utility. **Due to the time required to generate families *de novo*, this task is maintained separately from the main synCADO program.**


## All arguments

> ##### -g \<*filepath*\>
> **REQUIRED**. Path to a tab-delimited **genome file** describing the genomes to be analyzed.

> ##### -f \<*filepath*\>
> **REQUIRED**. Path to a **families file** containing ortholog groups built from the input genomes.

> ##### -t \<*filepath*\>
> **REQUIRED**. Path to a **targets file** describing the target families to be highlighted in the synCADO output.

> ##### -o \<*string*\>
> *OPTIONAL*. String to label the output. [default: synCADO_out]

> ##### -a \<*string*\>
> *OPTIONAL BUT RECOMMENDED*. Any feature ID to identify an OG to use as the anchor point for each genome. This OG will be added to the list of targets (unless already present) and used to anchor the start (left) of the graphic.

> ##### -h
> Writes a short help document to STDOUT.

> ##### -v
> Writes the synCADO version to STDOUT.

> ##### -d
> *OPTIONAL*. Flag to retain all temporary files (for debugging purposes). 


## synCADOfb

orthoDB's *tab* format is a more expanded format that contains one **feature** (gene or protein) per row:

<table>
<tr><td>og_id</td><td>og_name</td><td>level_taxid</td><td>organism_taxid</td><td>organism_name</td><td>int_prot_id</td><td>pub_gene_id</td><td>description</td></tr>
<tr><td>1331at780</td><td>IS110 family transposase</td><td>780</td><td>783_0</td><td>Rickettsia rickettsii</td><td>783_0:000304</td><td>RSA_RS04180</td><td>IS110 family transposase</td></tr>
<tr><td>1331at780</td><td>IS110 family transposase</td><td>780</td><td>1105111_0</td><td>Rickettsia amblyommatis str. GAT-30V</td><td>1105111_0:0002c8</td><td>H8K5S6_RICAG</td><td>H8K5S6_RICAG</td></tr>
</table>




## Release
For detailed information about synCADO versions, please see the RELEASE file included in the top-level **synCADO** directory of every release.



## License
`synCADO` is released under the GNU GPL v3 license. Please see the LICENSE file included in the top-level **synCADO** directory of every release.
