from argparse import ArgumentParser


def parse_params() -> ArgumentParser:
    """Parse common parameters"""
    parser = ArgumentParser(prog='customer-service-monitoring', description = 'Get data for connection string')
    parser.add_argument('--source', required = True)
    parser.add_argument('--host', required = True)
    parser.add_argument('--port', required = True)
    parser.add_argument('--database', '-db', required = True, default = 'entities')
    parser.add_argument('--username', '-user', required = True)
    parser.add_argument('--password', '-pass', required = True)
    return parser
