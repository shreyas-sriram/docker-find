#!/usr/bin/env bash

# set -e

SCRIPT_NAME="docker-find"
LAYERS="layers"
LAYER_TAR_FILENAME="${LAYERS}.tar"

# clean up before starting
function clean_up(){
    printf "[+] Cleaning existing files\n\n"

    rm -rf ${LAYERS}
}

# find image locally
# if not available locally, pull it
function find_image(){
    printf "[+] Searching '${image}' locally\n\n"
    
    if [[ "$(docker images -q ${image} 2> /dev/null)" == "" ]]; then
        printf "[-] Docker image: '${image}' not found locally\n"
        
        printf "[+] Pulling image: '${image}'\n"
        docker pull -q ${image}
    fi

    printf "[+] Found '${image}' locally\n\n"
}

# search for `search_term` in `docker history`
function search_history(){
    printf "[+] Searching docker history\n\n"

    docker history ${image} --no-trunc | grep --color -i ${search_term}
}

# search for search_term in `docker inspect`
function search_inspect(){
    printf "[+] Searching docker inspect\n\n"
    
    docker inspect ${image} | grep --color -i ${search_term}
}

# save image layers using `docker save` and untar each layers
function save_and_untar_layers(){
    printf "[+] Saving and extracting layers\n\n"

    mkdir -p ${LAYERS}

    docker save ${image} -o ${LAYER_TAR_FILENAME}
    tar xf ${LAYER_TAR_FILENAME} -C ${LAYERS}
    
    layers=(${LAYERS}/*/)
    for layer in "${layers[@]}"; do
        mkdir -p ${layer}layer # /layers/<layer-name>/layer
        tar xf ${layer}/layer.tar -C ${layer}/layer
    done
}

# recursive grep search
function grep_search(){
    printf "[+] Running 'grep' on layer files\n\n"

    grep -HnrIi --color "${search_term}" ${LAYERS}/
}

# recursive strings search
function strings_search(){
    printf "[+] Running 'strings' on layer files\n\n"

    find ${LAYERS}/ -type f \( ! -iname "*.tar" \) | xargs strings -f | grep --color -i "${search_term}"
}

# search for `search_term` in extracted layers
function search_layers(){
    save_and_untar_layers

    printf "[+] Searching layers\n\n"

    grep_search
    strings_search
}

function main(){
    clean_up

    find_image

    printf "[+] Searching '${image}' for '${search_term}'\n\n"
    
    search_history
    search_inspect
    search_layers
}

if [[ "$#" -ne 2 ]]; then
    printf "[-] Script requires 2 arguments: ./${SCRIPT_NAME} [image] [search-term]\n\n"
    exit
fi

image="${1}"
search_term="${2}"

main
