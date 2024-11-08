#!/bin/bash

PGMAJOR=
##--##
function opcaoInvalida() {
    echo "Opção inválida!"
}
##--##
function replicacao() {
    local OPCAO 
    function versaoPgMajor() {
        PGMAJOR=
        while [[ -z "$PGMAJOR" ]]; do
            echo -e "Informe a versão do PG_MAJOR (12, 13 ou 14): "
            read -r PGMAJOR
            case "$PGMAJOR" in
                12) PGMAJOR=12 && break;;
                13) PGMAJOR=13 && break;;
                14) PGMAJOR=14 && break;;
                *) echo "Versão incorreta, PGMAJOR precisa ser uma das versões citadas acima" && foo;;
            esac
        done
        echo -e "\t99) Menu"
    }

    configuracaoServerMaster() {
        DIR="/var/lib/pgsql/$PGMAJOR/conf.d"
        FILE="$DIR/rep.conf"
        POSTGRESQL_CONF="/var/lib/pgsql/14/data/postgresql.conf"
        echo "PGMAJOR = $PGMAJOR"
        if [[ ! -e "$DIR" ]]; then
            echo -e "Diretório de configuração não existe, criando arquivos"    
            mkdir -pm 0700 "$DIR"
            touch "$FILE"
            echo "cluster_name = 'sr0'" > "$FILE"
            echo "primary_slot_name = 'rs_sr0'" >> "$FILE"

            chmod 0600 "$FILE"
            chown postgres:postgres -R "$DIR"
        else
            echo -e "Diretório de configuração já existente, verificar arquivos no local $DIR"
        fi
        alterar_parametro() {
            local parametro="$1"
            local valor="$2"

            # Verifica se o parâmetro já está no arquivo, e se está comentado
            if grep -Eq "^[#]*\s*$parametro\s*=" "$POSTGRESQL_CONF"; then
                # Substitui a linha para ativar o parâmetro com o valor desejado
                sed -i "s|^[#]*\s*\($parametro\s*=\s*\).*|\1$valor|" "$POSTGRESQL_CONF"
            else
                # Adiciona o parâmetro e o valor ao final do arquivo, caso não exista
                echo "$parametro = $valor" >> "$POSTGRESQL_CONF"
            fi
        }

        # Alterar os parâmetros conforme especificado
        alterar_parametro "password_encryption" "md5"
        alterar_parametro "wal_level" "replica"
        alterar_parametro "max_wal_senders" "3"
        alterar_parametro "max_replication_slots" "2"
        alterar_parametro "include_dir" "'/var/local/pgsql/<VERSÃO MAJORITÁRIA>/conf.d'"

    echo "Parâmetros atualizados em $POSTGRESQL_CONF. Reinicie o PostgreSQL para que as alterações tenham efeito."

    }

    echo -e "OBS: Replicação por enquanto disponível no Postgres 12 ou superior"
    echo -e "Selecione uma opção: "
    echo -e "\t1) Instalar servidor master"
    echo -e "\t2) Verificar versão selecionada"
    echo -e "\t99) Menu"
    read -r OPCAO

    while true; do
        case "$OPCAO" in
            1) versaoPgMajor && configuracaoServerMaster && replicacao;;
            2) echo "$PGMAJOR" && replicacao;;
            99) main;;
            *) opcaoInvalida && replicacao;;
        esac
    done
}

function main() {
    function menu() {
        local OPCAO

        echo -e "Selecione uma opção: "
        echo -e "\t1) Replicação"
        echo -e "\t99) Sair"
        read -r OPCAO

        while true; do
            case "$OPCAO" in
                1) replicacao && sleep 5 && main ;;
                99) exit 0 ;;
                *) opcaoInvalida && main ;;
            esac
        done
    }

    menu
}

main