#!/bin/bash

# Colores
LBLUE='\033[1;34m'  # Azul claro
GREEN='\033[1;32m'  # Verde negrita
NC='\033[0m'        # Sin color

# Mostrar el logo
echo -e "\n${LBLUE}
██████╗ ██╗      ██████╗  ██████╗██╗  ██╗██████╗  ██████╗ ██╗  ██╗
██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗╚██╗██╔╝
██████╔╝██║     ██║   ██║██║     █████╔╝ ██████╔╝██║   ██║ ╚███╔╝ 
██╔══██╗██║     ██║   ██║██║     ██╔═██╗ ██╔══██╗██║   ██║ ██╔██╗ 
██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗██████╔╝╚██████╔╝██╔╝ ██╗
╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝
${NC}"

# Cargar variables de entorno desde el archivo .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Variables
REPO="https://github.com/jon0010/practica-rust.git"
BRANCH="main"
TOKEN="$GITHUB_ACCESS_TOKEN"
RUST_INSTALLER="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"

# Mostrar mensaje en verde negrita
echo -e "\n${GREEN}Ingrese el nombre del proyecto:${NC}"

# Leer la entrada
read project_name

# Validar la entrada
if [ -z "$project_name" ]; then
    echo "Nombre vacío. Terminando la secuencia..."
    exit 1
fi

# Definir el directorio de destino como el nombre del proyecto
DEST_DIR="$project_name"

# Clonar repositorio
echo -e "\n${LBLUE}Generando nuevo proyecto...${NC}"
git clone -b ${BRANCH} "https://${TOKEN}@github.com/jon0010/practica-rust.git" repo_temp
if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio."
    exit 1
fi

# Verificar la existencia de src/templates-backend
if [ ! -d "repo_temp/src/templates-backend" ]; then
    echo "El directorio src/templates-backend no existe en el repositorio clonado."
    exit 1
fi

# Crear la lista de templates usando `fzf`
backends=$(ls -d repo_temp/src/templates-backend/*/ | xargs -n 1 basename)
selected_backend=$(echo "$backends" | fzf --prompt "Elige un template para tu backend: " --height=10)
if [ -z "$selected_backend" ]; then
    echo "No se seleccionó ningún template. Terminando la secuencia..."
    exit 1
fi
echo "Backend seleccionado: $selected_backend"

# Preguntar por el tipo de base de datos usando `fzf`
database=$(echo -e "PostgreSQL\nMongoDB" | fzf --prompt "¿Qué base de datos vas a usar? " --height=10)
case $database in
    PostgreSQL) database="postgres" ;;
    MongoDB) database="mongo" ;;
    *) echo "Selección inválida. Terminando la secuencia..."; exit 1 ;;
esac
echo "Base de datos seleccionada: $database"

# Preguntar por el tipo de conexión usando `fzf`
connection=$(echo -e "Local\nRemota" | fzf --prompt "Selecciona el tipo de conexión: " --height=10)
case $connection in
    Local) connection="local" ;;
    Remota) connection="remote" ;;
    *) echo "Selección inválida. Terminando la secuencia..."; exit 1 ;;
esac
echo "Tipo de conexión seleccionado: $connection"

# Instalar Rust si no está instalado
if ! command -v rustc &> /dev/null; then
    echo -e "\n${LBLUE}Rust no está instalado. Instalando Rust...${NC}"
    eval $RUST_INSTALLER
fi

# Crear directorio del proyecto
echo -e "\n${LBLUE}Creando el directorio del proyecto: ${DEST_DIR}${NC}"
mkdir -p "$DEST_DIR"

# Copiar archivos
echo -e "\n${LBLUE}Copiando archivos...${NC}"
cp -r repo_temp/src/templates-backend/$selected_backend "$DEST_DIR"
cp -r repo_temp/src/templates-frontend "$DEST_DIR"
cp -r repo_temp/src/config "$DEST_DIR"
cp repo_temp/README.md "$DEST_DIR"

# Limpiar
echo -e "\n${LBLUE}Limpiando archivos temporales...${NC}"
rm -rf repo_temp

# Mensaje final
echo -e "\n${LBLUE}Proyecto generado exitosamente en $DEST_DIR${NC}"
