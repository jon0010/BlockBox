mod cli;
mod project;
mod db;
mod utils;

use cli::build_cli;

fn main() {
    let matches = build_cli().get_matches();
    if let Some(matches) = matches.subcommand_matches("generate") {
        let project_name = matches
            .get_one::<String>("project")
            .unwrap_or(&"new_project".to_string())
            .clone();

        let backend = matches
            .get_one::<String>("backend")
            .unwrap_or(&"parse_server".to_string())
            .clone();

        let database = matches
            .get_one::<String>("database")
            .unwrap_or(&"postgres".to_string())
            .clone();

        let connection = matches
            .get_one::<String>("connection")
            .unwrap_or(&"local".to_string())
            .clone();

        // Manejo de Result
        if
            let Err(e) = project::generator::generate_project(
                &project_name,
                &backend,
                &database,
                &connection
            )
        {
            eprintln!("Error al generar el proyecto: {}", e);
            std::process::exit(1);
        }
    }
}
