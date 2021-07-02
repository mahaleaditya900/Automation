import pytest
from utils import misc, clusters


# Custom Pytest command line options
def pytest_addoption(parser):
    group_db = parser.getgroup('DB Docker image options')
    group_db.addoption(
        "--db_type",
        action="store",
        default="epas",
        help="Database type: epas/pg"
    )
    group_db.addoption(
        "--db_version",
        action="store",
        default=13,
        help="Database version"
    )

    group_platform = parser.getgroup('OS options')
    group_platform.addoption(
        "--os_type",
        action="store",
        default="centos",
        help="OS type"
    )

    group_platform.addoption(
        "--os_version",
        action="store",
        default=7,
        help="OS type"
    )

    group_test = parser.getgroup('Test options')
    group_test.addoption(
        "--debug_test", action="store_true", default=False,
        help="Debug cluster by keeping nodes running after the test is complete"
    )

# Fixtures to retrieve command line options
@pytest.fixture(scope="session")
def database_type(request):
    return request.config.getoption("--db_type")


@pytest.fixture(scope="session")
def database_version(request):
    return request.config.getoption("--db_version")


@pytest.fixture(scope="session")
def platform_type(request):
    return request.config.getoption("--os_type")


@pytest.fixture(scope="session")
def platform_version(request):
    return request.config.getoption("--os_version")


@pytest.fixture(scope="session")
def debug(request):
    return request.config.getoption("--debug_test")

# Setup fixtures
@pytest.fixture(scope='session')
def create_db_image(database_type, database_version, platform_type, platform_version):
    image_name = "db{}{}{}".format(database_type, platform_type, platform_version)
    db_props = misc.get_db_props(database_type)
    misc.run_playbook('build_db_image.yaml', extravars={
        "db_type": database_type, "db_version": database_version,
        "platform": platform_type, "platform_version": platform_version,
        "database_name": db_props["database_name"], "database_user": db_props["database_user"]
    })
    return {
        "image_name": image_name,
        "db_props": db_props
    }


@pytest.fixture
def create_cluster(request, create_db_image, debug):
    # Create cluster
    image_name = create_db_image["image_name"]
    extravars = misc.get_test_vars(request.node.name)
    primary_name, standby_names = misc.get_node_names(extravars.get("standby_count", 0))
    extravars.update({
        "image_name": image_name,
        "primary": primary_name,
        "replicas": standby_names
    })
    misc.run_playbook('create_cluster.yaml', extravars=extravars)
    cluster = clusters.Cluster(primary_name, standby_names)

    # Remove cluster
    def _tear_down():
        cluster.remove_all_nodes()
    if not debug:
        request.addfinalizer(_tear_down)

    return {
        "cluster": cluster,
        "db_props": create_db_image["db_props"]
    }
