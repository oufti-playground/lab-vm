import jenkins.model.*;

import org.jenkinsci.plugins.workflow.libs.*;
import jenkins.scm.api.SCMSource;

GlobalLibraries globalLibs = GlobalConfiguration.all().get(GlobalLibraries.class)

SCMSource scm = new jenkins.plugins.git.GitSCMSource(
  "",
  "https://github.com/oufti-playground/pipeline-libraries",
  "",
  "",
  "",
  false
)

LibraryRetriever libRetriever = new SCMSourceRetriever(scm)

LibraryConfiguration libConfig = new LibraryConfiguration(
  "deploy",
  libRetriever
)

libConfig.setDefaultVersion("master")
libConfig.setImplicit(true)

List<LibraryConfiguration> libraries= new ArrayList<LibraryConfiguration>()
libraries.add(libConfig)

globalLibs.setLibraries(libraries)
