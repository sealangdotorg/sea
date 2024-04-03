//

use clap;
use clap::Parser;
use clap::Subcommand;

use sea_rs::build;

const NAME: &str = "sea";

const ABOUT: &str = r#"
The SEA Language <https://sealang.org>"#;

#[derive(Parser, Debug)]
#[command(
    name = NAME,
    version = build::PKG_VERSION,
    about = ABOUT,
    long_about = None,
)]
struct Args {
    #[command(subcommand)]
    commands: Commands,
}

#[derive(Subcommand, Debug, Clone, PartialEq)]
enum Commands {
    /// Print detailed version and build information
    Version,
    /// Print cargo package dependency tree
    Cargo,
    /// Print project license information
    License,
}

fn main() {
    let result = run();
    match result {
        Ok(code) => std::process::exit(code),
        Err(msg) => panic!("{}", msg),
    }
}

fn run() -> Result<i32, String> {
    let args = Args::parse();

    if args.commands == Commands::Version {
        println!("{} {}", NAME, build::PKG_VERSION);
        println!("├── revision: {}", build::SHORT_COMMIT); //8405e28e
        println!("└── datetime: {}", build::COMMIT_DATE); //2021-08-04 12:34:03 +00:00
    }

    if args.commands == Commands::Cargo {
        print!("{} {}", build::PROJECT_NAME, build::PKG_VERSION);
        println!("{}", build::CARGO_TREE);
    }

    if args.commands == Commands::License {
        let license = include_str!("../LICENSE");
        println!("{}", license);
    }

    Ok(0)
}
