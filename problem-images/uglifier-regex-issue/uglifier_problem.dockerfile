FROM ubuntu:16.04

RUN apt-get update && apt-get install -y binutils

# Install node.js
RUN cd ~ && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs build-essential

# Add the files to work with
RUN mkdir /tmp/gulp_problem
ADD gulpfile.js /tmp/gulp_problem
ADD simple_regex.js /tmp/gulp_problem

# Set up the node modules
RUN cd /tmp/gulp_problem && \
    npm init -f && \
    npm install gulp gulp-uglify pump && \
    npm install -g gulp

# Run the gulp file to see the problem
RUN cd /tmp/gulp_problem && \
    gulp compress
