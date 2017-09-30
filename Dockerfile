FROM ubuntu:16.04

LABEL maintainer="Akagi201 <akagi201@gmail.com>"

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            libmicrohttpd-dev \
            libjansson-dev \
            libnice-dev \
            libssl-dev \
            libsrtp-dev \
            libsofia-sip-ua-dev \
            libglib2.0-dev \
            libopus-dev \
            libogg-dev \
            libini-config-dev \
            libcollection-dev \
            pkg-config \
            gengetopt \
            libtool \
            automake \
            build-essential \
            git-core \
            cmake \
            wget \
            ca-certificates \
    \
    rm -rf /var/lib/apt/lists/*; \

# usrsctp
ENV USRSCTP_HASH "7737b4a547256d1b6a8176555e18984f68039dbc"

RUN git clone https://github.com/sctplab/usrsctp.git /tmp/usrsctp \
    && git checkout $USRSCTP_HASH \
    && ./bootstrap \
    && ./configure --prefix=/usr/local \
    && make && make install

# libwebsockets
ENV LIBWEBSOCKETS_VERSION "2.3.0"

RUN wget https://github.com/warmcat/libwebsockets/archive/v$LIBWEBSOCKETS_VERSION.tar.gz -O /tmp/v$LIBWEBSOCKETS_VERSION.tar.gz \
    && tar xvf /tmp/v$LIBWEBSOCKETS_VERSION.tar.gz -C /tmp \
    && cd /tmp/libwebsockets-$LIBWEBSOCKETS_VERSION \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_C_FLAGS="-fpic" .. \
    && make && make install

# libsrtp
ENV LIBSRTP_VERSION "2.1.0"

RUN wget https://github.com/cisco/libsrtp/archive/v$LIBSRTP_VERSION.tar.gz -O /tmp/v$LIBSRTP_VERSION.tar.gz \
    && tar xvf /tmp/v$LIBSRTP_VERSION.tar.gz -C /tmp \
    && cd /tmp/libsrtp-$LIBSRTP_VERSION \
    && ./configure --prefix=/usr/local ----enable-openssl \
    && make shared_library && make install

# glib
ENV GLIB_VERSION "2.54.0"

RUN wget https://github.com/GNOME/glib/archive/$GLIB_VERSION.tar.gz -O /tmp/$GLIB_VERSION.tar.gz \
    && tar xvf /tmp/$GLIB_VERSION.tar.gz -C /tmp \
    && cd /tmp/glib-$GLIB_VERSION \
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig sh autogen.sh --prefix=/usr/local --disable-libmount \
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --prefix=/usr/local --disable-libmount \
    && make && make install

# janus-gateway
ENV JANUS_GATEWAY_HASH "9bc69c136ecf093da77ce39d1917e26d4c3f9aeb"

RUN git clone https://github.com/meetecho/janus-gateway.git /tmp/janus-gateway \
    && cd /tmp/janus-gateway \
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig sh autogen.sh \
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --prefix=/usr/local/janus --disable-mqtt --disable-rabbitmq --disable-unix-sockets --disable-plugin-textroom --disable-plugin-audiobridge --disable-plugin-recordplay --disable-plugin-sip --disable-plugin-streaming --disable-plugin-voicemail --disable-plugin-videoroom --disable-plugin-videocall \
    && make && make configs & make install
