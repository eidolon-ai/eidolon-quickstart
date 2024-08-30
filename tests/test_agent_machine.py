import pytest
from eidolon_ai_client.client import Agent


@pytest.fixture
def agent():
    return Agent.get("hello-world")


def test_suite_initialization():
    assert True


@pytest.mark.vcr()
async def test_agent(agent: Agent):
    process = await agent.create_process()
    response = await process.action("converse", "Hi! What is the capital of France?")
    assert "paris" in response.data.lower()
