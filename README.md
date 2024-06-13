# Eidolon Agent Quickstart

This project serves as a template for individuals interested in building agents with Eidolon.

For a detailed guide, check out the [quickstart walkthrough](https://www.eidolonai.com/docs/prereq/) on our website.

## Directory Structure

- `resources`: This directory contains additional resources for the project. An example agent is provided for reference.
- `components`: This directory is where any custom code should be placed.

## Getting Started

### Clone the Project

First you need to clone the project and navigate to the project directory:

```bash
git clone https://github.com/eidolon-ai/eidolon-quickstart.git
cd eidolon-quickstart
```

### Run your AgentMachine

Then run the server in dev mode, use the following command:

```bash
make serve-dev
```

The first time you run this command, you may be prompted to enter credentials that the machine needs
to run (ie, OpenAI API Key).

This command will download the dependencies required to run your agent machine and start the Eidolon http server in
"dev-mode".

If the server starts successfully, you should see the following output:
```
Starting Server...
INFO:     Started server process [34623]
INFO:     Waiting for application startup.
INFO - Building machine 'local_dev'
...
INFO - Server Started in 1.50s
```

### Try it out
First download the Ediolon CLI
```bash
pip install 'eidolon-ai-client[cli]' -U
```

The create an AgentProcess
```bash
export PID=$(eidolon-cli processes create --agent hello_world)
```

Now that we have started a conversation, we can converse with our agent
```bash
eidolon-cli actions converse --process-id $PID --body "Hi! I made you"
```

You should see a response from your agent
```
Hello! 🎉 I'm super excited to be here and help you out! What's on your mind today? 😊
Agent transitioned to state: idle Available actions: ['converse', 'generate_title']
```
