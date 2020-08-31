from .arg_parser import parse_params


def get_connection_dict() -> dict:
    """Create connection dict"""
    #args = parse_params().parse_args()
    db_connect = {
        'drivername': 'postgresql+psycopg2',
        'host': '127.0.0.1',#args.host,
        'port': 8669, #args.port,
        'username': 'postgres', #args.username,
        'password': 'test1234!', #args.password,
        'database': 'entities' #args.database
    }
    return db_connect


def get_source():
    return 'sqla/data.yaml' #parse_param().parse_args().source
