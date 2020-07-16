#!/bin/bash

function die() {
  msg=$1
  echo "********"
  echo "* ${msg}"
  exit 110
}

function do_book() {
  book=$1
  recipe=$2
  col=$3
  
  base_path="${root_dir}/${book}/${col}/baked-book-metadata/${col}"

  baked_path="${base_path}/collection.baked.xhtml"
  metadata_json_path="${base_path}/collection.baked-metadata.json"
  metadata_xml_path="${base_path}/collection.baked-metadata.json.xml"
  temp="./temp.json.xml"

  if [[ ! -f "${metadata_xml_path}" ]]; then
    echo "<data><![CDATA[" > "${temp}"
    cat "${metadata_json_path}" >> "${temp}"
    echo "]]></data>" >> "${temp}"
    
    ./xsltproc3.bash ./jsonToXml.xsl "${temp}" "${metadata_xml_path}"
  fi

  if [[ -f "${baked_path}" ]]; then

    echo "Extracting ${book}"
    ./xsltproc3.bash ./extract-exercises.xsl "${baked_path}" "./exercises/${book}.xhtml" "bookName=${book}" "metadataPath=${metadata_xml_path}" || die "Failed to extract ${book}"
  
  else
    echo "ERROR: ${book} does not appear to be baked because the following file does not exist: ${baked_path}"
  fi
}

root_dir=$1
[[ -d "${root_dir}" ]] || die "ERROR: The first argument needs to be a path to the output-producer-service data dir (the result of using the bakery cli) directory where all of the books are already baked"


[[ -d "./exercises" ]] || mkdir "./exercises"



do_book microbiology               microbiology                       col12087   katalyst01.cnx.org    
do_book accounting-vol-1           accounting                         col25448   easyvm5.cnx.org       
do_book accounting-vol-2           accounting                         col25479   easyvm5.cnx.org       
do_book history                    history                            col11740   easyvm5.cnx.org       
do_book business-ethics            business-ethics                    col25722   easyvm5.cnx.org       
# do_book american-government-2e     american-government                col26739   easyvm5.cnx.org       


# None of these had anything interesting
#
# # do_extract chemistry-2e               
# # do_extract chemistry-atoms-first-2e   
# # do_extract anatomy                    
# # do_extract biology-2e                 
# # do_extract apbiology                  
# # do_extract concepts-biology           
# do_extract microbiology               
# do_extract physics                    
# do_extract apphysics                  
# do_extract u-physics-vol1             
# do_extract u-physics-vol2             
# do_extract u-physics-vol3             
# # do_extract pl-u-physics-vol1          
# # do_extract pl-u-physics-vol2          
# # do_extract pl-u-physics-vol3          
# do_extract hsphysics                  
# do_extract entrepreneurship           
# do_extract college-success            
# do_extract aphistory                  
# do_extract psychology-2e              
# do_extract prealgebra-2e              
# do_extract elementary-algebra-2e      
# do_extract intermediate-algebra-2e    
# do_extract hs-statistics              
# do_extract astronomy                  
# do_extract principles-management      
# do_extract organizational-behavior    
# do_extract accounting-vol-1           
# do_extract accounting-vol-2           
# do_extract business-ethics            
# do_extract business-law               
# do_extract intro-business             
# do_extract econ-2e                    
# do_extract macroecon-2e               
# do_extract macroeconap-2e             
# do_extract microecon-2e               
# do_extract microeconap-2e             
# do_extract sociology-2e               
# do_extract history                    
# do_extract american-government-2e     
# do_extract statistics                 
# do_extract business-statistics        
# do_extract calculus-vol1              
# do_extract calculus-vol2              
# do_extract calculus-vol3              
# do_extract college-algebra            
# do_extract precalculus                
# do_extract algebra-trigonometry       

