#!/bin/bash

##--##
function foo() {
    echo "Hello World"
}

function main() {
    function menu() {
        local OPCAO

        echo -e "Selecione uma opção: "
        echo -e "\t1) Echo hello world"
        echo -e "\t2) Sair"
        read -r OPCAO

        while true; do
            case "$OPCAO" in
                1) foo && sleep 5 && main ;;
                2) exit 0 ;;
                *) echo "Opção inválida! Encerrando script" && exit 1 ;;
            esac
        done
    }

    menu
}

main