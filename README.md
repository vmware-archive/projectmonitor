Description [![Build Status](https://secure.travis-ci.org/pivotal/projectmonitor.png?branch=master)](http://travis-ci.org/pivotal/projectmonitor) [![Code Climate](https://codeclimate.com/github/pivotal/projectmonitor.png)](https://codeclimate.com/github/pivotal/projectmonitor)
===========

ProjectMonitor is a CI display aggregator. It displays the status of multiple
Continuous Integration builds on a single web page.  The intent is that you
display the page on a big screen monitor or TV so that the status of all your
projects' builds are highly visible/glanceable (a "Big Visible Chart").
ProjectMonitor currently supports:

  * [CircleCI](http://circleci.com)
  * [Codeship](https://www.codeship.io/)
  * [Concourse](http://concourse.ci/)
  * [Cruise Control](http://cruisecontrolrb.thoughtworks.com/)
  * [Jenkins](http://jenkins-ci.org/)
  * [Semaphore](http://www.semaphoreci.com/)
  * [Solano CI (formerly loved as tddium)](http://solanolabs.com/)
  * [TeamCity](http://www.jetbrains.com/teamcity/)
  * [Travis CI](http://travis-ci.org/)
  * [Travis CI Pro](http://travis-ci.com/)

We use ProjectMonitor internally at Pivotal Labs to display the status of the
builds for all our client projects. We also have an instance of ProjectMonitor
running at [ci.pivotallabs.com](http://ci.pivotallabs.com) that we use for
displaying the status of the builds of various open source projects - both of
projects Pivotal Labs maintains (such as Jasmine) and of non-Pivotal projects
(such as Rails).

[![](http://f.cl.ly/items/2R2U392y1D2B033I0z3J/Screen%20Shot%202013-04-02%20at%208.27.44%20PM.png)](http://ci.pivotallabs.com)

## Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Deployment](#deployment)
4. [Ideas and Improvements](#ideas-and-improvements)

## Linked Documents

1. [Upgrading to Devise](docs/upgrading_to_devise.md)
2. [Adding a Project](docs/adding\_a\_project.md)
3. [Displaying Your Project's Status](docs/displaying\_your\_projects\_status.md)

## Installation

### Get the code
ProjectMonitor is a Rails application. To get the code, execute the following:

    git clone git://github.com/pivotal/projectmonitor.git
    cd projectmonitor
    brew install qt
	bundle install

It seems that the `qt` requirement is a relic of the past, we checked
and could not find any reference to it in the code.

### Initial Setup (local workstation)

ProjectMonitor depends on a running Postgres database instance.
Connection details for this database should be specified in
`config/database.yml`.  An example configuration file has been
supplied in `database.yml.example`, but you may need to edit it
before you can use it.  You can copy the file to `database.yml` yourself or use the
following command to do so:

    rake setup

If you run a local postgres server that is set up well, you won't have
to change the settings.  Do not create the three tables mentioned in
the configuration file yet, the next step will do that for you. 

If you have Postgres installed but not running, you can try this
(confirmed on OS-X Yosemite and Ubuntu 14.04) to run the database from
a subdirectory of the project (useful for development):

    mkdir data
    initdb -D data
	pg_ctl start -D data -l data/logfile

You should see several postgres processes if you run `ps -ef | grep
postgres`. 

### Creating the tables on the database

We assume you have created and updated the `config/database.yml` file.
The following commands will create and populate the databases for the
production environment (first 2 lines) and the development environment
(last 2 lines; development is the default):

    RAILS_ENV=production rake db:create
    RAILS_ENV=production rake db:migrate
    rake db:create
    rake db:migrate

### Authentication support
#### IP Whitelist
If you want to use Webhooks, your ProjectMonitor instance will need to be located on a
publicly accessible server. If you don't want your ProjectMonitor dashboard to also be
publicly accessible, you can whitelist access by IP address.

The whitelist is disabled by default, but can be enabled by uncommenting the `ip_whitelist` property
in settings.yml and adding a list of IP addresses to whitelist. If you're running ProjectMonitor
behind a load balancer (e.g. on a hosted provider such as Heroku), you'll probably want to set
`ip_whitelist_request_proxied` to true. See settings.yml for more documentation.

#### Password authentication
Project monitor uses [Devise](https://github.com/plataformatec/devise) to provide both database backed authentication and
Google OAuth2 logins.

Regular password authentication for managing project settings is enabled by default and can be switched off
by setting the `password_auth_enabled` setting to `false`. To ensure strong
password encryption you should adjust the value for `password_auth_pepper` and
`password_auth_stretches` appropriately.

#### Google OAuth2 setup
To use Google OAuth2 authentication you need Google apps set up for your domain
and the following configuration options specified:

    oauth2_enabled: true
    oauth2_apphost: 'MY_APP_ID'
    oauth2_secret: 'MY_SECRET'

### Setup Cron with Whenever

We have included a sample whenever gem config in
config/schedule.rb. Refer to the
[whenever documentation](https://github.com/javan/whenever) for full
instructions on how to integrate it with your deployment.  In a pinch,
you can do at the toplevel of the project:

    whenever --update-crontab

This will install the `whenever` jobs specified in
`config/schedule.rb` into your personal cron settings.  These settings
include a fetch from your CI servers every three minutes.

Refer to [Heroku scheduler documentation](https://devcenter.heroku.com/articles/scheduler) for instructions
on how to integrate the rake task with your Heroku deployment.
The default schedule clears log entries and cleans up unused tags
daily, and fetches project statuses every 3 minutes.  On CloudFoundry,
scheduling is taken care of by extra workers, see below. 

The `fetch-statuses` project task is what goes out and hits the individual
builds. We find that if you do this too frequently it can swamp the
builds. On the other hand, you don't want ProjectMonitor displaying
stale information. At Pivotal we set it up to run every 3 minutes.

### Start workers
The cron job above will add jobs to the queue, which workers will execute.  To
start running the workers, use the following command:

    rake start_workers

The default number of workers is 2, but if you wanted 3 you would call it like this:

    rake start_workers[3]

These workers need only be started once per system reboot, and must be running
for your project statuses to update.  To stop the workers, run this command:

    rake stop_workers

The workers are implemented using the [delayed_job
gem](http://github.com/collectiveidea/delayed_job).  The workers are configured
to have a maximum timeout of 1 minute when polling project status.  If you want
to change this setting, you can edit `config/initializers/delayed_job_config.rb`

### Start the application
Execute:

    nohup rails server -e production &> projectmonitor.log

### Next Steps

Now you need to add a project or two! You can read the *Configuration* section for instructions.

## Configuration

Each build that you want ProjectMonitor to display is called a "project" in
ProjectMonitor. You can log in to set up projects by clicking the "Manage Projects" 
link in the bottom-right corner of the main ProjectMonitor screen. You can either
create a user using the console as follows:

    rails c development
    User.create!(login: 'john', name: 'John Doe', email: 'jdoe@example.com', password: 'password', password_confirmation: 'password')

Or, if you have set up Google OAuth2 as per above, you can simply log in with Google to create a new user account.

### Admin Interface

Click 'manage projects' at the lower right to edit project details.

### Add Projects

We have instructions detailing [how to add a project](docs/adding_a_project.md).

### Importing and Exporting Configurations
You can export your configuration for posterity or to be transferred to another
host:

    rake projectmonitor:export > ${your_configuration.yml}

Or using heroku:

    heroku run rake projectmonitor:export --app projectmonitor-staging > ${your_configuration.yml}

Or you can download it using the configuration endpoint, using curl (or your web browser):

    curl --user ${username}:${password} ${your_project_monitor_host}/configuration > ${your_configuration.yml}

NOTE: That heroku doesn't treat STDERR and STDOUT differently so you may get
some warnings at the beginning of the generated file that you'll have to remove
manually.

It can be imported in a similar way:

    rake projectmonitor:import < ${your_configuration.yml}

On heroku or another host which doesn't allow you to directly load files or
read from stdin, you'll need to post the file to the configuration endpoint
like so:

    curl --user ${username}:${password} -F "content=@-" ${your_project_monitor_host}/configuration < ${your_configuration.yml}

## Deployment

### Cloud Foundry

Deployment is done using manifest.yml files.  There are two files, one
for staging and one for production.  The files are identical but for
the endpoints that they use.  To use these files, you will have to
modify the line `host: project-monitor-production`: This line
specifies the endpoint or URL, and
project-monitor-production.cfapps.io is already taken by Pivotal.

Before you can push up your app, you have to create a database to
connect to.  The easiest way is to go to the PWS control panel, then
the marketplace and look for the ElephantSQL service.  Install a
`panda` (paid version) of the database and call it `db-production`.
Create a second one called `db-staging`.  See below for hints on using
the free version.

To deploy to production:

```
cf push -f ./config/cf/manifest-production.yml
```

And likewise for staging, using `manifest-staging.yml`. 

After you have pushed the manifest, you have to change the health
check on the apps that do not serve an endpoint (worker, clockwork,
poller), with `cf set-health-check <APP> none`.  This does not disable
the health check but stops it from checking for a live endpoint.  Your
workers may crash repeatedly before this setting takes hold.  In
the future, `no-route: true` may set this automatically or a manifest
setting may become available. 


#### Changes to the manifest files

The manifest files as supplied will try to use the hostnames that are
in use at Pivotal.  You have to supply your own values for the `host`
key (under applications/project-monitor-staging). You should also
remove all `logentries` lines (if still present).  Finally, as of the
`Diego` release
CloudFoundry suggest to specify the buildpack with `buildpack:
ruby_buildpack`.



#### Using the ElephantSQL free plan

If you are using the ElephantSQL free plan, you have only four
connections available.  Assuming you use staging for this,  edit
`config/cf/manifest-staging.yml` and change the number of rails
instances (project-monitor-production) to one and disable the
`clockwork` task, which does cleanup tasks that are not required for a
staging app.  Also make sure you do not have a `psql` or `rails
console` open, and be careful with opening the ElephantSQL dashboard.
Finally, edit the first line of `config/unicorn.rb` to have unicorn
start only one worker process, as each process opens its own database
connection.  




#### Applications started on CloudFoundry

On cloud deployment platforms like CloudFoundry and Heroku, `cron` is
not available or easy to use.  To work around this, the manifest
starts the following independent applications, that all connect to the
same database:

* Project-monitor:  This is the main rails app that will be connected
  to your endpoint,  `<HOST>.cfapps.io`.  You will get three instances
  by default.
* Project-monitor-worker:  One instance of this is spun up to do
  background tasks, which it reads from the database
* Project-monitor-clockwork: This application will run the rake
  commands in   `clockwork.rb` periodically.  These commands clean up
  logs etc.
* Project-monitor-poller:  This application will contact the CI
  providers periodically. 

On a local machine, this 4 application setup is replaced with the cron
tasks that are controlled by the `config/schedule.rb` file.

#### Cloudfoundry environment variables

Once you have set up your CF instance, you will want to modify some
environment variables with `cf set-env`.  Specifically, you will
probably want to supply

* A whitelist of IP addresses allowed to view this project monitor
* Your OAuth setup
* Pivotal uses NewRelic to monitor the monitor, it requries a token
  too
* Our internal production setup uses `logentries` and this requires
  setup too.  Logentries is no longer recommended or supported for new
  deployments.
  
#### Retired deployment method

Cloudfoundry hosts apps that serve the endpoints `ci.pivotallabs.com`
(for open source projects) and `pulse.pivotallabs.com` (Pivotal
projects).  These were once deployed with `rake
cf_deploy[orgname,spacename,environment]`, where environment is
production or staging.  This will tag your current git commit and push
the tag up to github, then do a `cf push`.  This mechanism is currently
not used. 

### Heroku

To get running on Heroku, after you have cloned and bundled, run the
following commands:

NB: These instructions are for the basic authentication strategy. 

    heroku create
    git push heroku master
    heroku run rake db:migrate
    heroku config:add REST_AUTH_SITE_KEY=<unique, private and long alphanumeric key, e.g. abcd1234edfg78910>
    heroku config:add REST_AUTH_DIGEST_STRETCHES=<count of number of times to apply the digest, 10 recommended>
    heroku run console 

When inside the console, run the creating a new user step above. You should then be able to access your server and start using it.

## Ideas and Improvements
Got a burning idea that just needs to be implemented? Check the CONTRIBUTE.md file for help getting started. Join the google group and share your ideas with the team.

The google group for Project Monitor is [projectmonitor_pivotallabs](http://groups.google.com/group/projectmonitor_pivotallabs)

Copyright (c) 2013-2015 Pivotal Labs. This software is licensed under the MIT License.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/pivotal/projectmonitor/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

