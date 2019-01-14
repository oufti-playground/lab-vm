import jenkins.model.*;

import org.jenkinsci.plugins.workflow.libs.*;
import jenkins.scm.api.SCMSource;

GlobalLibraries globalLibs = GlobalConfiguration.all().get(GlobalLibraries.class)

SCMSource scm = new jenkins.plugins.git.GitSCMSource(
  "",
  "http://gitserver:3000/butler/pipeline-libraries.git",
  "",
  "",
  "",
  false
)

LibraryRetriever libRetriever = new SCMSourceRetriever(scm)

LibraryConfiguration libConfig = new LibraryConfiguration(
  "pipeline-libraries",
  libRetriever
)

libConfig.setDefaultVersion("master")
libConfig.setImplicit(true)

List<LibraryConfiguration> libraries= new ArrayList<LibraryConfiguration>()
libraries.add(libConfig)

globalLibs.setLibraries(libraries)
