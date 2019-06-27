#!/bin/bash

BASE=./$(uuid)
export NXF_HOME=${BASE}/home
export NXF_WORK=${BASE}/work
export NXF_TEMP=${BASE}/temp
LOGFILE=${BASE}/nextflow.log
export CAPSULE_CACHE_DIR=/opt/nextflow/.nextflow/capsule
export NXF_DIST=/opt/nextflow/.nextflow/framework

usage() {
        echo $(basename $0): Query rfam using the farm
        echo $(basename $0) [options] fasta_file
        echo -e Options:
	echo -e "\t" -l,--local: run locally, as opposed to on the farm
        echo -e "\t" -o,--output: the output directory where the results will be stored. Default is current directory.
        echo -e "\t" -d,--debug: do not delete temporary files "(debug purposes)"
        echo -e "\t" -h,--help: show this help
}

OUTPUT="."
DEBUG="NO"
PROFILE="farm"
while [ $# -gt 0 ]
do
  key="$1"
  case $key in
      -o|--output)
      OUTPUT="$2"
      shift # past argument
      shift # past value
      ;;
      -l|--local)
      PROFILE="local"
      shift # past argument
      ;;
      -d|--debug)
      DEBUG=YES
      shift # past argument
      ;;
      -h|--help)
      usage
      exit 0
      ;;
      *)    # must be query file 
      QUERY="$key"
      shift
      ;;
  esac
done

if [[ ! -r $QUERY ]]
then
	echo "Query file is not a readable file: $QUERY"
	usage
	exit 1
fi

if [ -z $OUTPUT ]
then
	echo "Output unspecified"
	usage
	exit 1
fi

#Create working directories
mkdir -p ${NXF_HOME} ${NXF_WORK} ${NXF_TEMP}
if [ $? != 0 ]
then
	echo Could not create directory in $(pwd)
	exit 1
fi

#Run nextflow
nextflow -log $LOGFILE -c ${FARM_RFAM_NEXTFLOW_CONFIG} run "/opt/farm-rfam/rfam.nf" -profile $PROFILE --query $QUERY --output $OUTPUT

#cleanup
if [[ "$DEBUG" != "YES" ]] 
then
	rm -rf ${BASE}
fi
