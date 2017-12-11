import jenkins.model.*
import hudson.model.*
import hudson.slaves.*
import hudson.security.csrf.DefaultCrumbIssuer

def instance = Jenkins.getInstance()

// One executor for deploying
instance.setNumExecutors(0)
instance.setLabelString('master')
instance.setMode(Node.Mode.EXCLUSIVE)

// We trust users: enable CSP for hosting content
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")

// Don't enable CSRF or webhooks are not working
// instance.setCrumbIssuer(new DefaultCrumbIssuer(false))

// SVN was 15 years ago
instance.setQuietPeriod(0)

instance.save()
