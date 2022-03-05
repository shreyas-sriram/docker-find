#!/usr/bin/env bash

# set -e

SCRIPT_NAME="docker-find"
LAYERS="layers"
LAYER_TAR_FILENAME="${LAYERS}.tar"

function search_history(){
    echo "Searching docker history"
    docker history ${image} --no-trunc | grep --color -i ${search_term}
}

function search_inspect(){
    echo "Searching docker inspect"
    docker inspect ${image} | grep --color -i ${search_term}
}

function save_and_untar_layers(){
    mkdir -p ${LAYERS}

    docker save ${image} -o ${LAYER_TAR_FILENAME}
    tar xf ${LAYER_TAR_FILENAME} -C ${LAYERS}
    
    layers=(${LAYERS}/*/)
    for layer in "${layers[@]}"; do
        mkdir ${layer}/layer
        tar xf ${layer}/layer.tar -C ${layer}/layer
    done
}

function search_layers(){
    save_and_untar_layers

    # grep search
    # strings search
}

function main(){
    echo "Searching ${image} for ${search_term}"
    
    # search_history
    # search_inspect
    search_layers
}

if [[ "$#" -ne 2 ]]; then
    echo "Script requires 2 arguments: ./${SCRIPT_NAME} [image] [search-term]"
    exit
fi

image="${1}"
search_term="${2}"

main
