# farm_rfam

Use the farm to query rfam with big query file

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://gitlab.internal.sanger.ac.uk/sanger-pathogens/farm_rfam/blob/master/LICENSE)   


## Contents
  * [Introduction](#introduction)
  * [Installation](#installation)
  * [Run](#Run)
  * [License](#license)
  * [Feedback/Issues](#feedbackissues)


## Introduction
This software, based on nextflow and rfam_scan.pl (RFAM 11), splits the query file in chunks of 8kb, query rfam on each chunck and combined the results together.

## Installation

### Pre-requisite
farm_rfam has the folloing pre requisite:
 * nextflow version 19.04.1.5072 or compatible
 * RFAM 11

Both of these have their own dependencies.  See Vagrantfile for details of ubuntu installation.
   
### From github
Download and unarchive the desired release from github: ```https://github.com/sanger-pathogens/farm_rfam/releases```

## Run

### Help
To get the help message run
```
farm_rfam.sh -h
```

### Running a query on sanger farm
```
farm_rfam.sh <fasta_query_file>
```
This will produce a file in the current directory called ```rfam_annotations.txt``` containing the results

### Specifying an output directory for the results
```
farm_rfam.sh -o <outputdir> <fasta_query_file>
```
This will create the result file ```rfam_annotations.txt``` in directory ```<outputdir>```

### Running locally
```
farm_rfam.sh -l <fasta_query_file>
```
This will disable the use of the farm.


## Tests and continuous integration

There is no CI/CD at the moment.

There is a small test data sample available in test_data.
If running the query.fasta file through, the output should be the same as rfam_annotations.txt

## License
farm_rfam is free software, licensed under [GPLv3](https://gitlab.internal.sanger.ac.uk/sanger-pathogens/farm_rfam/blob/master/LICENSE).

# Feedback/Issues
Please report any issues to the [issues page](https://gitlab.internal.sanger.ac.uk/sanger-pathogens/farm_rfam/issues) or email path-help@sanger.ac.uk.

