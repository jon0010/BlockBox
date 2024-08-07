#!/bin/bash

# Variables
REPO="https://github.com/jon0010/practica-rust.git"
BRANCH="main"
TOKEN="your_github_token"  # Reemplaza con tu token de acceso personal
RUST="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
DIALOG_PACKAGE="dialog"

# Colores
LBLUE='\033[1;34m'
NC='\033[0m'

# Verificar e instalar dialog
if ! command -v dialog &> /dev/null; then
    echo "Dialog no está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y ${DIALOG_PACKAGE}
else
    echo "Dialog ya está instalado."
fi

# Clonar repositorio
if [ -d "practica-rust" ]; then
    echo -e "\n${LBLUE}El repositorio ya existe...${NC}"
    rm -rf practica-rust
fi

git clone -b ${BRANCH} "https://${TOKEN}@${REPO}"

# Instalar Rust si no está instalado
if ! command -v rustc &> /dev/null; then
    echo "Rust no está instalado. Instalando..."
    ${RUST}
else
    echo "Rust ya está instalado."
fi

# Instalar Cargo si no está instalado
if ! command -v cargo &> /dev/null; then
    echo "Cargo no está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install cargo
else
    echo "Cargo ya está instalado."
fi

# Cambiar al directorio del repositorio
cd practica-rust || exit

# Preguntar por el nombre del proyecto
project_name=$(dialog --inputbox "Ingrese el nombre del proyecto:" 8 40 3>&1 1>&2 2>&3)
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Operación cancelada."
    exit
fi

# Listar las carpetas en src/templates-backend
backends=$(ls -d src/templates-backend/*/ | xargs -n 1 basename)
selected_backend=$(dialog --menu "Selecciona el tipo de backend:" 15 50 4 $backends 3>&1 1>&2 2>&3)
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Operación cancelada."
    exit
fi

# Preguntar por el tipo de base de datos
database=$(dialog --menu "Selecciona el tipo de base de datos:" 15 50 4 \
    "postgres" "PostgreSQL" \
    "mysql" "MySQL" \
    "sqlite" "SQLite" \
    3>&1 1>&2 2>&3)
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Operación cancelada."
    exit
fi

# Preguntar por el tipo de conexión
connection=$(dialog --menu "Selecciona el tipo de conexión:" 15 50 4 \
    "local" "Local" \
    "remote" "Remota" \
    3>&1 1>&2 2>&3)
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Operación cancelada."
    exit
fi

# Ejecución del comando Rust
RUST_BACKTRACE=1 cargo run -- generate --project "$project_name" --backend "$selected_backend" --database "$database" --connection "$connection"
