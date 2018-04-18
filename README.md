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

In practice, ProjectMonitor is often displayed on publicly-viewable monitors mounted to the wall. This provides transparency into the health of the build(s) that entire team can see at a glance. When a build goes red (fails), the next person or pair to finish their story can take a look at what broke before starting new work. If a build goes red a lot over a period of time, it can prompt a conversation about what isn't working.

![ProjectMonitor in use](http://i.imgur.com/HRy31hX.jpg)

## Table of Contents

1. [Installation](#installation)
2. [Custom Configuration](#custom-configuration)
3. [In-app Configuration](#in-app-configuration)
4. [Deployment](#deployment)
5. [Ideas and Improvements](#ideas-and-improvements)

## Linked Documents

1. [Upgrading to Devise](docs/upgrading_to_devise.md)
2. [Adding a Project](docs/adding\_a\_project.md)
3. [Displaying Your Project's Status](docs/displaying\_your\_projects\_status.md)

## Installation

### Get the code
To get the code, execute the following:

    git clone git://github.com/pivotal/projectmonitor.git
    cd projectmonitor
    
### Get Docker
ProjectMonitor provides a one-line setup using Docker

Download and install docker from [the official Docker website](https://docs.docker.com/install/)

### Run the app locally with the default configuration

	docker run -p 3000:3000 -v `pwd`:/projectmonitor pivotaliad/project-monitor \
	bash -c "cd projectmonitor && bundle install && RAILS_ENV=development rake local:start"

The app will be available at: [http://0.0.0.0:3000](http://0.0.0.0:3000)

Add a user: 

	docker exec CONTAINER_ID_OR_NAME \
	bash -c 'cd projectmonitor && \
	echo "User.create!(login: \"jane\", name: \"Jane Martinez\", email: \"jmartinez@example.com\", password: \"password\")" | \
	rails c development'

To stop: `docker kill <container-id>`

### Local development
	docker run -it -p 3000:3000 -v `pwd`:/projectmonitor pivotaliad/project-monitor

Inside the container run:
	
	bundle install

To run tests:
   
	rake local:test
	
see [Custom Configuration](#custom-configuration) for DB setup

## Custom configuration

### Set up the database
You'll need a database. Create it with whatever name you want. For defaults, copy `database.yml.example` to `database.yml`.  Edit the
production environment configuration so it's right for your database:

First, get the defaults copied:

    cp config/database.yml.example config/database.yml

Edit the defaults in `config/database.yml`

Create the db and set the tables:

    RAILS_ENV=production rake db:create
    RAILS_ENV=production rake db:migrate

### Authentication support
#### IP Whitelist
If you want to use Webhooks, your ProjectMonitor instance will need to be located on a
publicly accessible server. If you don't want your ProjectMonitor dashboard to also be
publicly accessible, you can whitelist access by IP address.

The whitelist is disabled by default, but can be enabled by uncommenting the "ip_whitelist" property
in settings.yml and adding a list of IP addresses to whitelist. If you're running ProjectMonitor
behind a load balancer (e.g. on a hosted provider such as Heroku), you'll probably want to set
"ip_whitelist_request_proxied" to true. See settings.yml for more documentation.

#### Password authentication
Project monitor uses [Devise](https://github.com/plataformatec/devise) to provide both database backed authentication and
Google OAuth2 logins.

Regular password authentication for managing project settings is enabled by default. 
Run `rake db:seed` with the environment variables `PROJECT_MONITOR_LOGIN`, `PROJECT_MONITOR_EMAIL` and
`PROJECT_MONITOR_PASSWORD` set to create a new account.

To switch off password auth, set `password_auth_enabled` setting to `false`. To ensure strong
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

### Next Steps

Now you need to add a project or two! Keep reading the *In-app Configuration* section for instructions.

## In-app Configuration

Each build that you want ProjectMonitor to display is called a "project" in
ProjectMonitor. You can log in to set up projects by clicking the "Manage Projects"
link in the bottom-right corner of the main ProjectMonitor screen. You can either
create a user using the console as follows:

    rails c production
    User.create!(login: 'john', name: 'John Doe', email: 'jdoe@example.com', password: 'password')

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
ProjectMonitor requires a database that can handle more than 4 concurrent connections, otherwise occasional errors might pop up.

Create a CF space and add a db service named `rails-mysql`

The default way to deploy to CF is using the attached [concourse](https://concourse-ci.org/) pipeline. Follow the concourse installation steps to setup concourse-ci.

Add credentials to: `concourse/projectmonitor-production-credentials.yml`

Set the pipilene: 

	fly set-pipeline -c concourse/projectmonitor-production-pipeline.yml -p PIPELINE_NAME \
	-l concourse/projectmonitor-production-credentials.yml -t TARGET_NAME
	
The pipeline will deploy the latest stable version with default configuration every time it is updated.

For manual CF deployment:

```
cf target -s SPACE -o ORG
cf create-service DB_SERVICE DB_SERVICE_PLAN rails-mysql
cf push
```

### Heroku
To get running on Heroku, after you have cloned and bundled, run the following commands:

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

Copyright (c) 2018 Pivotal Labs. This software is licensed under the MIT License.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/pivotal/projectmonitor/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

