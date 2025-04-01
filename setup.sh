#!/bin/bash

# Função para excluir todos os usuários e seus arquivos no sistema
function excluir_todos_usuarios() {
    echo "Excluindo todos os usuários e seus arquivos..."
    
    # Obtém todos os usuários no sistema, exceto root, e os exclui junto com seus arquivos
    for usuario in $(cut -d: -f1 /etc/passwd | grep -vE '^(root|nobody)$'); do
        echo "Excluindo usuário: $usuario"
        userdel -r $usuario
    done
}

# Função para excluir diretórios, grupos e usuários existentes
function excluir_existentes() {
    # Excluir os diretórios se existirem
    echo "Excluindo diretórios existentes..."
    rm -rf /publico /adm /ven /sec

    # Excluir os grupos se existirem
    echo "Excluindo grupos existentes..."
    for grupo in GRP_ADM GRP_VEN GRP_SEC; do
        if getent group $grupo > /dev/null 2>&1; then
            groupdel $grupo
        fi
    done
}

# Função para criar os diretórios
function criar_diretorios() {
    echo "Criando diretórios..."
    mkdir -p /publico /adm /ven /sec
    chmod 777 /publico
    chmod 770 /adm /ven /sec
    chown root:root /publico /adm /ven /sec
}

# Função para criar os grupos
function criar_grupos() {
    echo "Criando grupos..."
    groupadd GRP_ADM
    groupadd GRP_VEN
    groupadd GRP_SEC
}

# Função para criar os usuários
function criar_usuarios() {
    echo "Criando usuários..."

    # Grupo GRP_ADM
    useradd carlos -m -s /bin/bash -G GRP_ADM
    useradd maria -m -s /bin/bash -G GRP_ADM
    useradd joao -m -s /bin/bash -G GRP_ADM

    # Grupo GRP_VEN
    useradd debora -m -s /bin/bash -G GRP_VEN
    useradd sebastiana -m -s /bin/bash -G GRP_VEN
    useradd roberto -m -s /bin/bash -G GRP_VEN

    # Grupo GRP_SEC
    useradd josefina -m -s /bin/bash -G GRP_SEC
    useradd amanda -m -s /bin/bash -G GRP_SEC
    useradd rogerio -m -s /bin/bash -G GRP_SEC
}

# Função para definir as permissões nos diretórios
function definir_permissoes() {
    echo "Definindo permissões nos diretórios..."

    # Permissões no diretório /publico (todos têm acesso total)
    chmod 777 /publico

    # Permissões no diretório /adm (somente GRP_ADM tem permissão total)
    chmod 770 /adm
    chown root:GRP_ADM /adm

    # Permissões no diretório /ven (somente GRP_VEN tem permissão total)
    chmod 770 /ven
    chown root:GRP_VEN /ven

    # Permissões no diretório /sec (somente GRP_SEC tem permissão total)
    chmod 770 /sec
    chown root:GRP_SEC /sec

    # Garantir que os usuários de outros grupos não tenham permissão nos diretórios dos outros grupos
    setfacl -m g:GRP_ADM:--- /ven /sec
    setfacl -m g:GRP_VEN:--- /adm /sec
    setfacl -m g:GRP_SEC:--- /adm /ven
}

# Main: Chamar as funções
excluir_todos_usuarios
excluir_existentes
criar_diretorios
criar_grupos
criar_usuarios
definir_permissoes

echo "Configuração concluída com sucesso!"
