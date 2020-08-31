from .arg_parser import parse_params


def get_connection_dict() -> dict:
    """Create connection dict"""
    #args = parse_params().parse_args()
    db_connect = {
        'host': '127.0.0.1',#args.host,
        'port': 8669, #args.port,
        'user': 'postgres', #args.username,
        'password': 'test1234!', #args.password,
        'database': 'entities' #args.database
    }
    return db_connect


def get_conn_dict() -> dict:
    """Create connection to database (pg2)"""
    return get_connection_dict()


def get_source():
    return 'pg2/data.yaml' #parse_param().parse_args().source
