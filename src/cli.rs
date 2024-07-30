use clap::{ Command, Arg };

pub fn build_cli() -> Command {
    Command::new("BlockBox CLI")
        .version("1.0")
        .author("Jon pereyra/Alan pereyra <jonnahuel78@gmail.com>")
        .about("Generador de proyectos fullstack")
        .subcommand(
            Command::new("generate")
                .about("Genera un nuevo proyecto")
                .arg(
                    Arg::new("project")
                        .short('p')
                        .long("project")
                        .num_args(1)
                        .help("Nombre del proyecto")
                )
                .arg(
                    Arg::new("backend")
                        .short('b')
                        .long("backend")
                        .num_args(1)
                        .help("Elige el template de backend")
                )
                .arg(
                    Arg::new("database")
                        .short('d')
                        .long("database")
                        .num_args(1)
                        .help("Elige la base de datos (postgres o mongo)")
                )
                .arg(
                    Arg::new("connection")
                        .short('c')
                        .long("connection")
                        .num_args(1)
                        .help("Elige la conexión (local o remota)")
                )
                .arg(
                    Arg::new("model")
                        .short('m')
                        .long("model")
                        .num_args(1..)
                        .help("Define los modelos")
                )
        )
}
