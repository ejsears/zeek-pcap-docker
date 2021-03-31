##### Create builder image

FROM centos:centos8 as builder

LABEL maintainer "Eric Sears (https://www.github.com/ejsears)"

ENV ZEEK_VERSION 4.0.0

RUN dnf -y install dnf-plugins-core && \
  dnf config-manager --set-enabled powertools

RUN dnf install -y cmake \
  make \
  gcc \
  gcc-c++ \
  flex \
  bison \
  libpcap-devel \
  openssl-devel \
  python3 \
  python3-devel \
  swig \
  zlib-devel \
  libmaxminddb-devel \
  git

RUN dnf group install 'Development Tools' -y

RUN echo "Retrieving source code for zeek..." \
  && cd /tmp \
  && git clone --recursive --branch v$ZEEK_VERSION https://github.com/zeek/zeek.git

RUN echo "Compiling zeek source code..." \
  && cd /tmp/zeek \
  && ./configure --prefix=/usr/local/zeek \
  --build-type=MinSizeRel \
  --disable-broker-tests \
  --disable-zeekctl \
  --disable-auxtools \
  --disable-python \
  && make -j $(nproc) \
  && make install

RUN echo "Adding zeek script hosom/file-extraction package..." \
  && cd /tmp \
  && git clone https://github.com/hosom/file-extraction.git \
  && mv file-extraction/scripts /usr/local/zeek/share/zeek/site/file-extraction

RUN echo "Shrinking image..." \
  && strip -s /usr/local/zeek/bin/zeek

####### Final Image
FROM centos:centos8

LABEL maintainer "Eric Sears https://www.github.com/ejsears"

RUN dnf -y install dnf-plugins-core && \
  dnf config-manager --set-enabled powertools

RUN dnf install -y ca-certificates \
  zlib \
  openssl \
  libstdc++ \
  libpcap-devel \
  libmaxminddb-devel \
  libgcc

COPY --from=builder /usr/local/zeek /usr/local/zeek
COPY local.zeek /usr/local/zeek/share/zeek/site/local.zeek

COPY scripts/conn-add-geodata.zeek \
  /usr/local/zeek/share/zeek/site/geodata/conn-add-geodata.zeek
COPY scripts/log-passwords.zeek \
  /usr/local/zeek/share/zeek/site/passwords/log-passwords.zeek

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /pcap

ENV ZEEKPATH .:/data/config:/usr/local/zeek/share/zeek:/usr/local/zeek/share/zeek/policy:/usr/local/zeek/share/zeek/site
ENV PATH $PATH:/usr/local/zeek/bin

ENTRYPOINT ["/entrypoint.sh"]
