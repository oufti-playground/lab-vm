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
String alpineJdk8Home = '/usr/lib/jvm/java-1.8-openjdk'
String alpineJdk12Home = '/opt/openjdk-12'

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

Slave productionNode = new DumbSlave(
  "production-node",
  "Node for production deployment, and Docker Workloads",
  "/home/jenkins",
  "1",
  Node.Mode.EXCLUSIVE,
  "deploy production docker",
  new SSHLauncher(
    "jenkins-production-node", // HostName
    22,
    'ssh-nodes-key', // Credential ID
    customJvmOpts, // JVM Options
    "${alpineJdk8Home}/bin/java", // JavaPath
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

List<Entry> productionNodeEnv = new ArrayList<Entry>();
productionNodeEnv.add(new Entry("JAVA_HOME","${alpineJdk8Home}"))
productionNodeEnv.add(new Entry("DOCKER_HOST","unix:///var/run/docker.sock"))
EnvironmentVariablesNodeProperty productionNodeEnvPro = new EnvironmentVariablesNodeProperty(productionNodeEnv);
productionNode.getNodeProperties().add(productionNodeEnvPro)

Slave mavenJDK8Node = new DumbSlave(
  "maven-jdk8-node",
  "Node for running Maven with OpenJDK8, or Docker workloads",
  "/home/jenkins",
  "4",
  Node.Mode.NORMAL,
  "jdk8 java8 maven maven-jdk8 maven-java8 maven3 maven3-jdk8 maven3-java8 docker",
  new SSHLauncher(
    "jenkins-maven-jdk8-node", // HostName
    22,
    'ssh-nodes-key', // Credential ID
    customJvmOpts, // JVM Options
    "${alpineJdk8Home}/bin/java", // JavaPath
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
jdk8SSHNodeEnv.add(new Entry("JAVA_HOME","${alpineJdk8Home}"))
EnvironmentVariablesNodeProperty jdk8SSHNodeEnvPro = new EnvironmentVariablesNodeProperty(jdk8SSHNodeEnv);
mavenJDK8Node.getNodeProperties().add(jdk8SSHNodeEnvPro)

Slave mavenJDK12Node = new DumbSlave(
  "maven-jdk12-node",
  "Node for running Maven with OpenJDK12",
  "/home/jenkins",
  "2",
  Node.Mode.EXCLUSIVE,
  "jdk12 java12 maven-jdk12 maven-java12 maven3-jdk12 maven3-java12",
  new SSHLauncher(
    "jenkins-maven-jdknext-node", // HostName
    22,
    'ssh-nodes-key', // Credential ID
    customJvmOpts, // JVM Options
    "${alpineJdk8Home}/bin/java", // JavaPath - Use JDK8 for running the slave.jar
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

List<Entry> jdk12SSHNodeEnv = new ArrayList<Entry>();
jdk12SSHNodeEnv.add(new Entry("JAVA_HOME","${alpineJdk12Home}"))
EnvironmentVariablesNodeProperty jdk12SSHNodeEnvPro = new EnvironmentVariablesNodeProperty(jdk12SSHNodeEnv);
mavenJDK12Node.getNodeProperties().add(jdk12SSHNodeEnvPro)


Jenkins.instance.addNode(productionNode)
println("Added successfully 'docker-node' to Jenkins")

Jenkins.instance.addNode(mavenJDK8Node)
println("Added successfully 'maven-jdk8-node' to Jenkins")

Jenkins.instance.addNode(mavenJDK12Node)
println("Added successfully 'maven-jdk12-node' to Jenkins")
