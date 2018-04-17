FROM ubuntu

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH

# Pick Ruby version
RUN rbenv install 2.3.1
RUN rbenv global 2.3.1

# Install bundler
RUN /bin/bash -c 'eval "$(rbenv init -)" && gem install bundler'

# Install capybara dependencies
RUN apt-get install -y qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

# Install javascript runtime
RUN apt-get install -y nodejs

# Install xvfb for headless selenium
RUN apt-get -y install xvfb

# Install mysql
RUN { \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
	} | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server libmysqlclient-dev

# Install timezone data
RUN apt-get install -y tzdata