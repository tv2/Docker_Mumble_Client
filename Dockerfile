# Mumble.info - Mumble Client
#
# Netjack2 - jackaudio.org
# Ubuntu.org - Ubuntu
#
# Kasper Olsson Hans TV2 Denmark
#
FROM        ubuntu:16.04 AS base

WORKDIR     /

# CleanUp Ubuntu
RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 && \
        apt-get autoremove -y && \
        apt-get clean -y

FROM base as build

# Environment
ENV        PKG_CONFIG_PATH=

# Build dependencies for Mumble
RUN     buildDeps="autoconf \
		automake \
                build-essential \
		pkg-config \
		qt5-default \
		libqt5svg5-dev \
                libasound2-dev \
		libboost-dev \
		libssl-dev \
                libspeechd-dev \
		libzeroc-ice-dev \
		libpulse-dev \
                libcap-dev \
		libprotobuf-dev \
		protobuf-compiler \
                libogg-dev \
		libavahi-compat-libdnssd-dev \
		libsndfile1-dev \
                libg15daemon-client-dev \
		libxi-dev \
		cmake \
		git \
		pkg-config \
 	        libexpat1-dev \
                make \
		avahi-daemon \
		avahi-utils \
                libssl-dev" && \
        apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ${buildDeps}


#Build depencies for jack:
RUN	DEBIAN_FRONTEND="noninteractive"  apt-get -yq install jackd2

#Install x11server service and vnc and start at boot:
RUN	apt-get -yq --no-install-recommends install xfce4 vnc4server xfonts-base xfce4-terminal tightvncserver
WORKDIR	/root/.vnc/
COPY	xstartup xstartup

# Get Mumble Source from Git:
RUN	git clone git://github.com/mumble-voip/mumble.git /mumble

# Get submodules:
WORKDIR	"/mumble"
RUN	git submodule init
RUN	git submodule update

#Install Qt5Creator:
RUN	apt-get -yq install qtcreator

# Compile Mumble Client:
WORKDIR "/mumble"

RUN	qmake -recursive main.pro CONFIG+=no-server
RUN	make

#For network testing ------ KAOL uncomment to test
RUN apt-get install -yq --no-install-recommends net-tools iputils-ping


#Info
MAINTAINER  KAOL TV2 Denmark

#Add mumble user:
RUN groupadd -r mumbleuser && useradd -r -g mumbleuser -G audio,video mumbleuser \
    && mkdir -p /home/mumbleuser/Downloads && chown -R mumbleuser:mumbleuser /home/mumbleuser

# Run mumble as non privileged user
#USER mumbleuser

#Add startup script
ADD         "start.sh" "/root/start.sh"
RUN         chmod +x /root/start.sh

ENTRYPOINT  ["/root/start.sh"]
ENV         LD_LIBRARY_PATH=/usr/local/lib

#EXPOSE	5353:5353/udp
#EXPOSE	5941:5941/udp
EXPOSE  5000-6000/udp
EXPOSE  5000-6000
EXPOSE 	19000
EXPOSE 	3000