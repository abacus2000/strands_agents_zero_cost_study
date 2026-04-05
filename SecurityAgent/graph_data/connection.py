
import os
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()


def get_driver():
    uri = os.getenv("NEO4J_URI")
    user = os.getenv("NEO4J_USER")
    password = os.getenv("NEO4J_PASSWORD")
    if not password:
        raise RuntimeError("NEO4J_PASSWORD not set. ")
    return GraphDatabase.driver(uri, auth=(user, password))
