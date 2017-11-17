import jenkins.model.*
import hudson.security.*
import hudson.model.*

def username = 'butler'
def password = username
def userEmail = "${username}@localhost.local"

def instance = Jenkins.getInstance()

// Define default admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username,password)
instance.setSecurityRealm(hudsonRealm)
instance.save()

// Set User email
def user = User.get(username)

def email_param = new hudson.tasks.Mailer.UserProperty(userEmail)
user.addProperty(email_param)
user.save()
