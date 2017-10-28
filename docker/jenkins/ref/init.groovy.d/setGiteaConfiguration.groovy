import jenkins.model.*

import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*

/*********************************
// Add the Gitea Admin Credential
*********************************/

domain = Domain.global()

store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "local-gitea-admin-credentials", // Credential ID
  "Local Gitea Admin Credentials", // Description
  "butler", // Username
  "butler" // Password
)

store.addCredentials(domain, usernameAndPassword)

/************************************
// Add the Gitea Global Configuration
************************************/

// Nothing to do here: we use an XML for now
