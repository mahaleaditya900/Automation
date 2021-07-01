import time

from test_automation.utils import database


def test_new(create_cluster):
    primary_ip = create_cluster.get_primary_ip()
    time.sleep(10)
    db = database.Database(primary_ip, 'edb', 5433, 'enterprisedb')
    db.execute_query("CREATE TABLE test(id INT, name TEXT);")
    db.execute_query("INSERT INTO test values(1, 'Test');")
    db.execute_query("INSERT INTO test values(2, 'Name');")
    data = db.select_query("SELECT * FROM test")
    db.tear_down_connection()
    assert data[0][1] == 'Test'


def test_new1(create_cluster):
    primary_ip = create_cluster.get_primary_ip()
    time.sleep(10)
    db = database.Database(primary_ip, 'edb', 5433, 'enterprisedb')
    db.execute_query("CREATE TABLE test(id INT, name TEXT);")
    db.execute_query("INSERT INTO test values(1, 'Test');")
    db.execute_query("INSERT INTO test values(2, 'Name');")
    data = db.select_query("SELECT * FROM test")
    db.tear_down_connection()
    assert data[1][1] == 'Name'
