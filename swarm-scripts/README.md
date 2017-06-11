# Swarm Scripts

Here is a set of scripts to help starting the cluster for running a CodeLab:

```bash
# Start the cluster (Edit the settings before + Load your AWS credentials)
bash init-cluster.sh

# If you want to associate an EIP to one of the manager machine, to it now
# And regenerate docker-machine certs: docker-machine regenerate-certs MACHINE_NAME

# Load the "admin services stack"
bash deploy_stack.sh admin ./admin.yml

# Build and deliver (registry push) the app images
bash build_and_deliver_stack.sh

# Load a random "app stack"
bash deploy_stack.sh app1
```
