```
███████╗██╗███╗   ██╗ █████╗ ██╗     ██╗     ██╗   ██╗
██╔════╝██║████╗  ██║██╔══██╗██║     ██║     ╚██╗ ██╔╝
█████╗  ██║██╔██╗ ██║███████║██║     ██║      ╚████╔╝ 
██╔══╝  ██║██║╚██╗██║██╔══██║██║     ██║       ╚██╔╝  
██║     ██║██║ ╚████║██║  ██║███████╗███████╗   ██║   
╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   

██████╗  ██████╗ ███████╗████████╗ ██████╗ ██████╗ ███████╗███████╗██╗
██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔════╝ ██╔══██╗██╔════╝██╔════╝██║
██████╔╝██║   ██║███████╗   ██║   ██║  ███╗██████╔╝█████╗  ███████╗██║
██╔═══╝ ██║   ██║╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  ╚════██║╚═╝
██║     ╚██████╔╝███████║   ██║   ╚██████╔╝██║  ██║███████╗███████║██╗
╚═╝      ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝
```

# Finally, Postgres!

Ready-to-use PostgreSQL development environment with Docker. Simple setup, smart defaults, and comprehensive management commands.

## Requirements

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Make](https://www.gnu.org/software/make/)

## Quick Start

```bash
make setup
```

Edit `.env` file to change database credentials and other settings.
> Default credentials are already set after running `make setup`

```bash
nano/vim/code .env
```

Start PostgreSQL container

```bash
$ make start
```

and that's it!

### Commands

```bash
$ make help
Available commands:
make setup          - Create necessary directories
make start          - Start PostgreSQL container
make stop           - Stop PostgreSQL container
make restart        - Restart PostgreSQL container
make reload         - Reload PostgreSQL container (down and up)
make status         - Check container status
make logs           - Show container logs
make health-check   - Check PostgreSQL health
make clean          - Remove container and volumes
make backup         - Backup PostgreSQL database
make restore        - Restore PostgreSQL database from backup
make ps             - List running containers
```