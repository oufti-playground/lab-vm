import jenkins.model.*
import hudson.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def strategy = new ProjectMatrixAuthorizationStrategy()

strategy.add(Jenkins.ADMINISTER, "butler")
strategy.add(Jenkins.READ, "anonymous")
strategy.add(hudson.model.Item.READ,'anonymous')
strategy.add(hudson.model.Item.BUILD,'anonymous')

if(!strategy.equals(instance.getSecurityRealm())) {
    instance.setAuthorizationStrategy(strategy)
    instance.save()
}
