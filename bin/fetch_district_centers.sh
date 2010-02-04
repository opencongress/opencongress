#!/bin/bash

#DEBUG="echo"
DATADIR="/data/govtrack/110/geo"

function download {
  echo "Downloading govtrack district centerpoints..."
  ${DEBUG} mkdir -p ${DATADIR} && ${DEBUG} cd ${DATADIR} && ${DEBUG} wget -nc -nd -O centers.json "http://www.govtrack.us/perl/wms/list-regions.cgi?dataset=http://www.rdfabout.com/rdf/usgov/congress/house/110&amp;fields=coord,area&amp;format=json&amp"
}

download
