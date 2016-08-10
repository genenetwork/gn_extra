#! /bin/bash

rsync -va data/* pjotr@penguin2:data/genotype/ $*
