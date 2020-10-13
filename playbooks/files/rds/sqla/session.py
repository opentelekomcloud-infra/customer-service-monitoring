from sqlalchemy import create_engine, engine
from sqlalchemy.engine import url
from sqlalchemy.engine.url import URL
from sqlalchemy.orm import sessionmaker

from arg_parser import get_connection_dict


def get_db_engine() -> engine:
    """Create connection to database, and start logging"""
    return create_engine(url.make_url(URL(**get_connection_dict())), echo = False)


def get_session(db_engine: engine):
    """Create session object"""
    Session = sessionmaker(db_engine)
    return Session()
