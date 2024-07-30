use std::fs;
use std::path::Path;
use crate::utils::file::create_file;

pub fn generate_project(
    project_name: &str,
    backend: &str,
    database: &str,
    connection: &str
    // models: Vec<&str>
) {
    println!("Generando proyecto: {}", project_name);
    println!("Backend: {}", backend);
    println!("Base de datos: {}", database);
    println!("Conexión: {}", connection);
    // for model in &models {
    //     println!("Modelo: {}", model);
    // }

    let project_path = Path::new(project_name);
    fs::create_dir_all(&project_path).unwrap();
    create_backend(project_path, backend);
    create_database_config(project_path, database, connection);
    // create_models(project_path, &models);
}

fn create_backend(project_path: &Path, backend: &str) {
    let backend_template_path = Path::new("src/templates-backend").join(backend);
    let backend_target_path = project_path.join("backend");

    println!("backend_template_path: {:?}", backend_template_path);
    println!("backend_target_path: {:?}", backend_target_path);

    // Validacion de que la ruta de template existe
    if !backend_template_path.exists() {
        panic!("El template backend no existe: {:?}", backend_template_path);
    }

    fs::create_dir_all(&backend_target_path).unwrap();

    // Copio todos los archivos y directorios del template de crud
    for entry in fs::read_dir(&backend_template_path).unwrap() {
        let entry = entry.unwrap();
        let entry_path = entry.path();
        let target_path = backend_target_path.join(entry.file_name());

        if entry_path.is_file() {
            println!("Copiando archivo: {:?}", entry_path);
            fs::copy(&entry_path, &target_path).unwrap();
        } else if entry_path.is_dir() {
            fs::create_dir_all(&target_path).unwrap();
            for sub_entry in fs::read_dir(entry_path).unwrap() {
                let sub_entry = sub_entry.unwrap();
                let sub_entry_path = sub_entry.path();
                let target_sub_path = target_path.join(sub_entry.file_name());
                fs::copy(sub_entry_path, target_sub_path).unwrap();
            }
        }
    }
}

fn create_database_config(project_path: &Path, database: &str, connection: &str) {
    // esta fn crea un archivo de configuración donde ira la conexion a la base de datos
    let db_config_content = format!("database: {}\nconnection: {}", database, connection);
    let db_config_path = project_path.join("database_config.yml");
    create_file(&db_config_path, &db_config_content);
}

// fn create_models(project_path: &Path, models: &[&str]) {
//     // Usar `&[&str]` en lugar de `Vec<&str>`
//     // Crear archivos de modelos
//     let models_path = project_path.join("models");
//     fs::create_dir_all(&models_path).unwrap();
//     for model in models {
//         let model_content = format!("model: {}", model);
//         let model_path = models_path.join(format!("{}.yml", model));
//         create_file(&model_path, &model_content);
//     }
// }
