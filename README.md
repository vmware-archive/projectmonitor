[![Build Status](https://secure.travis-ci.org/pivotal/projectmonitor.png?branch=master)](http://travis-ci.org/pivotal/projectmonitor)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/pivotal/projectmonitor)

Description
===========

ProjectMonitor is a CI display aggregator. It displays the status of multiple
Continuous Integration builds on a single web page.  The intent is that you
display the page on a big screen monitor or TV so that the status of all your
projects' builds are highly visible/glanceable (a "Big Visible Chart").
ProjectMonitor currently supports:

  * [Cruise Control](http://cruisecontrolrb.thoughtworks.com/)
  * [Jenkins](http://jenkins-ci.org/)
  * [TeamCity](http://www.jetbrains.com/teamcity/)
  * [Travis CI](http://travis-ci.org/)

We use ProjectMonitor internally at Pivotal Labs to display the status of the
builds for all our client projects. We also have an instance of ProjectMonitor
running at [ci.pivotallabs.com](http://ci.pivotallabs.com) that we use for
displaying the status of the builds of various open source projects - both of
projects Pivotal Labs maintains (such as Jasmine) and of non-Pivotal projects
(such as Rails).

## Upgrading

ProjectMonitor has recently moved to
[Devise](https://github.com/plataformatec/devise/) for authentication. This
means that any existing users will have invalid passwords. If you don't want
all your users to have to reset their passwords, you can alter the following
configuration settings to support legacy passwords:

    devise_encryptor: :legacy
    devise_pepper: <rest_auth_site_key>
    devise_stretches: <rest_auth_digest_stretches>

The values for `rest_auth_site_key` and `rest_auth_digest_stretches` can be found
in your `config/auth.yml`. This file is no longer needed.

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

### Authentication support

Project monitor uses Devise to provide both database backed authentication and
Google OAuth2 logins.

#### Password authentication

Regular password authentication is enabled by default and can be switched off
by setting the `password_auth_enabled` setting to `false`. To ensure strong
password encryption you should adjust the value for `password_auth_pepper` and
`password_auth_stretches` appropriately.

#### Google OAuth2 setup

To use Google OAuth2 authentication you need Google apps setup for your domain
and the following configuration options specified:

    oauth2_enabled: true
    oauth2_apphost: 'MY_APP_ID'
    oauth2_secret: 'MY_SECRET'

### Setup Cron with Whenever

We have included a sample whenever gem config in config/schedule.rb. Refer to
the [whenever documentation](https://github.com/javan/whenever) for instructions
on how to integrate it with your deployment.

The default schedule clears log entries daily, and fetches project statuses every 3 minutes.

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
ProjectMonitor. You need to login to set up projects.


### Create a user

ProjectMonitor can use either the [Restful Authentication
plugin](http://github.com/technoweenie/restful-authentication), or Google
OpenId for user security. If you are using Google OpenId, users will be
automatically provisioned.  All users from your domain will be permitted to
edit projects. Otherwise, use the following steps to add users by hand.

Your first user must be created at the command line.

    rails c production
    User.create!(login: 'john', name: 'John Doe', email: 'jdoe@example.com', password: 'password', password_confirmation: 'password')

After that, you can login to ProjectMonitor with the username and password you
specified and use the "New User" link to create additional users.

### Log in

Open a browser on ProjectMonitor. Login by clicking on "Login" in the upper-right corner.

### Add projects

Click on "Projects" in the upper-right corner. Click on "New Project" and enter
the details for a build you want to display on ProjectMonitor. The "Name",
"Project Type", and "Feed URL" are required. If your Feed URL is
http://myhost.com:3333/projects/MyProject, then your RSS URL is probably
http://myhost.com:3333/projects/MyProject.rss.

#### TeamCity
To configure TeamCity:

*   Choose Team City Rest Project for the project type
*   URL looks like: http://teamcity:8111/app/rest/builds?locator=running:all,buildType:(id:bt*) where * is the buildTypeId from the TeamCity Build Configuration.
*   Requires a username and password that match a valid account in TeamCity with access to the Build Configuration.

NOTE: The Cradiator-TeamCity-Plugin is deprecated. Please use the Team City
Rest Project configuration, which is natively supported by TeamCity 5+.

Optionally, if your Build system is behind Basic Authentication or Digest
Authentication, you can enter the credentials.

If you want to temporarily hide your build on ProjectMonitor, you can uncheck
the "Enable" checkbox.

ProjectMonitor's main display page is at `/`. You can always get back there by
choosing the number of tiles you want at the lower left.

#### Semaphore
When configuring [Semaphore](http://semaphoreapp.com), you should use the Branch History URL from the API section of your Project Settings page.

This ensures that no build statuses will be missed.

### Auto-start for Ubuntu

In order to have projectmonitor start when the machine boots, modify the startup
scripts.  In the following example, we have modified /etc/rc.local on an Ubuntu
10.04 server (change paths & userids as needed):

    # need to set PS1 so that rvm is in path otherwise .bashrc bails too early
    su - pivotal -c 'PS1=ps1; . /home/pivotal/.bashrc; cd ~/projectmonitor/current; bundle exec thin -e production start -c /home/pivotal/projectmonitor/current -p7990 -s3; bundle exec rake start_workers[6]'

### Importing and Exporting Configurations

You can export your configuration for posterity or to be transferred to another
host:

    rake cimonitor:export > ${your_configuration.yml}

Or using heroku:

    heroku run rake cimonitor:export --app projectmonitor-staging > ${your_configuration.yml}

Or you can download it using the configuration endpoint, using curl (or your web browser):

    curl --user ${username}:${password} ${your_project_monitor_host}/configuration > ${your_configuration.yml}

NOTE: That heroku doesn't treat STDERR and STDOUT differently so you may get
some warnings at the beginning of the generated file that you'll have to remove
manually.

It can be imported in a similar way:

    rake cimonitor:import < ${your_configuration.yml}

On heroku or another host which doesn't allow you to directly load files or
read from stdin, you'll need to post the file to the configuration endpoint
like so:

    curl --user ${username}:${password} -F "content=@-" ${your_project_monitor_host}/configuration < ${your_configuration.yml}

## Deployment

### Heroku

To get running on Heroku, after you have cloned and bundled, run the following commands:

NB: These instructions are for the basic authentication strategy. 

    heroku create
    heroku push heroku master
    heroku run rake db:migrate
    heroku config:add REST_AUTH_SITE_KEY=<unique, private and long alphanumeric key, e.g. abcd1234edfg78910>
    heroku config:add REST_AUTH_DIGEST_STRETCHES<count of number of times to apply the digest, 10 recommended>
    heroku run console 

When inside the console, run the creating a new user step above. You should then be able to access your server and start using it.

## Cron

You need to hit an authenticated endpoint to run the scheduler. 

    POST http://localhost:3000/projects/update_projects

You can create a cron entry to hit this:

    curl -dfoo=bar localhost:3000/projects/update_projects -uadmin:password

## Display

Just open a browser on `/`. The page will refresh every 30 seconds. When it
refreshes, it shows whatever status was last fetched by the cron job. That is,
a refresh doesn't cause the individual builds to be polled.

### Layout

The new layout consists of a grid of tiles representing the projects.  The
number of projects that need to be displayed is determined automatically, but
can also be set explicitly.  There are views available for 15 tiles, 24 tiles,
48 tiles, or 63 tiles, and a 6-project view with larger tiles is coming soon.

### Tile colors

Tiles are green for green projects, red for red projects, and light gray if the
project's build server cannot be reached. If the build server is online but no
builds have been run then the tile will appear in yellow.

### Project Ticker Codes

Each tile shows the project's brief ticker code.  If not chosen explicitly,
this will be the first 4 letters of the project.

### Build Statuses

To the right of the ticker and name, each project lists the amount of time
since the last build, followed by the build status history.  The last 5-8 builds
are displayed from left to right, in reverse chronological order -- the most
recent build will be on the left and the least recent on the right.
Successful builds are marked with a filled in circle, and unsuccessful builds
are marked with an x.  When a build is in progress a spinner is displayed instead
of the time since the last build.

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

## Tags

You can enter tags for a project (separated by commas) on the project edit page.  You can then have ProjectMonitor display
only projects that match a set of tags by going to /?tags=tag1,tag2

## CI

CI for ProjectMonitor is [here](http://travis-ci.org/pivotal/projectmonitor), and it's aggregated at [ci.pivotallabs.com](http://ci.pivotallabs.com)
(that's an instance of ProjectMonitor, of course).

## Development

The public Tracker project for ProjectMonitor is [here](http://www.pivotaltracker.com/projects/2872).

To run tests, run:

    rake setup
    rake spec

To run a local development server and worker, run:

    foreman start

## Deploying to Github

Project Monitor has been moved under the "Pivotal" organization. Developers will need to request that their Github ID's are added as collaborators in order to have push privileges to the repo.

## Ideas /Improvements

Got a burning idea that just needs to be implemented? Join the google group and share it with the team.

The google group for Project Monitor is [projectmonitor_pivotallabs](http://groups.google.com/group/projectmonitor_pivotallabs)

Copyright (c) 2012 Pivotal Labs. This software is licensed under the MIT License.
