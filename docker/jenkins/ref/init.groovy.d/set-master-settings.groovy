import jenkins.model.*
import hudson.model.*
import hudson.security.csrf.DefaultCrumbIssuer
import org.jenkinsci.plugins.workflow.flow.*

def instance = Jenkins.getInstance()

instance.setNumExecutors(0)
instance.setLabelString('master')
instance.setMode(Node.Mode.EXCLUSIVE)

// We trust users: enable CSP for hosting content
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")

// Enable CSRF protection
instance.setCrumbIssuer(new DefaultCrumbIssuer(false))

// SVN was 15 years ago
instance.setQuietPeriod(0)

instance.save()
