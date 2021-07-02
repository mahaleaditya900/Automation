import time

from test_automation.utils import database


def test_new(create_cluster):
    cluster = create_cluster["cluster"]
    db_props = create_cluster["db_props"]
    primary_ip = cluster.get_primary_ip()
    time.sleep(10)
    db = database.Database(
        primary_ip, db_props["database_name"],
        db_props["db_port"], db_props["database_user"]
    )
    db.execute_query("CREATE TABLE test(id INT, name TEXT);")
    db.execute_query("INSERT INTO test values(1, 'Test');")
    db.execute_query("INSERT INTO test values(2, 'Name');")
    data = db.select_query("SELECT * FROM test")
    db.tear_down_connection()
    assert data[0][1] == 'Test'


def test_new1(create_cluster):
    cluster = create_cluster["cluster"]
    db_props = create_cluster["db_props"]
    primary_ip = cluster.get_primary_ip()
    time.sleep(10)
    db = database.Database(
        primary_ip, db_props["database_name"],
        db_props["db_port"], db_props["database_user"]
    )
    db.execute_query("CREATE TABLE test(id INT, name TEXT);")
    db.execute_query("INSERT INTO test values(1, 'Test');")
    db.execute_query("INSERT INTO test values(2, 'Name');")
    data = db.select_query("SELECT * FROM test")
    db.tear_down_connection()
    assert data[1][1] == 'Name'
