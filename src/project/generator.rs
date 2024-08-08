use std::fs;
use std::path::Path;
use std::process::Command;
use std::io;

pub fn generate_project(
    project_name: &str,
    backend: &str,
    database: &str,
    connection: &str
) -> io::Result<()> {
    println!("Generando proyecto: {}", project_name);
    println!("Backend: {}", backend);
    println!("Base de datos: {}", database);
    println!("Conexión: {}", connection);

    let project_path = Path::new(project_name);
    fs::create_dir_all(&project_path)?;

    // Clonar el repositorio
    let repo_url = "https://github.com/tuusuario/tu-repo.git";
    let repo_temp_path = Path::new("repo_temp");

    if repo_temp_path.exists() {
        fs::remove_dir_all(repo_temp_path)?;
    }

    Command::new("git").args(&["clone", repo_url, repo_temp_path.to_str().unwrap()]).output()?;

    let backend_template_path = repo_temp_path.join("src/templates-backend").join(backend);
    let backend_target_path = project_path.join("backend");

    println!("Ruta absoluta del template de backend: {:?}", backend_template_path);
    println!("Ruta absoluta del directorio objetivo: {:?}", backend_target_path);

    if !backend_template_path.exists() {
        return Err(
            io::Error::new(
                io::ErrorKind::NotFound,
                format!("El template backend no existe: {:?}", backend_template_path)
            )
        );
    }

    fs::create_dir_all(&backend_target_path)?;

    for entry in fs::read_dir(&backend_template_path)? {
        let entry = entry?;
        let entry_path = entry.path();
        let target_path = backend_target_path.join(entry.file_name());

        if entry_path.is_file() {
            println!("Copiando archivo: {:?}", entry_path);
            fs::copy(&entry_path, &target_path)?;
        } else if entry_path.is_dir() {
            fs::create_dir_all(&target_path)?;
            for sub_entry in fs::read_dir(entry_path)? {
                let sub_entry = sub_entry?;
                let sub_entry_path = sub_entry.path();
                let target_sub_path = target_path.join(sub_entry.file_name());
                fs::copy(sub_entry_path, target_sub_path)?;
            }
        }
    }

    // Eliminar el repositorio clonado
    fs::remove_dir_all(repo_temp_path)?;

    // Crear archivo de configuración de base de datos
    create_database_config(&project_path, database, connection)?;

    Ok(())
}

fn create_database_config(project_path: &Path, database: &str, connection: &str) -> io::Result<()> {
    let db_config_content = format!("database: {}\nconnection: {}", database, connection);
    let db_config_path = project_path.join("database_config.ts");
    create_file(&db_config_path, &db_config_content)
}

fn create_file(path: &Path, content: &str) -> io::Result<()> {
    use std::fs::File;
    use std::io::Write;
    let mut file = File::create(path)?;
    file.write_all(content.as_bytes())?;
    Ok(())
}
