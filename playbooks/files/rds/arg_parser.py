from argparse import ArgumentParser


def parse_params() -> ArgumentParser:
    """Parse common parameters"""
    parser = ArgumentParser(prog='customer-service-monitoring', description = 'Get data for connection string')
    parser.add_argument('--run_option', dest = 'run_option', required = True, choices = ['pg2', 'sqla'])
    parser.add_argument('--source', required = True)
    parser.add_argument('--host', required = True)
    parser.add_argument('--port', required = True)
    parser.add_argument('--database', '-db', required = True, default = 'entities')
    parser.add_argument('--username', '-user', required = True)
    parser.add_argument('--password', '-pass', required = True)
    parser.add_argument('--drivername', default = 'postgresql+psycopg2')
    return parser


def get_connection_dict() -> dict:
    """Create connection dict"""
    args = parse_params().parse_args()
    db_connect = {
        'host': args.host,
        'port': args.port,
        'password': args.password,
        'database': args.database
    }
    if args.run_option == 'pg2':
        db_connect['user'] = args.username
    else:
        db_connect['drivername'] = args.drivername
        db_connect['username'] = args.username
    return db_connect


def get_source():
    """Data file"""
    return parse_params().parse_args().source


def get_run_option():
    """Get run option"""
    return parse_params().parse_args().run_option
