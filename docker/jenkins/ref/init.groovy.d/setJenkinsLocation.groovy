import jenkins.model.JenkinsLocationConfiguration

def env = System.getenv()
String externalDomain = env['EXTERNAL_DOMAIN']
String myPublicPort = env['EXTERNAL_PORT']

jlc = JenkinsLocationConfiguration.get()

jlc.setUrl("http://${externalDomain}:${myPublicPort}/")

jlc.save()
