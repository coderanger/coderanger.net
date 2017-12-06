---
title: Jenkins Wrangling for Fun &amp; Profit
date: 2017-12-05
hire_me: Thanks to <a href="https://www.sap.com/">SAP</a> for supporting this work.
---

While there have been [many](https://travis-ci.org/) [new](https://about.gitlab.com/features/gitlab-ci-cd/)
[developments](https://www.gocd.org/) in CI/testing tools, [Jenkins](https://jenkins.io/)
is still a mainstay. And to be fair to the Jenkins team, it has come a tremendous
way in the past few years. The new Pipelines system is more flexible than anything
I've used before, and the Blue Ocean UI is a big graphical and UX upgrade.
My team at SAP started using Jenkins long before I arrived, but over the
years we have slowly accumulated some complaints about how it was working and how
we managed things.

This post is going to be a (very) long-form dive into how we set things up and why.
I do not think this is going to work out of the box for (almost) anyone else, but
the hope is that this will provide a blueprint for others to build their own
solutions on the same general ideas.

## The Problems

Before I launch into what we did, let's list out the issues we had with our
current set up so we are all on the same page. Leaving aside some details that
exist only for PCI, we have a Jenkins server deployed by Chef. Some plugins were
installed originally by the Chef cookbook, but most were installed and upgraded
by hand since then. Jobs were mostly created via a custom CLI tool that talks
to the Jenkins API, but then updated by hand (or more often, not) after that.

So we spent some time in a meeting room with a whiteboard and came up with a
few top-level problems:

1. Upgrades are too unpredictable, both for Jenkins and individual plugins.
2. Jenkins configuration is (mostly) not versioned, ditto for job configs.
3. Job configs can bitrot over time with no easy way to update them other than
   one at a time.
4. No pull-request builds, and overall existing builds are quite slow.

While this applied to a lot of different use cases for Jenkins, the one I chose
to tackle first was Chef cookbook testing, but with a clear eye towards building
a solution which will grow to include other use cases as we want to move them
off the old Jenkins server.

## The Shape

After a bunch of research, the overall shape of the goal came together fairly
quickly. We'll go through each of these in excruciating detail later on, but to
start let's break it down into bullet points:

1. Deployed on Kubernetes, because this is the way we're trying to move everything.
2. Build a container image containing Jenkins, all the plugins, and configuration.
3. Use Helm for managing the deployment (and rollback if needed).
4. Manage the configuration via Jenkins groovy as much as possible.
5. Use the "organization folder" system in Jenkins to auto-detect projects.
6. Use shared pipeline libraries to keep the per-repository config low.
7. Build a container image for the cookbook testing environment that has all
   needed gems pre-installed.
8. Work out a way to test cookbooks on top of Kubernetes pods.

## Kubernetes?

We did briefly look over non-Kubernetes deployment options like building a new Chef
cookbook or using a dedicated Nomad cluster, but with the continued rise of
Kubernetes as an operations platform it seemed like a good idea to use this as
an internal experiment for running "real" (but not customer facing) services
on Kubernetes. In the months since that choice, I think we have only seen the
industry move even more behind Kubernetes as the next dominant platform so this
seems to have been the right move. If you already have a heavy investment in
Mesos or Nomad then perhaps just ignore the Kubernetes-specific bits of this.

Within the Kubernetes ecosystem there are a few tools/patterns for managing
deployment of complex applications (i.e. things that need more than just a pod).
While ["folder full of YAML + kubectl"](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)
and [ksonnet](http://ksonnet.heptio.com/) are nice from a simplicity point-of-view,
the rollback capabilities of [Helm](https://helm.sh/) made it the clear choice in my mind.

The deployment of Kubernetes and Helm themselves are out-of-scope for this post;
there are numerous guides for Kubernetes and setting up Helm is mostly just `helm init`.
Our production cluster is currently on AWS and set up with Kops, but your mileage
may vary if you aren't on AWS. If you just want to play with the stuff in this
post, I would highly recommend starting with a hosted cluster option like Google
GKE, Azure AKS, or the newly announced Amazon EKS.

## The Jenkins Container

The first stop on our journey is building a Docker image for the Jenkins server.
Going line by line so we can talk about it as we go:

```
FROM jenkins/jenkins:2.92-alpine
```

We're starting from the existing Jenkins Docker Hub images. This determines
which version of Jenkins gets used so doing a Jenkins upgrade consists of changing
this line, building a new container, pushing it to our registry, and then upgrading
the Helm release. This is using the Jenkins weekly release, so we try to keep
this bumped roughly once a week, though if it ends up a few weeks behind that's
totally fine.

```
COPY saml-idp-metadata.xml /metadata.xml
COPY plugins.txt /plugins.txt
COPY style.css /style.css
```

Next we copy some base files. The SAP internal authentication system uses SAML
(please hold your sighs for the end) so we store the IdP metadata in a file to
use in the Jenkins config. The plugins.txt looks like:

```
kubernetes:1.1
workflow-aggregator:2.5
workflow-job:2.15
credentials-binding:1.13
git:3.6.4
blueocean:1.3.3
github-oauth:0.28.1
matrix-auth:2.2
saml:1.0.4
```

and gets used later down by the `install-plugins.sh` script that comes in the
base image. The `style.css` file is a few minor tweaks on top of the theme for
things it gets wrong or we didn't like:

```css

// The theme overwrites this so we need to fix.
.glyphicon {
  font-family: 'Glyphicons Halflings' !important;
}

// Theme has no icon for this.
.icon-github-branch {
  background-image: url('/static/ccf6b398/plugin/github-branch-source/images/24x24/github-branch.png');
}

// Force all icons in that bar to be grayscale.
.icon-md {
  filter: grayscale(1);
}
```

Overall files that aren't expected to change often.

```
RUN mkdir -p /usr/share/jenkins/ref/secrets && \
    # Why is this not the default?
    echo false > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch && \
    # Install all our plugins so they are baked in to the image.
    /usr/local/bin/install-plugins.sh < /plugins.txt && \
    # Install a nicer default theme to make it look shiny for non-BlueOcean.
    mkdir /usr/share/jenkins/ref/userContent && \
    curl --compressed http://jenkins-contrib-themes.github.io/jenkins-neo-theme/dist/neo-light.css > /usr/share/jenkins/ref/userContent/neo-light.css.override && \
    cat /style.css >> /usr/share/jenkins/ref/userContent/neo-light.css.override
```

Then the meat of the Dockerfile. A poorly documented feature of the Jenkins
Docker image is that all files under `/usr/share/jenkins/ref` are used to seed
the creation of the JENKINS_HOME folder during startup. Normally these files are
only copied over the first time, but if they end in `.override` it is copied every
time Jenkins starts (with the `.override` trimmed off).

First we set the poorly named `slave-to-master-security-kill-switch` file which
makes it so JNLP builders don't get admin access to the Jenkins server because
we don't want rogue builds to take down the universe if possible.

Next we install all the Jenkins plugins. It should be noted that the Docker
layer cache can sometimes bite you here. Because we only list the top-level
plugins we want (the script handles finding all dependencies), if we want to
upgrade an internal dependency but nothing else has changed, might need to
manually zap the cached layer image. Given that Jenkins itself releases weekly
anyway (meaning we change the `FROM` image and invalidate the whole cache), it's
not hugely likely that this will an operational problem, but be aware.

After that we set up some custom CSS theming. While Blue Ocean does have a nicely
refreshed UI, the default post-login landing page is still the normal UI and we
wanted to spruce that up a bit, both for aesthetic reasons and to make it easier
to tell at a glance which Jenkins server you are looking at. Neo-light seemed
the nicest of the themes that still worked, but you can change or ignore this
part as you wish.

```
COPY config.groovy /usr/share/jenkins/ref/init.groovy.d/zzz_alti-jenkins.groovy.override
COPY plugin/target/alti-jenkins-plugin.hpi /usr/share/jenkins/ref/plugins/alti-jenkins-plugin.hpi.override
```

And finally we copy over two more files. These change more often than the plugins.txt
or Jenkins version (at least so far during development, hopefully that will change
over time) so they go at the end. The config Groovy code gets put in place to be
run automatically at startup, with the weird `zzz` thing because Jenkins alpha-sorts
the hook scripts if there is more than one and we want to be last. The config
itself is big and complex so we'll cover that further down.

The `alti-jenkins` plugin is a bit of an experiment, currently all it does is
add the `<link>` tags to the HTML for the theme CSS and sets a few security HTTP
headers. This could probably be replaced with the `simple-theme` plugin instead,
but I would like to add more stuff to it (ex. custom job health metric that
ignores failed PR builds), so we're leaving it for now.

And with that, we have a Jenkins Docker image. `docker build -t ourrepo.com/alti_jenkins:2.92 .`,
`docker push ourrepo.com/alti_jenkins:2.92`, ???, profit. As a built artifact this
encompasses the Jenkins release, all plugins used, and the configuration code.
Just about everything we could ask for.

We'll talk about the `config.groovy` in just a moment, but because all secrets
(or any other configuration you want to hide) is coming in at run-time from
Kubernetes, this image doesn't actually contain anything that needs to be hidden.
If you aren't running your own registry already, you could push this up to a
public Docker Hub account instead.

## `config.groovy`

This was the bulk of my time on the project, a slowly expanding config script
that started with some basics and now encompasses the entire setup process.
I will lead off with the fact that I am neither a Jenkins nor Groovy expert so
I'm sure this code can be improved, for example I only learned very late in my
writing that `import` is optional in Groovy if you use the fully-qualified
class name. With that in mind, let's go line by line again:

```groovy
import static jenkins.model.Jenkins.instance as jenkins
```

The most important import, the Jenkins object singleton. We use this a ton, so
put it in a magic global.

```groovy
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import hudson.security.GlobalMatrixAuthorizationStrategy
import hudson.security.Permission
import hudson.util.Secret
import jenkins.branch.OrganizationFolder
import jenkins.install.InstallState
import jenkins.plugins.git.GitSCMSource
import org.csanchez.jenkins.plugins.kubernetes.ContainerEnvVar
import org.csanchez.jenkins.plugins.kubernetes.ContainerTemplate
import org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud
import org.csanchez.jenkins.plugins.kubernetes.PodTemplate
import org.csanchez.jenkins.plugins.kubernetes.ServiceAccountCredential
import org.jenkinsci.plugins.github_branch_source.BranchDiscoveryTrait
import org.jenkinsci.plugins.github_branch_source.GitHubSCMNavigator
import org.jenkinsci.plugins.github_branch_source.OriginPullRequestDiscoveryTrait
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import org.jenkinsci.plugins.saml.SamlEncryptionData
import org.jenkinsci.plugins.saml.SamlSecurityRealm
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever

println "--> configuring alti_jenkins"
```

As mentioned, I didn't really know how Groovy imports worked when starting this
so this is mostly not needed but I haven't cleaned it up yet.

```groovy
try {
```

By default, if an init hook script fails, Jenkins prints an error to the log and
keeps on truckin'. The whole config code is inside a `try/catch` so we can at
least attempt to not let it continue starting if we might have failed to configure
something important (like, say, authentication). This will only catch runtime
errors though, if there is a syntax error in the script, that will still result
in Jenkins starting as per usual.

```groovy
  //////// CONFIG
  def secretsRoot = System.getenv('JENKINS_SECRETS') ?: '/var/jenkins_secrets'
  def downwardRoot = System.getenv('DOWNWARD_VOLUME') ?: '/etc/downward'
  println "--> Loading configuration from from secrets:$secretsRoot and downward:$downwardRoot"
  def githubUser = new File("$secretsRoot/github-user").text.trim()
  def githubUserToken = new File("$secretsRoot/github-token").text.trim()
  def samlPass = new File("$secretsRoot/saml-pass").text.trim()
  def samlKeystore = "$secretsRoot/saml-keystore"
  def developmentMode = new File("$secretsRoot/development-mode").text.trim() == 'true'
  def kubeNamespace = new File("$downwardRoot/namespace").text.trim()
  def admins = [
    'nkantrowitz', // Noah Kantrowitz
    'etc', // Someone else
  ]
  def githubOrg = 'MyOrg'
  def librariesRepo = "$githubOrg/jenkins-pipeline-libs"
  def agentVersion = '3.10-1-alpine'

  // Parse the labels test.
  def labels = [:]
  new File("$downwardRoot/labels").eachLine {
    def parts = it.split('=')
    labels[parts[0]] = parts[1][1..-2]
  }
```

Next up, loading and parsing a bunch of configuration data. We'll look at the
pod configuration later on, but this is mostly reading from either a Kubernetes
Secret volume (for secrets) or a Downward API volume (for metadata about the pod
we are running inside of). And then a few hardcoded values that don't change
often enough to be exposed outside of the file/image like the name of the GitHub
organization.

```groovy
  //////// GENERAL SETTINGS
  // Bypass the setup wizard because this script defines all of our config.
  // This is _supposed_ to be handled by /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
  // but that doesn't seem to be working. See https://github.com/jenkinsci/docker#script-usage.
  if (!jenkins.installState.isSetupComplete()) {
    println '--> Neutering SetupWizard'
    InstallState.INITIAL_SETUP_COMPLETED.initializeState()
  }
  // Disable CLI over the remoting protocol for security.
  jenkins.getDescriptor("jenkins.CLI").get().enabled = false
  // More security, disable old/unsafe agent protocols.
  jenkins.agentProtocols = ["JNLP4-connect", "Ping"] as Set
  // Enable CSRF.
  jenkins.crumbIssuer = new hudson.security.csrf.DefaultCrumbIssuer(true)
  // Disable execution on the main server.
  jenkins.numExecutors = 0
```

Then some baseline global configuration. This disables the "welcome to Jenkins" setup
wizard, sets some security stuffs, and turns off job execution on the Jenkins
server itself because we want all jobs to run inside Kubernetes workers.

```groovy
  //////// AUTHENTICATION
  if (new File(samlKeystore).exists()) {
    // Configure the SAML plugin.
    println '--> Configuring SAML authentication realm'
    def realm = new SamlSecurityRealm(
      new File('/metadata.xml').text, // String idpMetadata,
      'display_name', // String displayNameAttributeName,
      '', // String groupsAttributeName,
      SamlSecurityRealm.DEFAULT_MAXIMUM_AUTHENTICATION_LIFETIME, // Integer maximumAuthenticationLifetime,
      'uid', // String usernameAttributeName,
      'email', //  String emailAttributeName,
      '', // String logoutUrl,
      null, // SamlAdvancedConfiguration advancedConfiguration,
      new SamlEncryptionData( // SamlEncryptionData encryptionData,
        samlKeystore, // String keystorePath,
        Secret.fromString(samlPass), // Secret keystorePassword,
        Secret.fromString(samlPass), // Secret privateKeyPassword,
        'saml-key' // String privateKeyAlias
      ),
      'lowercase' // String usernameCaseConversion,
    )
    jenkins.securityRealm = realm
  }
  else {
    println '--> Not configuring SAML'
    // TODO This shoud set up some fallback realm.
  }
```

Ahh the fabled dev `TODO`, I swear I'll get back to that someday. This section is
setting up the authentication system for logging in to Jenkins, the "security realm"
in official parlance. For our production servers we're using our company-wide
SAML SSO system because if I can ever not have to store passwords, I'll take that
option in a heartbeat. If you don't have a a similar internal SSO system, I
would recommend looking at the GitHub OAuth plugin, but you can always use the
internal login form realm if needed. If you are using SAML, the attribute
configuration options are likely to be different for you, but the rest should
look pretty similar. For unknown reasons, the Jenkins SAML plugin refers to the
SP signing key as "encryption data", but it definitely is the signing key. You
can also see here is where we read back in the IdP metadata we embedded in the
Jenkins container image up above.

```groovy
  //////// AUTHORIZATION
  if (developmentMode) {
    // Turn off authorization in case hacking on SAML configs leads to lockout.
    // As it says in the values.yaml, do not do this in production.
    println "--> Configuring Unsecured authorization strategy. THIS BETTER NOT BE PROD."
    def unsecured = new hudson.security.AuthorizationStrategy$Unsecured()
    jenkins.authorizationStrategy = unsecured
  }
  else {
    // Configure matrix auth and ACLs.
    println "--> Configuring Matrix authorization strategy."
    def authz = new GlobalMatrixAuthorizationStrategy()
    [
      "hudson.model.Hudson.Read",
      "hudson.model.Item.Build",
      "hudson.model.Item.Cancel",
      "hudson.model.Item.Discover",
      "hudson.model.Item.Read",
      "hudson.model.Item.Workspace",
      "hudson.model.Run.Replay",
      "hudson.model.Run.Update",
    ].each {
      // Use the string form because I'm lazy and don't want to import all the things.
      authz.add(it + ":authenticated")
    }
    // Admins always get all permissions. Hopefully I won't regret this.
    Permission.getAll().each { perm ->
      admins.each { user ->
        authz.add(perm, user)
      }
    }
    jenkins.authorizationStrategy = authz
  }
```

While the authentication configuration (or security realm if you want to call it
that) determines how users log in, the authorization strategy decides what they
can do once logged in. For general use, we're using the relatively-standard
Matrix authorizer from the plugin of the same name. If you need more complex
access controls you might want to look at the similarly more complex `role-strategy`
authorizer. But here we only really have three bits of authorization config,
first is the `developmentMode` setting coming in from Secret volume. If that is
set we entirely disable authorization. This in here for times where I need to
hack on the authentication config or if I'm offline somewhere and don't have
access to the corporate SAML servers. Otherwise for the Matrix we set up one
entry for the generic "logged-in user" group to give them some minimal, read-only
permissions, which is enough for normal users to view builds and force them to
re-run if they end up with a flaky test (though hopefully they will fix it soon
after). For admins, we create one row for each administrator giving them every
permission available in Jenkins. Because this is rebuilt from scratch every time
the configuration script runs, it means that is we do manage to break the
permissions settings via "accidental" clicking in the web configuration GUI, it
will at least get automatically restored as soon as we restart the container.

```groovy
  //////// GITHUB CONFIG
  // Create the credentials used to access GitHub.
  def creds = CredentialsProvider.lookupCredentials(StandardUsernamePasswordCredentials, jenkins)
  def cred = creds.findResult { it.description == "GitHub access token" ? it : null }
  if (cred) {
    println "--> Updating existing GitHub access token credential ${cred.id}"
    def newCred = new UsernamePasswordCredentialsImpl(
      cred.scope,
      cred.id,
      cred.description,
      githubUser,
      githubUserToken)
    SystemCredentialsProvider.instance.store.updateCredentials(Domain.global(), cred, newCred)
  }
  else {
    println '--> Creating GitHub access token credential'
    cred = new UsernamePasswordCredentialsImpl(
      CredentialsScope.GLOBAL,
      java.util.UUID.randomUUID().toString(),
      "GitHub access token",
      githubUser,
      githubUserToken)
    SystemCredentialsProvider.instance.store.addCredentials(Domain.global(), cred)
  }
```

Next we construct a Jenkins credential with our GitHub access token. This was
read in up at the top from the Secret volume, and here we either create a new
credential if one isn't found, or update the existing one. Again, the goal is
convergent behavior so every time Jenkins start, it tries to match the persistent
state to the desired state.

```groovy
  //////// GLOBAL LIBRARIES
  def retriever = new SCMSourceRetriever(new GitSCMSource(
    "pipeline",
    "https://github.com/${librariesRepo}.git/",
    cred.id,
    "*",
    "",
    false))
  def pipeline = new LibraryConfiguration("pipeline", retriever)
  pipeline.defaultVersion = "master"
  pipeline.implicit = true
  pipeline.includeInChangesets = false
  jenkins.getDescriptor("org.jenkinsci.plugins.workflow.libs.GlobalLibraries").get().setLibraries([pipeline])
```

This configures the shared pipeline libraries. We'll show the library code further
down, but roughly this allows having a centralized repo with Groovy snippets
that can be used by the per-repo Jenkinsfiles. In practical terms, this actually
contains almost all of the pipeline logic, the final Jenkinsfile is currently
always exactly one line long, calling one of the global presets. The `implicit`
setting means Jenkinsfiles don't have to explicitly include the library, and
disabling `includeInChangesets` means that a new version of the library won't
trigger every job to build (though that would certainly be a nice load test).

```groovy
  //////// CLOUUUUUD (NOT BUTT)
  // Register the Kubernetes magic secret.
  creds = CredentialsProvider.lookupCredentials(ServiceAccountCredential, jenkins)
  if (creds.isEmpty()) {
    println '--> Creating Kubernetes service account credential'
    kubeCred = new ServiceAccountCredential(
      CredentialsScope.GLOBAL,
      java.util.UUID.randomUUID().toString(),
      "Kubernetes service account")
    SystemCredentialsProvider.instance.store.addCredentials(Domain.global(), kubeCred)
  }
  else {
    kubeCred = creds[0]
  }
```

Starting in on setting up the Kubernetes support in Jenkins. The plugin declares
a special credential type that effectively loads on the fly from the pod's service
account. But we still need to actually create that stub secret to feed into the
rest of config. I guess if we weren't using a service account this would be
different, but service account are what the cool kids do.

```groovy
  // Configure the cloud plugin.
  println '--> Configuring Kubernetes cloud plugin'
  def cloud = new KubernetesCloud('kubernetes')
  cloud.serverUrl = 'https://kubernetes.default'
  cloud.namespace = kubeNamespace
  cloud.jenkinsUrl = "http://${labels['app']}:8080"
  cloud.jenkinsTunnel = "${labels['app']}-agent:50000"
  cloud.credentialsId = kubeCred.id
  def podTemplate = new PodTemplate()
  podTemplate.name = 'default'
  podTemplate.label = "${labels['release']}-agent"
  def containerTemplate = new ContainerTemplate('jnlp', "jenkins/jnlp-slave:$agentVersion")
  containerTemplate.workingDir = '/home/jenkins'
  containerTemplate.command = ''
  containerTemplate.args = '${computer.jnlpmac} ${computer.name}' // Single quotes are intentional.
  containerTemplate.envVars.add(new ContainerEnvVar('JENKINS_URL', cloud.jenkinsUrl))
  containerTemplate.resourceRequestCpu = '200m'
  containerTemplate.resourceLimitCpu = '200m'
  containerTemplate.resourceRequestMemory = '256Mi'
  containerTemplate.resourceLimitMemory = '256Mi'
  podTemplate.containers.add(containerTemplate)
  cloud.addTemplate(podTemplate)
  jenkins.clouds.clear()
  jenkins.clouds.add(cloud)
```

Then the actual cloud plugin configuration. This aims the plugin at the same
cluster as Jenkins is running inside of, and uses the pod's service account
credentials as mentioned above. Then we set up a pod and container template
for the JNLP worker. This handles the communication with Jenkins once the worker
pod launches, but we'll add additional containers to it in our pipeline libraries
to do the actual heavy lifting of the build. Those resource limits are based on
the Helm community chart for Jenkins and I'm not yet sure if they reflect reality
when Jenkins is under heavy load.

```groovy
  //////// PROJECT FOLDER
  println '--> Creating organization folder'
  // Create the top-level item if it doesn't exist already.
  def folder = jenkins.items.isEmpty() ? jenkins.createProject(OrganizationFolder, 'MyName') : jenkins.items[0]
  // Set up GitHub source.
  def navigator = new GitHubSCMNavigator(githubOrg)
  navigator.credentialsId = cred.id // Loaded above in the GitHub section.
  navigator.traits = [
    // Too many repos to scan everything. This trims to a svelte 265 repos at the time of writing.
    new jenkins.scm.impl.trait.WildcardSCMSourceFilterTrait('*-cookbook', ''),
    // We have a ton of old branches so try to limit to just master and PRs for now.
    new jenkins.scm.impl.trait.RegexSCMHeadFilterTrait('^(master|PR-.*)'),
    new BranchDiscoveryTrait(1), // Exclude branches that are also filed as PRs.
    new OriginPullRequestDiscoveryTrait(1), // Merging the pull request with the current target branch revision.
  ]
  folder.navigators.replace(navigator)
```

This part I'm very proud of. The traditional way to automate Jenkins job
creation is the venerable Job DSL plugin. Job DSL uses its own Groovy scripting
API to create and manage jobs totally separately from the Jenkins Groovy
scripting framework, usually using a single "seed job" to create all the others.
This special DSL does (easily) support this use case, but I wanted to try and
avoid it. Having one fewer plugin to worry about, as well as a more tightly
integrated configuration seemed worth a bit of extra exploration. Building the
job configuration in pure Jenkins Groovy turned out to be pretty
straightforward other than being entirely undocumented, almost all of the
default values are actually what you want in this case. This block of code will
create the top-level folder and set up the GitHub folder source. As mentioned in the
comments, the organization scan was being too slow for my tastes so I set up
those two filter traits to cut down on the number of things Jenkins will even
bother checking for a Jenkinsfile. As I expand past just cookbook testing those
will probably go away, and the org scan only runs once a day so it being slow
isn't actually a runtime problem, I was just being impatient in development.

An aside about the GitHub plugin and webhooks. The plugin can automatically
configure the organization webhook for you, however I'm not actually doing that
here. That would require giving Jenkins an admin-capable token which I prefer
not to do. If you're adapting this config to create dozens of organization folder,
maybe consider putting that back in (add `navigator.afterSave(folder)` after the
`save()` in the next snippet) but barring that I would just configure it manually.
You'll want to set the URL to `https://myjenkinsserver.com/github-webhook/` and
enable the `push`, `pull request`, and `repository` events.

```groovy
  println '--> Saving Jenkins config'
  jenkins.save()
```

We did it! I don't think a manual save is actually required but it makes life
slightly easier if we have to `kubectl exec` to log in and stare at the `config.xml`
manually.

```groovy
  println '--> Scheduling GitHub organization scan'
  Thread.start {
    sleep 30000 // 30 seconds
    println '--> Running GitHub organization scan'
    folder.scheduleBuild()
  }
```

Because we really wanted this to be fully hands-off, we schedule a org scan on
startup. This has to wait for a few other startup tasks inside Jenkins, so it
runs 30 seconds after this script.

```groovy
  println "--> configuring alti_jenkins... done"
}
catch(Throwable exc) {
  println '!!! Error configuring alti_jenkins'
  org.codehaus.groovy.runtime.StackTraceUtils.sanitize(new Exception(exc)).printStackTrace()
  println '!!! Shutting down Jenkins to prevent possible mis-configuration from going live'
  jenkins.cleanUp()
  System.exit(1)
}
```

And then finally the `catch` for those runtime errors we talked about up at the
start. This will print the error to the log (ends up `kubectl logs` or whatever
else you are using) and then tells Jenkins to shut down.

And there you have it. A fully convergent configuration script to set up a
working Jenkins based on GitHub and Pipelines and all that jazz. Now we just
need to run this sucka'.

## Helm Chart

We started out first trying to use the [community Helm chart](https://github.com/kubernetes/charts/tree/master/stable/jenkins)
for Jenkins directly, and then making a wrapper chart, but both approaches
turned out more complex than we wanted. At this time, my recommendation for
charts as complex as Jenkins is to fork them and use them as a starting point
for your own chart. As an example, the community chart uses the Jenkins
container image directly, and installs the config and plugins in an
initContainer, rather than building our image as shown above. We felt this
approach left too many moving pieces at deploy time and potentially compromised
our ability to do rollbacks if an upgrade didn't go according to plan. I'm not
going to show the entire chart as there is a lot that is going to be specific to
my specific requirements but I do want to talk about the core of it.

### Deployment

As with most simple applications, the heart of the deployment is a Kubernetes
Deployment object, which manages the actual pods.

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "alti-jenkins.fullname" . }}
  labels:
    app: {{ template "alti-jenkins.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
    component: "{{ .Release.Name }}-jenkins"
```

We start with a pretty standard set of metadata for a Helm-created object. Some
of these values are used for selectors in the service/ingress side of things,
but mostly these are to aid in human debugging and management.

```yaml
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      component: "{{ .Release.Name }}-jenkins"
```

Simple defaults, we only want one pod at a time because Jenkins' idea of HA is
"restart it if it crashes" so leave things at that.

```yaml
  template:
    metadata:
      labels:
        app: {{ template "alti-jenkins.fullname" . }}
        heritage: "{{ .Release.Service }}"
        release: "{{ .Release.Name }}"
        chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
        component: "{{ .Release.Name }}-jenkins"
      annotations:
        checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

Next the same metadata but for the Pod object this time. The annotation is
somewhat standard Helm pattern where we put a checksum of the rendered Secret
object in the Deployment so that when the Secret changes, the Deployment will
re-roll the pods automatically. This is needed because our config code only
looks at the secret data at container startup, so if they change after that it
will be ignored. The actual checksum isn't used for anything, but it changing
will trigger Tiller (the server component of Helm) to update the Deployment,
which triggers the Pods to re-roll.

```yaml
    spec:
      serviceAccountName: {{ template "alti-jenkins.fullname" . }}
      imagePullSecrets:
        - name: {{ template "alti-jenkins.fullname" . }}-pull
      securityContext:
        # This is the default gid for the jenkins group in the upstream container.
        fsGroup: 1000
```

Some general Pod configuration, setting the service account for Jenkins, the
image pull secret to talk to our internal registry to download the `alti_jenkins`
image we made before, and setting the GID used for volume mounts down below so
that we can lock down the file modes a little bit just in case someone manages
to get a shell on the Jenkins container somehow.

```yaml
      containers:
        - name: {{ template "alti-jenkins.fullname" . }}
          image: "{{ .Values.Server.Image }}:{{ .Values.Server.ImageTag }}"
          {{- if .Values.Server.ImagePullPolicy }}
          imagePullPolicy: "{{ .Values.Server.ImagePullPolicy }}"
          {{- end }}
```

Basic container set up, nothing too interesting here. The only reason to change
the image pull policy is to set it to `Always` in local development if I'm
rebuilding the same image version multiple times before I release it. But I
usually do my development in minikube anyway, so I use `minikube docker-env` to
build directly in the Docker daemon used by Kubernetes later on:
`( eval "$(minikube docker-env)" && docker build -t myrepo.com/alti_jenkins:2.whatever )`.

```
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 50000
              name: agentlistener
```

Expose two ports, one for HTTP and the other for JNLP workers. Unlike the
community chart, I didn't see much reason to make these configurable since there
is no worry of port collisions or whatever.

```yaml
          resources:
            requests:
              cpu: "{{ .Values.Server.Cpu }}"
              memory: "{{ .Values.Server.Memory }}"
```

We don't yet really have a good idea for what these limits should be from production
data under heavy load, so just make them configurable for now.

```yaml
          volumeMounts:
            - mountPath: /var/jenkins_home
              name: jenkins-home
            - mountPath: /var/jenkins_secrets
              name: jenkins-secrets
              readOnly: true
            - name: downward
              mountPath: /etc/downward
              readOnly: true
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: {{ .Values.Persistence.ExistingClaim | default (include "alti-jenkins.fullname" .) }}
      - name: jenkins-secrets
        secret:
          secretName: {{ template "alti-jenkins.fullname" . }}
          defaultMode: 0440
      - name: downward
        downwardAPI:
          items:
            - path: labels
              fieldRef:
                fieldPath: metadata.labels
            - path: namespace
              fieldRef:
                fieldPath: metadata.namespace
```

And then the volumes. We need three volumes for three different purposes. The
big one is the JENKINS_HOME mount. Despite my best efforts towards immutable
configuration, Jenkins still does store a lot of state in the JENKINS_HOME
directory, like job history and build artifacts. As such, this needs to be
persistent at least over short timescales. If we lost this persistent volume we
could still trivially rebuild Jenkins, but we would lose enough history that it
might be frustrating. So for now, PVC.

Then the two configuration volumes, a Secret volume and the Downward API volume.
As we saw back at the top of the `config.groovy`, these are used to feed configuration
data into the Jenkins config. The `defaultMode` settings works with `fsGroup`
up above to slightly restrict things, though probably not in a way that really
matters but yay for defense in depth.

### Secret

Mostly pretty rote, but including it here as an example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "alti-jenkins.fullname" . }}
  labels:
    app: {{ template "alti-jenkins.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
type: Opaque
data:
  artifactory-token: {{ required "Secrets.ArtifactoryToken is required" .Values.Secrets.ArtifactoryToken | b64enc | quote }}
  github-user: {{ required "Secrets.GithubUser is required" .Values.Secrets.GithubUser | b64enc | quote }}
  github-token: {{ required "Secrets.GithubToken is required" .Values.Secrets.GithubToken | b64enc | quote }}
  saml-keystore: {{ required "Secrets.SamlKeystore is required" .Values.Secrets.SamlKeystore | nospace | quote }}
  saml-pass: {{ required "Secrets.SamlPass is required" .Values.Secrets.SamlPass | b64enc | quote }}
  # Not technically secret but convenient to put here because the same kind of code needs them.
  development-mode: {{ printf "%t" .Values.Server.DevelopmentMode | b64enc | quote }}
```

One thing to note is that the `SamlKeystore` value is coming in already base64-encoded
because it's a binary file format and it's vastly easier to store it in the Helm
values file (and Tiller storage of the same) as text data. Given that we expect
this value to change infrequently (cert rotation, or in case of a security issue),
we just put it in base64 up front by hand.

### Services

We end up with two services, one each for HTTP and worker traffic.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ template "alti-jenkins.fullname" . }}
  labels:
    app: {{ template "alti-jenkins.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
    component: "{{.Release.Name}}-jenkins"
spec:
  ports:
    - port: 8080
      targetPort: 8080
      name: http
  selector:
    component: "{{.Release.Name}}-jenkins"
```

and then:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ template "alti-jenkins.fullname" . }}-agent
  labels:
    app: {{ template "alti-jenkins.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
    component: "{{ .Release.Name }}-jenkins"
spec:
  ports:
    - port: 50000
      targetPort: 50000
      name: agentlistener
  selector:
    component: "{{ .Release.Name }}-jenkins"
  type: ClusterIP
```

### Ingress

And finally an Ingress to handle TLS in production. We went with an Ingress
because we wanted to use [`kube-lego`](https://github.com/jetstack/kube-lego) to
automate certificates via LetsEncrypt. If you're on AWS and want to use ACM
instead, you can do that directly via the first Service object above.

```yaml
{{- if .Values.Server.PublicHostname }}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ template "alti-jenkins.fullname" . }}
  labels:
    app: {{ template "alti-jenkins.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  annotations:
    kubernetes.io/tls-acme: "true"
spec:
  tls:
    - secretName: {{ template "alti-jenkins.fullname" . }}-tls
      hosts:
        - {{ .Values.Server.PublicHostname | quote }}
  rules:
    - host: {{ .Values.Server.PublicHostname | quote }}
      http:
        paths:
          - path: /
            backend:
              serviceName: {{ template "alti-jenkins.fullname" . }}
              servicePort: 8080
{{- end }}
```

This will only be active on production, for local development I just talk
directly to the service via minikube's `minikube service` helper command. I've
only tested with the Nginx ingress controller, but I would imagine it should
work with the GCE ingress too, and any other controller supported by `kube-lego`.
In production we installed both `nginx-ingress` and `kube-lego` using
their community Helm charts directly:

```bash
$ helm install -n nginx-ingress stable/nginx-ingress
$ helm install --set config.LEGO_EMAIL=me@example.com \
  --set config.LEGO_URL=https://acme-v01.api.letsencrypt.org/directory \
  -n kube-lego stable/kube-lego
```

## Global Pipeline Libraries

Okay, so we have a working, running Jenkins server. Progress! Next step is to
get some actual builds on it. Because we have hundreds of cookbooks which should
all use the same build logic, we wanted to make sure all of that was kept
somewhere centralized. Jenkins' global libraries system made this very easy,
though as I've only attacked the cookbook testing use case I don't actually
have very much yet.

An aside about how to structure this: each helper goes in a file named
`vars/nameOfHelper.groovy`. The bit after `vars/` is what ends up being the
function name for your Jenkinsfiles.

```groovy
// vars/altiNode.groovy
def call(Closure body) {
  def secretsRoot = System.getenv('JENKINS_SECRETS') ?: '/var/jenkins_secrets'
  def artifactoryToken = new File("$secretsRoot/artifactory-token").text.trim()

  withEnv(['CI=true', "BERKSHELF_PATH=${env.WORKSPACE}/.berkshelf", "ARTIFACTORY_API_KEY=$artifactoryToken"]) {
    node('cookbook') {
      container('alti-pipeline') {
        body()
      }
    }
  }
}
```

First a utility helper to help avoid too many levels of indentation in other
helpers. This is like the build in `node {}` pipeline step but with some standard
stuffs for our testing environment.

```groovy
// vars/altiCookbook.groovy
def call(Closure body) {
    def altiPipelineVersion = '4.9.2'

    def downwardRoot = System.getenv('DOWNWARD_VOLUME') ?: '/etc/downward'

    // Parse the labels test.
    def labels = [:]
    new File("$downwardRoot/labels").eachLine {
      def parts = it.split('=')
      labels[parts[0]] = parts[1][1..-2]
    }
```

Next is the interesting one, the cookbook testing pipeline, though currently
a very simple one. First we do some configuration stuff like we saw in `config.groovy`.
It is, in fact, a copy-pasta because I couldn't find a reasonable way to share
code between the two contexts and it's not very long anyway.

```groovy
    podTemplate(label: 'cookbook', imagePullSecrets: ["${labels['app']}-pull"], containers: [
      containerTemplate(name: 'alti-pipeline', image: "altiscale-docker-dev.jfrog.io/alti_pipeline:${altiPipelineVersion}", alwaysPullImage: false, command: "/bin/sh -c \"trap 'exit 0' TERM; sleep 2147483647 & wait\""),
    ]) {
```

Then we set up the pod for our job to build in. This will be combined with the
podspec we gave the Kubernetes cloud plugin up in the Jenkins configuration so
the final pod will end up with two containers, one for the JNLP worker and another
with the build environment image. The build environment doesn't actually have
a service to run, so use the sleep wait to keep it busy until the pod is shut down.

```groovy
        def integrationTests = []
        stage('Check') {
            altiNode {
                checkout scm
                // Check that we have an acceptable version of alti_pipeline, just looks at the major version.
                def gemfile = readFile('Gemfile')
                if(gemfile =~ /gem.*alti_pipeline.*\b${altiPipelineVersion[0]}\./) {
                    echo "Gemfile is compatible with alti_pipeline ${altiPipelineVersion}"
                } else {
                    error "Gemfile is not compatible with alti_pipeline ${altiPipelineVersion}:\n"+gemfile
                }
                // Parse out the integration tests for use in the next stage.
                integrationTests = sh(script: 'kitchen list --bare', returnStdout: true).split()
            }
        }
```

The first stage is a sanity check. Unlike many Chef shops, we don't actually use
ChefDK (that would have to be a whole 'nother blog post so just take it as a given)
and instead have a Gemfile in each cookbook that points it at our equivalent gem,
`alti_pipeline`. Here we want to make sure that the cookbook's Gemfile is the
same major version as the build image since if it isn't, the build is very
unlikely to work. We also grab the list of all Test Kitchen instances to build in
the next stage.

```groovy
        stage('Test') {
            testJobs = [
                'Lint': {
                    altiNode {
                        checkout scm
                        sh 'rm -f Gemfile Gemfile.lock'
                        sh 'rake style'
                    }
                },
                'Unit Tests': {
                    altiNode {
                        checkout scm
                        try {
                            sh 'rm -f Gemfile Gemfile.lock'
                            sh 'rake spec'
                        } finally {
                            junit 'results.xml'
                        }
                    }
                },
            ]
            integrationTests.each { instance ->
              testJobs["Integration $instance"] = {
                    altiNode {
                        checkout scm
                        sh 'rm -f Gemfile Gemfile.lock'
                        sh "kitchen test --destroy always $instance"
                    }
                }
            }
            parallel(testJobs)
        }

        body()

    }
}
```

And then finally the actual test bit of the pipeline. This sets up jobs for
lint checking, unit tests, and one job each for the integration tests so they
can all run in parallel. You can see this uses the `altiNode` helper from above,
instead of the usual `node` pipeline step. We're also removing the Gemfile in-place
since we've already installed all the needed gems in my build environment image
and don't want bundler to even try and activate.

## Cookbook Integration Testing

As part of this project I also built a new Test Kitchen driver, [`kitchen-kubernetes`](https://github.com/coderanger/kitchen-kubernetes),
specifically for running Chef cookbook integration tests on top of Kubernetes.
This works similarly to `kitchen-docker` and `kitchen-dokken`, but using
Kubernetes machinery rather than plain Docker containers. If duplicating this
set up for yourself, make sure you remember to include `rsync` in the job build
image (`alti_pipeline` above) as that is required for `kitchen-kubernetes`'s
file upload system.

## Build Environment Image

While most people doing Chef cookbook testing should probably use the [`chef/chef-dk`](https://hub.docker.com/r/chef/chefdk/)
image, as mentioned before we are not using ChefDK for our environment management.
The short version of "why" is that we're still on Chef 12 but wanted newer versions
of a lot of tools, as well as including a lot of our own utility gems. We may
yet transition back to ChefDK but for now we needed to create a container image
that included a bunch of private gems. Pulling in private gems means including
an access token for the repository (careful readers have probably figured out
by now that we use Artifactory), but unfortunately build-time secrets are still
a notable problem with `docker build`. There are a few options, short-lived tokens
that do get baked in to the image but are already expired by the time anyone
could get them, localhost proxies that handle authentication, use of alternative
image build systems like [Habitat](https://habitat.sh/)/[buildah](https://github.com/projectatomic/buildah), but we
decided to try and keep it simple and use the new "squash build" feature in Docker.

We decided to use `alpine` as the base image (shoutout to the great folks at
[Glider Labs](https://gliderlabs.github.io/devlog/)) to minimize the file size. Kubernetes does cache images
aggressively, but every little bit helps in improving build performance. The
final `Dockerfile` looks like this:

```
FROM alpine:latest
ENV VERSION=4.9.2
ENV ALTISCALE_KITCHEN_KUBERNETES=true
ENV ALTISCALE_BERKS_ARTIFACTORY=true
COPY .gemrc /root
RUN set -x && \
    apk --update-cache add build-base ruby-io-console ruby ruby-dev libffi libffi-dev zlib zlib-dev curl git openssh-client rsync && \
    gem install alti_pipeline -v $VERSION && \
    git clone https://github.com/coderanger/kitchen-kubernetes /tmp/kitchen-kubernetes && \
    ( cd /tmp/kitchen-kubernetes && gem build *.gemspec && gem install --local *.gem ) && \
    curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    gem sources --clear-all && \
    rm -rf /root/.gemrc /usr/lib/ruby/gems/2.4.0/cache/*.gem /tmp/kitchen-kubernetes && \
    for f in /usr/lib/ruby/gems/2.4.0/gems/*; do rm -rf $f/spec $f/test $f/examples $f/distro $f/acceptance; done && \
    apk del build-base ruby-dev libffi-dev zlib-dev curl
```

This can be broken down in to four parts. First the base image and some
environment variables we want set for all builds. Then copying the gem server
credentials, from this point on things become radioactive because we have a
secret value in the image. Then the installs, first a bunch of Alpine packages
we need, then the top-level `alti_pipeline` gem, `kitchen-kubernetes` (from git
because I haven't actually put up a release yet), and  `kubectl` (for use by
`kitchen-kubernetes`). Finally a whole bunch of cleanup. This is mostly to
reduce the final image size, removing files and packages we don't need after
image creation. But also we remove the `.gemrc`, making the image no longer
radioactive if built correctly.

Even with this `COPY`+`rm` though, we need to make sure to build the image using
`docker build --squash` (which requires experimental features be enabled on the
Docker daemon, add `--experimental=true` to the daemon command line). If built
without `--squash`, the final image would _look_ like it doesn't have the token,
but it would still be visible in the intermediary layer created between the
`COPY` and `RUN`. Hopefully at some point there will be a better solution for
build-time secrets, but for now this is enough to get us a build environment
weighing in at around 100MB.

## Per-Repo Jenkinsfile

One requirement of this set up is you do need to put a Jenkinsfile in each
repository you want to be built. This might be frustrating for some, having to
touch every repo when that could potentially be (and in my case, is) hundreds
of projects. That said, currently the Jenkinsfile we are adding to each repo is
literally `altiCookbook { }`. So it's not much in terms of footprint, but you
do have to do the legwork, either by hand or via a script using the GitHub API.

## To Conclude

As I mentioned at the start, my goal here is to provide a jump start in designing
your own Jenkins deployment. I suspect the precise combo of design choices shown
here might be literally unique in the world, but most of the bits are very
modular and the overall structure should be a starting point for your own
specifics.

If you have any questions on any of this code or the design decisions behind it
you can reach me at <a href="&#x6d;&#97;&#x69;&#108;&#x74;&#111;&#x3a;&#110;&#111;&#x61;&#104;&#x40;&#x63;&#x6f;&#x64;&#101;&#114;&#x61;&#110;&#103;&#101;&#x72;&#46;&#110;&#x65;&#x74;">&#110;&#x6f;&#97;&#x68;&#x40;&#x63;&#111;&#100;&#101;&#x72;&#x61;&#x6e;&#x67;&#x65;&#114;&#46;&#110;&#x65;&#x74;</a>.
