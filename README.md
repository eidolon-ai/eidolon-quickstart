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
First download the Ediolon CLI
```bash
pip install 'eidolon-ai-client[cli]'
```

The create an AgentProcess and run the converse action on it
```bash
export PID=$(eidolon-cli processes create --agent hello_world)
eidolon-cli actions converse --process-id $PID --body "Hi! I made you"
```
