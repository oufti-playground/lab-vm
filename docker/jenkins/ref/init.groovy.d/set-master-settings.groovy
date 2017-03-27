import jenkins.model.*
import hudson.model.*
import hudson.slaves.*

def instance = Jenkins.getInstance()

// One executor for deploying
instance.setNumExecutors(0)
instance.setLabelString('master')
instance.setMode(Node.Mode.EXCLUSIVE)

// We trust users: enable CSP for hosting content
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")

instance.setQuietPeriod(0)

instance.save()
