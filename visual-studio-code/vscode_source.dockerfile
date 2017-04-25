FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl xz-utils

# Install X11
RUN apt-get install -y sudo x11-apps libx11-xcb-dev

# Set up permissions for X11 access.
# Replace 1000 with your user / group id.
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer

#Install node
# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 7.8.0

RUN cd /home/developer && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && sudo tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && sudo ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 0.22.0

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done \
  && cd /home/developer && curl -fSL -o yarn.js "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js" \
  && curl -fSL -o yarn.js.asc "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js.asc" \
  && gpg --batch --verify yarn.js.asc yarn.js \
  && rm yarn.js.asc \
  && sudo mv yarn.js /usr/local/bin/yarn \
&& sudo chmod +x /usr/local/bin/yarn

#Install python
RUN sudo apt-get install -y python2.7
RUN sudo ln -s /usr/bin/python2.7 /usr/bin/python

#Install git
RUN sudo apt-get install -y git

#Install vscode source
RUN sudo apt-get install -y g++ make
RUN cd /home/developer && git clone https://github.com/microsoft/vscode && cd vscode && git checkout tags/1.11.1
RUN sudo apt-get install -y libxkbfile-dev
RUN cd /home/developer/vscode && ./scripts/npm.sh install --arch=x64

#Install electron
RUN sudo apt-get install -y libnss3 libgtk2.0-0 libxtst6 libxss1 libgconf-2-4 libasound2
RUN cd /home/developer/vscode && sudo npm install -g electron

# crazy npm rebuild line taken from https://github.com/EmergingTechnologyAdvisors/node-serialport/issues/904
RUN cd /home/developer/vscode && npm run-script compile && npm rebuild --runtime=electron --target=1.6.3 --disturl=https://atom.io/download/atom-shell --build-from-source

# change the application name in the window title from "Code - OSS" to "Visual Studio Code"
RUN sed -ie 's/Code - OSS/Visual Studio Code/g' /home/developer/vscode/product.json

# change the application icon to the production one
RUN rm /home/developer/vscode/resources/linux/code.png
ADD code.png /home/developer/vscode/resources/linux/code.png

# Add canberra to satify gtk error message
RUN sudo apt-get install -y libcanberra-gtk-module

#Set VSCODE_DEV to something so that an initial folder isn't opened in the explorer window on start-up
ENV VSCODE_DEV=1

CMD cd /home/developer/vscode && electron .




