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
  new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(
    '/usr/share/jenkins/ref/insecure_vagrant_key'
  ),
  '',
  "SSH Key for the Agent"
)

credentials_store.addCredentials(global_domain, credentials)

Slave dockerAgent = new DumbSlave(
  "docker-agent",
  "Agent for Docker",
  "/home/jenkins",
  "2",
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

Slave mavenAgent = new DumbSlave(
  "maven-agent",
  "Agent for Maven",
  "/home/jenkins",
  "2",
  Node.Mode.NORMAL,
  "maven",
  new SSHLauncher(
    "maven-agent", // HostName
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

Jenkins.instance.addNode(dockerAgent)
println("Added successfully 'docker-agent' to Jenkins")


Jenkins.instance.addNode(mavenAgent)
println("Added successfully 'maven-agent' to Jenkins")
