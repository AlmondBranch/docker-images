FROM ruby:2.7

RUN gem install elasticsearch

RUN mkdir /home/resources
COPY resources /home/resources/
