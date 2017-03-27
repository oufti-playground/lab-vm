import jenkins.*;
import jenkins.model.*;
import hudson.model.*;

def p = AgentProtocol.all()
p.each { x ->
  if (x.name.contains("CLI")) p.remove(x)
}

def removal = { lst ->
  lst.each { x -> if (x.getClass().name.contains("CLIAction")) lst.remove(x) }
}
def j = Jenkins.instance;
removal(j.getExtensionList(RootAction.class))
removal(j.actions)
