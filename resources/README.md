# Machine Resources

This is where you will define additional agents and resources for your Agent Machine.

Here is an example of a simple agent you can add to your machine:

```yaml "title=hello-world-agent.yaml"
apiVersion: server.eidolonai.com/v1alpha1
kind: Agent
metadata:
  name: hello-world-agent

spec:
  description: "This is a general agent that uses an LLM to answer questions."
  system_prompt: "You are a friendly assistant that thinks carefully before responding to questions."
```

You can add this to your machine by creating a new file in the `resources` directory. The file can be named anything you like, but should have a `.eidolon.yaml` extension.

> 🤔 why `.eidolon.yaml`? This isn't needed to function, but if your IDE supports [schemastore](https://www.schemastore.org/) yaml validation, it will match off of this file extension and give you docs and auto-completion right in your IDE! 
> * **IntelliJ**: yaml extension is bundled and enabled ootb.
> * **Visual Studio**: [yaml extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) needs to be downloaded seporately.

See the [Eidolon Documentation](https://www.eidolonai.com/) for more information on how to define agents and components.
