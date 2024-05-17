# Eidolon Agent Quickstart

This project serves as a template for individuals interested in building agents with Eidolon.

For a detailed guide, check out the [quickstart walkthrough](https://www.eidolonai.com/docs/prereq/) on our website.

## Directory Structure

- `resources`: This directory contains additional resources for the project. An example agent is provided for reference.
- `components`: This directory is where any custom code should be placed.

## Getting Started

### Run your AgentMachine

```bash
make serve-dev
```

### Try it out

First, start a virtual environment

MacOS:

```bash
python3 -m venv venv
source venv/bin/activate
```

Use the current project version of Python

```bash
poetry env use python3.11
```

Download the Eidolon CLI
```bash
pip install 'eidolon-ai-client[cli]'
```

Create an AgentProcess and run the converse action on it 

_Ensure the AgentMachine is already running from a terminal before doing this_

```bash
export PID=$(eidolon-cli processes create --agent hello_world)
eidolon-cli actions converse --process-id $PID --body "Hi! I made you"
```

In your terminal, you should see the response from the agent.

### Troubleshooting

If commands like pip or python3 are not found, you may need to install them. See instructions in the
[quickstart walkthrough](https://www.eidolonai.com/docs/prereq/)