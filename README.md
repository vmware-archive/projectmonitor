Description [![Build Status](https://secure.travis-ci.org/pivotal/projectmonitor.png?branch=master)](http://travis-ci.org/pivotal/projectmonitor) [![Code Climate](https://codeclimate.com/github/pivotal/projectmonitor.png)](https://codeclimate.com/github/pivotal/projectmonitor)
===========

ProjectMonitor is a CI display aggregator. It displays the status of multiple
Continuous Integration builds on a single web page.  The intent is that you
display the page on a big screen monitor or TV so that the status of all your
projects' builds are highly visible/glanceable (a "Big Visible Chart").
ProjectMonitor currently supports:

  * [CircleCI](http://circleci.com)
  * [Cruise Control](http://cruisecontrolrb.thoughtworks.com/)
  * [Jenkins](http://jenkins-ci.org/)
  * [Semaphore](http://www.semaphoreapp.com/)
  * [TeamCity](http://www.jetbrains.com/teamcity/)
  * [Travis CI](http://travis-ci.org/)
  * [tddium](http://www.tddium.com/)

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
4. [Deployment](#deployment)
5. [Display](#display)
6. [Ideas and Improvements](#ideas-and-improvements)

## Linked Documents

1. [Upgrading](docs/upgrading.md)
2. [Adding a Project](docs/adding_a_project.md)

## Installation

### Get the code
ProjectMonitor is a Rails application. To get the code, execute the following:

    git clone git://github.com/pivotal/projectmonitor.git
    cd projectmonitor
    bundle install

### Initial Setup
We have provided an example file for `database.yml`. Run the following to 
automatically generate these files for you:

    rake setup

You likely need to edit the generated files.  See below.

### Set up the database
You'll need a database. Create it with whatever name you want.  If you have not
run `rake setup`, copy `database.yml.example` to `database.yml`.  Edit the
production environment configuration so it's right for your database:

    cp config/database.yml.example config/database.yml
    <edit database.yml>
    RAILS_ENV=production rake db:create
    RAILS_ENV=production rake db:migrate

### Set up memcached for performant/distributed caching
Statuses are cached via an in-memory store by default.  If you want to use memcache,
you'll need to ensure it's installed. It should be very easy to install if you have
homebrew or another package manager:

    brew install memcached

After you have successfully installed memcached follow the instructions to run it.

### Authentication support
#### IP Whitelist
If you want to use Webhooks, your ProjectMonitor instance will need to be located on a
publically accessible server. If you don't want your ProjectMonitor dashboard to also be
publically accessible, you can whitelist access by IP address.

The whitelist is disabled by default, but can be enabled by uncommenting the "ip_whitelist" property
in settings.yml and adding a list of IP addresses to whitelist. If you're running ProjectMonitor
behind a load balancer (e.g. on a hosted provider such as Heroku), you'll probably want to set
"ip_whitelist_request_proxied" to true. See settings.yml for more documentation.

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
We have included a sample whenever gem config in config/schedule.rb. Refer to
the [whenever documentation](https://github.com/javan/whenever) for instructions
on how to integrate it with your deployment. Refer to [Heroku scheduler documentation](https://devcenter.heroku.com/articles/scheduler) for instructions
on how to integrate the rake task with your Heroku deployment.

The default schedule clears log entries and cleans up unused tags daily, and fetches project statuses every 3 minutes.

The fetch project task is what goes out and hits the individual builds. We find
that if you do this too frequently it can swamp the builds. On the other hand,
you don't want ProjectMonitor displaying stale information. At Pivotal we set
it up to run every 3 minutes.

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

## Configuration

Each build that you want ProjectMonitor to display is called a "project" in
ProjectMonitor. You can log in to set up projects by clicking the "Manage Projects" 
link in the bottom-right corner of the main ProjectMonitor screen. You can either
create a user using the console as follows:

    rails c production
    User.create!(login: 'john', name: 'John Doe', email: 'jdoe@example.com', password: 'password', password_confirmation: 'password')

Or, if you have set up Google OAuth2 as per above, you can simply log in with Google to create a new user account.

### Add projects

We have instructions detailing [how to add a project](docs/configuration.md).

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

### Heroku
To get running on Heroku, after you have cloned and bundled, run the following commands:

NB: These instructions are for the basic authentication strategy. 

    heroku create
    git push heroku master
    heroku run rake db:migrate
    heroku config:add REST_AUTH_SITE_KEY=<unique, private and long alphanumeric key, e.g. abcd1234edfg78910>
    heroku config:add REST_AUTH_DIGEST_STRETCHES=<count of number of times to apply the digest, 10 recommended>
    heroku labs:enable user-env-compile
    heroku run console 

When inside the console, run the creating a new user step above. You should then be able to access your server and start using it.

## Display
Just open a browser on `/`. The page refreshes every 30 seconds with the latest
status fetched by the cron job or received via Webhook. That is,
refreshing the page doesn't cause the individual builds to be re-polled.

### Layout
The layout consists of a grid of tiles representing the projects.  The
number of projects that need to be displayed is determined automatically.

### Tile colors
Tiles are green for green projects, red for red projects, and light gray if the
project's build server cannot be reached. If the build server is online but no
builds have been run then the tile will appear in yellow. A pulsating tile indicates
that a new build is currently in progress.

### Project Ticker Codes
Each tile shows the project's brief ticker code.  If not chosen explicitly,
this will be the first 4 letters of the project.

### Build Statuses
To the right of the ticker and name, each project lists the amount of time
since the last build, followed by the build status history.  The last 5-8 builds
are displayed from left to right, in reverse chronological order -- the most
recent build will be on the left and the least recent on the right.
Successful builds are marked with a filled in circle, and unsuccessful builds
are marked with an x.

### Tags
You can enter tags for a project (separated by commas) on the project edit page.  You can then have ProjectMonitor display
only projects that match a set of tags by going to /?tags=tag1,tag2

### Aggregate Projects
Striped tiles indicate the aggregate status of several projects.  Click on an
aggregate project to see the status of its component projects.

### Pivotal Tracker Integration
ProjectMonitor can display basic [Pivotal Tracker](http://pivotaltracker.com) information.  When
configured, the current velocity will be displayed, as well as a graph showing points completed for
the current iteration and the past 9 iterations.  To add this integration, you will need to add your
Pivotal Tracker project ID and a Pivotal Tracker API key in the admin section.

### Admin Interface
Click 'manage projects' at the lower right to edit project details.

## Ideas and Improvements
Got a burning idea that just needs to be implemented? Check the CONTRIBUTE.md file for help getting started. Join the google group and share your ideas with the team.

The google group for Project Monitor is [projectmonitor_pivotallabs](http://groups.google.com/group/projectmonitor_pivotallabs)

Copyright (c) 2013 Pivotal Labs. This software is licensed under the MIT License.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/pivotal/projectmonitor/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

