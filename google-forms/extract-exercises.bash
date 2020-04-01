#!/bin/bash

function die() {
  msg=$1
  echo "********"
  echo "* ${msg}"
  exit 110
}

function do_extract() {
  book=$1
  
  baked_path="${cnx_recipes_data_dir}/${book}/collection.baked.xhtml"
  [[ -f "${baked_path}" ]] || die "ERROR: ${book} does not appear to be baked because the following file does not exist: ${baked_path}"

  echo "Extracting ${book}"
  ./xsltproc3.bash ./extract-exercises.xsl "${baked_path}" "./exercises/${book}.json" "bookName=${book}" || die "Failed to extract ${book}"
}

cnx_recipes_data_dir=$1
[[ -d "${cnx_recipes_data_dir}" ]] || die "ERROR: The first argument needs to be a path to the cnx-recipes/data/ directory where all of the books are already baked"


[[ -d "./exercises" ]] || mkdir "./exercises"

do_extract apbiology
do_extract psychology-2e
do_extract apphysics
do_extract chemistry-2e
do_extract macroeconap-2e
do_extract microeconap-2e



# do_extract anatomy
# do_extract accounting-vol-1
# do_extract accounting-vol-2
# do_extract american-government-2e
# do_extract astronomy
# do_extract biology-2e
# do_extract biology
# do_extract business-ethics
# do_extract business-law
# do_extract business-statistics
# do_extract calculus-vol1
# do_extract calculus-vol2
# do_extract calculus-vol3
# do_extract chemistry-atoms-first-2e
# # do_extract ~college-algebra~
# do_extract concepts-biology
# do_extract econ-2e
# do_extract elementary-algebra
# do_extract entrepreneurship
# do_extract history
do_extract hs-statistics
# do_extract hsphysics
# do_extract intermediate-algebra
# do_extract intro-business
# do_extract macroecon-2e
# do_extract microbiology
# do_extract microecon-2e
# do_extract organizational-behavior
# do_extract physics-draft
do_extract physics
# do_extract prealgebra-2e
# do_extract precalculus
# do_extract principles-management
# do_extract sociology-2e
# do_extract statistics
# do_extract u-physics-vol1
# do_extract u-physics-vol2
# do_extract u-physics-vol3
