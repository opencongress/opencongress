#!/bin/bash
# We expect this file to exist in bin/ under the Rails install.
# Data will then go into data/

#DEBUG="echo"
SCRIPT_PATH=$(cd ${0%/*} && pwd -P)
DATADIR="${1}/govtrack/110/geo"

function download {
  echo "Downloading govtrack district centerpoints..."
  ${DEBUG} mkdir -p ${DATADIR} && ${DEBUG} cd ${DATADIR} && ${DEBUG} wget -nd -O centers.json "http://www.govtrack.us/perl/wms/list-regions.cgi?dataset=http://www.rdfabout.com/rdf/usgov/congress/house/110&amp;fields=coord,area&amp;format=json&amp"
}

download
