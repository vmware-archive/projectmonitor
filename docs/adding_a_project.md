# Adding a project

After logging in, click the "New Project" button and enter
the details for a build you want to display on ProjectMonitor. The "Name" and
"Project Type" are required. You will need to either connect your service via
Webhooks or polling.

To connect via Webhooks, the project settings page will display the Webhook URL
you'll need to enter in your CI instance's settings. The Webhook URL isn't generated
until after a project is created, so you'll need to select the 'Webhooks' radio button,
click 'Create', and then click the 'Edit' button for the newly-created project
to get the Webhook URL.

In order for Webhooks to work, you'll also need to make sure that the machine hosting
ProjectMonitor is accessible by the machine hosting your CI instance.

If you want to set up a project to connect via polling instead, you'll typically need
to enter the base URL, build name or ID, and your login credentials with the CI service.

## TeamCity

For TeamCity projects, find the buildTypeId (usually something like 'bt2') from the URL, which should look like one of the following: 

    http://teamcity:8111/app/rest/builds?locator=running:all,buildType:
    http://teamcity:8111/viewType.html?buildTypeId=
    http://teamcity:8111/viewLog.html?buildId=1&tab=buildResultsDiv&buildTypeId=

You will also need a valid user account and password.

If you want TeamCity to connect via Webhooks, you'll need to install the
[TcWebHooks plugin](http://sourceforge.net/apps/trac/tcplugins/wiki/TcWebHooks) on 
your TeamCity instance. When setting up the webhook in TeamCity, make sure the payload 
format is set to "JSON" (it might show up as "JSON (beta)").

If you want to connect to TeamCity via polling, you will need to ensure that your TeamCity instance
is accessible by the machine running ProjectMonitor.

## Semaphore

When configuring [Semaphore](http://semaphoreapp.com), you should use the Branch History URL from the API section of your Project Settings page.

This ensures that no build statuses will be missed. 

If you notice that there are build statuses missing in project monitor, ensure that you are NOT using the Branches URL from the API section (vs. the 
recommended Branch History URL).  The Branches URL from the API section returns only the latest build status, instead of the history, so if builds occurred 
between status fetches, they would be missed and not be reflected in project monitor.

## Jenkins

If you want Jenkins to connect via Webhooks, you will need the
[Jenkins notification plugin](https://wiki.jenkins-ci.org/display/JENKINS/Notification+Plugin).

If you want to connect to Jenkins via polling, you'll need to ensure that your Jenkins instance is accessible by the machine running ProjectMonitor.

## Travis

If you want Travis to connect via Webhooks, you will still need to enter the 
GitHub account, repository, and optionally branch name for the codebase being
built in Travis.

## Travis Pro

If you want Travis Pro to connect via polling, you will need your Travis CI token.
You can find this by logging into [Travis CI Pro](https://magnum.travis-ci.com),
clicking your name in the top-right corner, choosing *Accounts*,
then choosing the *Profile* tab. Copy the value listed as your *Token*
into the Project Monitor *New Project* page as your **Travis Pro Token**.

## TDDium

TDDium only supports connecting via polling, not Webhooks.

In order to get polling configured, you will need to log in to your TDDium dashboard, go to Organizations using the drop down in the top right corner.
Then click on organization settings for the appropriate organization. Then click on "Chat Notifications"; CCmenu is at the bottom of the page.
That should take you to a URL that looks like:

    https://api.tddium.com/cc/SOME-TOKEN-HERE/cctray.xml

The value for "SOME-TOKEN-HERE" is the TDDium authentication token you'll need to paste into the ProjectMonitor settings.
The XML returned by that link will look something like:

    <Projects>
       <Project name="foobar (master)" webUrl="https://api.tddium.com/1/reports/151751" lastBuildLabel="151751" 
       lastBuildTime="2013-01-08 18:20:05" lastBuildStatus="Failure" activity="Building"/>
    </Projects>

The "TDDium Project Name" field in the ProjectManager settings will need to be set to the full value of the Project
name attribute, complete with the branch name in parentheses (in this case, "foobar (master)"). 

