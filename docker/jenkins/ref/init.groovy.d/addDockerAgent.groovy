import jenkins.model.*
import hudson.model.*
import hudson.slaves.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*;
import hudson.plugins.sshslaves.verifiers.*;

global_domain = Domain.global()

credentials_store = Jenkins.instance.getExtensionList(
  'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
)[0].getStore()

credentials = new BasicSSHUserPrivateKey(
  CredentialsScope.SYSTEM,
  "ssh-agent-key",
  "jenkins",
  new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource('/usr/share/jenkins/ref/insecure_vagrant_key'),
  '',
  "SSH Key for the Agent"
)

credentials_store.addCredentials(global_domain, credentials)

Slave agent = new DumbSlave(
  "docker-node",
  "Agent node for Docker",
  "/home/jenkins",
  "1",
  Node.Mode.NORMAL,
  "docker",
  new SSHLauncher(
    "docker-agent", // HostName
    22,
    'ssh-agent-key', // Credential ID
    "", // JVM Options
    "", // JavaPath
    "", // Prefix Start CMD
    "", // Suffix Start CMD
    15, // Launch Timeout
    3, // maxRetries
    5, // RetryWait
    new ManuallyTrustedKeyVerificationStrategy(false)
  ),
  new RetentionStrategy.Always(),
  new LinkedList()
)

agent.getNodeProperties().add(envPro)

Jenkins.instance.addNode(agent)
println("Added successfully 'docker-agent' to Jenkins")
