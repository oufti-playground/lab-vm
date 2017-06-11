# Swarm Scripts

Here is a set of scripts to help starting the cluster for running a CodeLab:

```bash
# Start the cluster (Edit the settings before + Load your AWS credentials)
bash init-cluster.sh

# If you want to associate an EIP to one of the manager machine, to it now
# And regenerate docker-machine certs: docker-machine regenerate-certs MACHINE_NAME

# Don't forget to set up Security Groups with those elements
# 1 - Docker-Machine (SSH, Secured Docker engine)
# 2 - Docker-Swarm (Secured Docker Machine 2 machine, TCP/UDP for net, etc.)
# 3 - Admin ports (to restrict to yourself) from admin.yml
# 4 - Open Registry 5000 and HTTP 10000 to the outside for the codelab

# Load the "admin services stack"
bash deploy_stack.sh admin ./admin.yml

# Build and deliver (registry push) the app images
bash build_and_deliver_stack.sh

# Load a random "app stack"
bash deploy_stack.sh app1

# You can cleanup the docker engines
bash clean-cluster.sh

# You can upgrade the ubuntu Host OS
bash upgrade-cluster.sh
```
