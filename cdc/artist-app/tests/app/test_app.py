from fastapi.testclient import TestClient


class TestApp:

    def test_app_runs(self, client: TestClient) -> None:
        assert client.app is not None
