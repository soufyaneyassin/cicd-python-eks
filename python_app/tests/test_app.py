from .conftest import client


def test_hello_page(client):
    response= client.get("/hello/test")
    assert response.status_code == 200