import jenkins.model.JenkinsLocationConfiguration

def env = System.getenv()
String externalUrl = env['JENKINS_EXTERNAL_URL']

jlc = JenkinsLocationConfiguration.get()

jlc.setUrl("${externalUrl}")

jlc.save()
