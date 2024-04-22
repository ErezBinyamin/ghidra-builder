FROM ubuntu:20.04
MAINTAINER @dukebarman

ARG gradle_version=7.3
ARG jdk_version=17

# Set timezone data for correct configuration of build-essential tools. If not specified here installation will interactivley prompt for tzdata
RUN echo Europe/London > /etc/timezone
RUN echo tzdata tzdata/Areas select Europe | debconf-set-selections
RUN echo tzdata tzdata/Zones/Europe select London | debconf-set-selections

# Install basic packages along with correct JDK
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bison \
        build-essential \
        curl \
        flex \
        g++ \
        gcc \
        git \
        make \
        software-properties-common \
        unzip \
        wget \
	xvfb
# Add openjdk-r/ppa and install correct JDK version
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:openjdk-r/ppa -y
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openjdk-$jdk_version-jdk \        
    && rm -r /var/lib/apt/lists/*

# Non-root user 'dockerbot'
RUN groupadd --gid 1000 dockerbot && useradd --gid 1000 --uid 1000 --create-home dockerbot
USER dockerbot

# Build tools are part of the builder image; project code is mounted
RUN mkdir --parents $HOME/.gradle/init.d/

# Install gradle
RUN wget https://services.gradle.org/distributions/gradle-$gradle_version-bin.zip --directory-prefix=/tmp
RUN unzip -d $HOME/gradle /tmp/gradle-*.zip

ENV GRADLE_HOME=/home/dockerbot/gradle/gradle-$gradle_version
ENV PATH=$GRADLE_HOME/bin:$PATH

RUN echo "\
ext.HOME = System.getProperty('user.home')\n\
\n\
allprojects {\n\
    repositories {\n\
        mavenCentral()\n\
        jcenter()\n\
        flatDir name:'flat', dirs:[\"$HOME/flatRepo\"]\n\
    }\n\
}\n\
" > $HOME/.gradle/init.d/repos.gradle
