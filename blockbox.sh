#!/bin/bash

# Cargar variables de entorno desde el archivo .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Variables
REPO="https://github.com/jon0010/practica-rust.git"
BRANCH="main"
TOKEN="$GITHUB_ACCESS_TOKEN"
RUST_INSTALLER="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"

# Colores
LBLUE='\033[1;34m'
NC='\033[0m'

# Preguntar por el nombre del proyecto usando read
read -p "Ingrese el nombre del proyecto: " project_name
if [ -z "$project_name" ]; then
    echo "Nombre vacío. Terminando la secuencia..."
    exit 1
fi
echo "Nombre del proyecto: $project_name"

# Definir el directorio de destino como el nombre del proyecto
DEST_DIR="$project_name"

# Clonar repositorio
echo -e "\n${LBLUE}Clonando el repositorio...${NC}"
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

# Listar las carpetas en src/templates-backend
echo -e "\n${LBLUE}Contenido de src/templates-backend:${NC}"
for dir in repo_temp/src/templates-backend/*/; do
    if [ -d "$dir" ]; then
        echo "$(basename $dir)"
    fi
done

# Crear la lista de opciones para el menú de backend
backends=$(ls -d repo_temp/src/templates-backend/*/ | xargs -n 1 basename)
echo "Opciones de backend disponibles:"
select backend in $backends; do
    if [ -n "$backend" ]; then
        selected_backend="$backend"
        break
    else
        echo "Selección inválida. Intenta nuevamente."
    fi
done
echo "Backend seleccionado: $selected_backend"

# Preguntar por el tipo de base de datos
echo "Selecciona el tipo de base de datos:"
select db in "PostgreSQL" "MongoDB"; do
    case $db in
        PostgreSQL) database="postgres"; break ;;
        MongoDB) database="mongo"; break ;;
        *) echo "Selección inválida. Intenta nuevamente." ;;
    esac
done
echo "Base de datos seleccionada: $database"

# Preguntar por el tipo de conexión
echo "Selecciona el tipo de conexión:"
select conn in "Local" "Remota"; do
    case $conn in
        Local) connection="local"; break ;;
        Remota) connection="remote"; break ;;
        *) echo "Selección inválida. Intenta nuevamente." ;;
    esac
done
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
