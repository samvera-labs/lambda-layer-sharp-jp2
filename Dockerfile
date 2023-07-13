# This file assists in building dependencies for our function on AWS Lambda
# Usage:
# docker build -t lambda-layer-sharp-jp2 .
# docker run -v $(pwd):/dist lambda-layer-sharp-jp2

###############################################################################
# Core
###############################################################################

# Use AWS Lambda node build environment
FROM public.ecr.aws/sam/build-nodejs18.x:latest AS core


# Update all existing packages
RUN yum update -y

# Optimize compilation for size to try and stay below Lambda's 250 MB limit
# This reduces filesize by over 90% (!) compared to the default -O2
ENV CFLAGS "-Os"
ENV CXXFLAGS $CFLAGS

# RUN yum groupinstall "Development Tools"
RUN yum install -y tar gzip giflib-devel libjpeg-devel libpng-devel libtiff-devel

###############################################################################
# GhostScript
###############################################################################
ARG GHOSTSCRIPT_VERSION=10.01.2
ARG GHOSTSCRIPT_URL=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10012/ghostscript-${GHOSTSCRIPT_VERSION}.tar.gz

WORKDIR /root

RUN curl -Lv ${GHOSTSCRIPT_URL} | tar zxv

WORKDIR /root/ghostscript-${GHOSTSCRIPT_VERSION}
RUN ./configure --prefix=/opt
RUN make install

###############################################################################
# libwebp
###############################################################################
ARG LIBWEBP_VERSION=1.3.1

WORKDIR /root

RUN curl https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VERSION}.tar.gz | tar zxv

WORKDIR /root/libwebp-${LIBWEBP_VERSION}

RUN ./configure --prefix=/opt
RUN make
RUN make install

###############################################################################
# libvips
###############################################################################
ARG LIBVIPS_VERSION=8.14.2

RUN pip3 install meson \
 && curl -Lo /tmp/ninja-linux.zip https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip \
 && unzip -d /usr/local/bin /tmp/ninja-linux.zip \
 && rm /tmp/ninja-linux.zip

WORKDIR /root

RUN yum install -y gtk-doc gobject-introspection-devel expat-devel lcms2-devel openjpeg2 openjpeg2-devel openjpeg2-tools

RUN curl https://codeload.github.com/libvips/libvips/tar.gz/v${LIBVIPS_VERSION} | tar zxv

WORKDIR /root/libvips-${LIBVIPS_VERSION}

FROM core

COPY build-libvips.sh .
RUN ./build-libvips.sh

###############################################################################
# RPM dependencies
###############################################################################

WORKDIR /root

# Install yumdownloader and rpmdev-extract
RUN yum install -y yum-utils rpmdevtools

RUN mkdir rpms
WORKDIR /root/rpms

# Download dependency RPMs
RUN yumdownloader libjpeg-turbo.x86_64 libpng.x86_64 libtiff.x86_64 \
  libgomp.x86_64 jbigkit-libs.x86_64 openjpeg2.x86_64 \
  glib2.x86_64 libmount.x86_64 libblkid.x86_64 giflib.x86_64 \
  lcms2.x86_64

# Extract RPMs
RUN rpmdev-extract *.rpm
RUN rm *.rpm
RUN for d in $(find . -name lib64 -type d); do mv $d ${d%%64}; done
RUN cp -vR */usr/* /opt

###############################################################################
# Node Dependencies
###############################################################################

RUN mkdir -p /opt/nodejs
COPY package* /opt/nodejs

###############################################################################
# Sharp
###############################################################################

WORKDIR /root
RUN mkdir -p sharp
COPY build-sharp.sh /root/sharp
WORKDIR /root/sharp
RUN PKG_CONFIG_PATH=/opt/lib/pkgconfig:/opt/lib64/pkgconfig ./build-sharp.sh

###############################################################################
# Zip all dependencies
###############################################################################

WORKDIR /opt
RUN zip -r /root/sharp-lambda-layer.zip *

###############################################################################
# Entrypoint: Copy zip file to host
###############################################################################

ENTRYPOINT ["/bin/cp", "/root/sharp-lambda-layer.zip", "/dist"]
