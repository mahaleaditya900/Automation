import pytest
from utils import misc, clusters


def pytest_addoption(parser):
    group_db = parser.getgroup('DB Docker image options')

    group_db.addoption(
        "--db_version",
        action="store",
        default=13,
        help="Database version"
    )


@pytest.fixture(scope="session")
def database_version(request):
    return request.config.getoption("--db_version")


@pytest.fixture(scope='session')
def create_db_image(database_version):
    image_name = "db{}".format(database_version)
    misc.run_playbook('build_db_image.yaml', extravars={
        "db_version": database_version, "image_name": image_name
    })
    return image_name


@pytest.fixture
def create_cluster(request, create_db_image):
    # Create cluster
    image_name = create_db_image
    extravars = misc.get_test_vars(request.node.name)
    primary_name, standby_names = misc.get_node_names(extravars.get("standby_count", 0))
    extravars.update({
        "image_name": image_name,
        "primary": primary_name,
        "replicas": standby_names
    })
    misc.run_playbook('create_cluster.yaml', extravars=extravars)
    cluster = clusters.Cluster(primary_name, standby_names)

    # Remove containers
    def _tear_down():
        cluster.remove_all_nodes()
    request.addfinalizer(_tear_down)

    return cluster
