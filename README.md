Description
===========

CiMonitor is a CI display aggregator. It displays the status of multiple Continuous Integration builds on a single web page.
The intent is that you display the page on a big screen monitor or TV so that the status of all your projects' builds
are highly visible/glanceable (a "Big Visible Chart"). CiMonitor currently supports:

  * [Cruise Control](http://cruisecontrolrb.thoughtworks.com/)
  * [Hudson](http://hudson-ci.org/)
  * [Team City](http://www.jetbrains.com/teamcity/)

NOTE: To get TeamCity to output the feed data needed for CIMonitor, you need to install a plugin into the server.
You can find the plugin at [http://github.com/iwz/Cradiator-TeamCity-Plugin](http://github.com/iwz/Cradiator-TeamCity-Plugin)

We use CiMonitor internally at Pivotal Labs to display the status of the builds for all our client projects. We also
have an instance of CiMonitor running at [ci.pivotallabs.com](http://ci.pivotallabs.com) that we use for displaying the
status of the builds of various open source projects - both of projects Pivotal Labs maintains (such as Refraction)
and of non-Pivotal projects (such as
Rails).

## Installation

### Get the code

CiMonitor is a Rails application. To get the code, execute the following:

    git clone git://github.com/pivotal/cimonitor.git pivotal_cimonitor
    cd pivotal_cimonitor
    bundle install

### Initial Setup

We have provided example files for `database.yml`, `auth.yml`, and `site_keys.rb`.  Run the following to automatically
generate these files for you:

    rake setup

You likely need to edit the generated files.  See below.

### Set up the database

You'll need a database. Create it with whatever name you want.  If you have not run `rake setup`,
copy `database.yml.example` to `database.yml`.  Edit the production environment configuration so it's right
for your database:

    cp config/database.yml.example config/database.yml
    <edit database.yml>
    RAILS_ENV=production rake db:create
    RAILS_ENV=production rake db:migrate

### Auth support

Adding, editing and removing projects through the UI requires authentication.

If you have not run `rake setup`, copy `auth.yml.example` to `auth.yml`.

    cp config/auth.yml.example config/auth.yml

The site can be configured to use Google OpenId or to use the RestfulAuthentication plugin.

#### Google OpenId setup

This setup requires you to have Google apps set up for your domain. 

In your `config/auth.yml` set the `auth_strategy` to `openid`. Then set the `openid_identifier`, `openid_realm`, and `openid_return_to` fields as appropriate for your domain.

#### Restful Authentication (`password`) setup 

In the `config/auth.yml` set the `auth_strategy` to `password`, and edit the `rest_auth_site_key` to be something secret.

### Set up cron

Add a cron job at whatever frequency you like for the following command:

    RAILS_ENV=production rake cimonitor:fetch_statuses > fetch_statuses.log 2>&1

This is what goes out and hits the individual builds. We find that if you do this too frequently it
can swamp the builds. On the other hand, you don't want CiMonitor displaying stale information. At Pivotal we set it up to
run every 3 minutes.  Also, make sure that you set your PATH correctly in crontab to include the 'bundle' executable.

### Start the application

Execute:

    nohup script/server -e production & > cimonitor.log 2> &1

## Configuration

Each build that you want CiMonitor to display is called a "project" in CiMonitor. You need to login to set up projects.


### Create a user

CiMonitor can use either the [Restful Authentication plugin](http://github.com/technoweenie/restful-authentication), or Google OpenId for user security. If you are using Google OpenId, users will be automatically provisioned.  All users from your domain will be permitted to edit projects. Otherwise, use the following steps to add users by hand.

Your first user must be created at the command line.

    script/console production
    User.create!(:login => 'john', :name => 'John Doe', :email => 'jdoe@example.com', :password => 'password', :password_confirmation => 'password')

After that, you can login to CiMonitor with the username and password you specified and use the "New User" link to create additional users.

### Log in

Open a browser on CiMonitor. Login by clicking on "Login" in the upper-right corner.

### Add projects

Click on "Projects" in the upper-right corner. Click on "New Project" and enter the details for a build
you want to display on CiMonitor. The "Name", "Project Type", and "Feed URL" are required. If your Feed URL is
http://myhost.com:3333/projects/MyProject, then your RSS URL is probably http://myhost.com:3333/projects/MyProject.rss.

Optionally, if your Build system is behind Basic Authentication or Digest Authentication, you can enter the credentials.

If you want to temporarily hide your build on CiMonitor, you can uncheck the "Enable" checkbox.

CiMonitor's main display page is at `/`. You can always get back there by clicking on the "Pivotal Labs" logo at the upper
left.

## Display

Just open a browser on `/`. The page will refresh every 60 seconds. When it refreshes, it shows whatever status was last
fetched by the cron job. That is, a refresh doesn't cause the individual Builds to be polled.

CiMonitor shows a big green check or a big red X to indicate a build's status. In addition, it shows the history of a
project's builds: the previous 9 are displayed underneath as green or red dots. The larger the dot, the more recent the
build.

CiMonitor looks good on an iPhone, by the way :)

## Notifications

CiMonitor can inform you of builds that have been red for more than 24 hours. Set up cron to daily execute:

    RAILS_ENV=production rake cimonitor:red_over_one_day_notification > red_over_one_day_notification.log 2>&1

## Tags

You can enter tags for a project (separated by commas) on the project edit page.  You can then have CiMonitor display
only projects that match a set of tags by going to /?tags=tag1,tag2

## Skins

You can skin the CiMonitor dashboard by adding a layout to app/views/layouts/skins, and associated static assets in
public/skins. View your skinned dashboard at http://myhost.com:3333/?skin=my_skin_name.

We have included an example skin - 'dark', which is great for dashboards with fewer projects.

## CI

CI for CiMonitor is [here](http://ci.pivotallabs.com:3333/builds/CiMonitor), and it's aggregated at [ci.pivotallabs.com](http://ci.pivotallabs.com)
(that's an instance of CiMonitor, of course).

## Development

The public Tracker project for CiMonitor is [here](http://www.pivotaltracker.com/projects/2872).

To run tests, run:
    rake setup
    rake spec

Copyright (c) 2010 Pivotal Labs. This software is licensed under the MIT License.

