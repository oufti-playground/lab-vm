import jenkins.model.*
import hudson.model.*
import hudson.slaves.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*;
import hudson.plugins.sshslaves.verifiers.*;
import hudson.slaves.EnvironmentVariablesNodeProperty.Entry

//// Set Credentials

global_domain = Domain.global()

def env = System.getenv()
String customJvmOpts = env['CUSTOM_JVM_OPTS']
String jdk8Home = '/usr/lib/jvm/java-1.8-openjdk'
String jdk7Home = '/usr/lib/jvm/java-1.7-openjdk'

credentials_store = Jenkins.instance.getExtensionList(
  'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
)[0].getStore()

credentials = new BasicSSHUserPrivateKey(
  CredentialsScope.SYSTEM,
  "ssh-nodes-key",
  "jenkins",
  new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(
    '/usr/share/jenkins/ref/insecure_vagrant_key'
  ),
  '',
  "SSH Key for the Agent"
)

credentials_store.addCredentials(global_domain, credentials)


/// Disable all protocol except JNLP4
//// From https://github.com/samrocketman/jenkins-bootstrap-shared/blob/master/scripts/configure-jnlp-agent-protocols.groovy
Jenkins myJenkins = Jenkins.instance

if(!myJenkins.isQuietingDown()) {
    Set<String> agentProtocolsList = ['JNLP4-connect', 'Ping']
    if(!myJenkins.getAgentProtocols().equals(agentProtocolsList)) {
        myJenkins.setAgentProtocols(agentProtocolsList)
        println "Agent Protocols have changed.  Setting: ${agentProtocolsList}"
        myJenkins.save()
    }
    else {
        println "Nothing changed.  Agent Protocols already configured: ${myJenkins.getAgentProtocols()}"
    }
}
else {
    println 'Shutdown mode enabled.  Configure Agent Protocols SKIPPED.'
}

/// Configure and start Agents on Nodes

Slave dockerNode = new DumbSlave(
  "docker-node",
  "Node for running Docker",
  "/home/jenkins",
  "4",
  Node.Mode.NORMAL,
  "docker",
  new SSHLauncher(
    "jenkins-docker-node", // HostName
    22,
    'ssh-nodes-key', // Credential ID
    customJvmOpts, // JVM Options
    "", // JavaPath
    "", // Prefix Start CMD
    "", // Suffix Start CMD
    15, // Launch Timeout
    3, // maxRetries
    5, // RetryWait
    new NonVerifyingKeyVerificationStrategy()
  ),
  new RetentionStrategy.Always(),
  new LinkedList()
)

List<Entry> dockerNodeEnv = new ArrayList<Entry>();
dockerNodeEnv.add(new Entry("JAVA_HOME","${jdk8Home}"))
dockerNodeEnv.add(new Entry("DOCKER_HOST","unix:///var/run/docker.sock"))
EnvironmentVariablesNodeProperty dockerNodeEnvPro = new EnvironmentVariablesNodeProperty(dockerNodeEnv);
dockerNode.getNodeProperties().add(dockerNodeEnvPro)

Slave mavenJDK8Node = new DumbSlave(
  "maven-jdk8-node",
  "Node for running Maven with OpenJDK8",
  "/home/jenkins",
  "2",
  Node.Mode.NORMAL,
  "jdk8 java8 maven maven-jdk8 maven-java8 maven3 maven3-jdk8 maven3-java8",
  new SSHLauncher(
    "jenkins-maven-jdk8-node", // HostName
    22,
    'ssh-nodes-key', // Credential ID
    customJvmOpts, // JVM Options
    "", // JavaPath
    "", // Prefix Start CMD
    "", // Suffix Start CMD
    15, // Launch Timeout
    3, // maxRetries
    5, // RetryWait
    new NonVerifyingKeyVerificationStrategy()
  ),
  new RetentionStrategy.Always(),
  new LinkedList()
)

List<Entry> jdk8SSHNodeEnv = new ArrayList<Entry>();
jdk8SSHNodeEnv.add(new Entry("JAVA_HOME","${jdk8Home}"))
EnvironmentVariablesNodeProperty jdk8SSHNodeEnvPro = new EnvironmentVariablesNodeProperty(jdk8SSHNodeEnv);
mavenJDK8Node.getNodeProperties().add(jdk8SSHNodeEnvPro)

Slave mavenJDK7Node = new DumbSlave(
  "maven-jdk7-node",
  "Node for running Maven with OpenJDK7",
  "/home/jenkins",
  "2",
  Node.Mode.NORMAL,
  "jdk7 java7 maven-jdk7 maven-java7 maven3-jdk7 maven3-java7",
  new SSHLauncher(
    "jenkins-maven-jdk7-node", // HostName
    22,
    'ssh-nodes-key', // Credential ID
    customJvmOpts, // JVM Options
    "${jdk8Home}/bin/java", // JavaPath - Use JDK8 for running the slave.jar
    "", // Prefix Start CMD
    "", // Suffix Start CMD
    15, // Launch Timeout
    3, // maxRetries
    5, // RetryWait
    new NonVerifyingKeyVerificationStrategy()
  ),
  new RetentionStrategy.Always(),
  new LinkedList()
)

List<Entry> jdk7SSHNodeEnv = new ArrayList<Entry>();
jdk7SSHNodeEnv.add(new Entry("JAVA_HOME","${jdk7Home}"))
EnvironmentVariablesNodeProperty jdk7SSHNodeEnvPro = new EnvironmentVariablesNodeProperty(jdk7SSHNodeEnv);
mavenJDK7Node.getNodeProperties().add(jdk7SSHNodeEnvPro)


Jenkins.instance.addNode(dockerNode)
println("Added successfully 'docker-node' to Jenkins")

Jenkins.instance.addNode(mavenJDK8Node)
println("Added successfully 'maven-jdk8-node' to Jenkins")

Jenkins.instance.addNode(mavenJDK7Node)
println("Added successfully 'maven-jdk7-node' to Jenkins")
