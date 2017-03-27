
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*;

global_domain = Domain.global()

credentials_store = Jenkins.instance.getExtensionList(
  'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
)[0].getStore()

credentials = new BasicSSHUserPrivateKey(
  CredentialsScope.GLOBAL,
  "ssh-insecure-key",
  "jenkins",
  new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource('/usr/share/jenkins/ref/insecure_vagrant_key'),
  '',
  "agent-ssh-key"
)

credentials_store.addCredentials(global_domain, credentials)
