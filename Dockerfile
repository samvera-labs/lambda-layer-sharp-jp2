# This file assists in building dependencies for our function on AWS Lambda
# Usage:
# docker build -t lambda-layer-sharp-jp2 .
# docker run -v $(pwd):/dist lambda-layer-sharp-jp2

###############################################################################
# Core
###############################################################################

# Use AWS Lambda node build environment
FROM public.ecr.aws/sam/build-nodejs16.x:latest

ARG GHOSTSCRIPT_VERSION=9.52 \
    LIBVIPS_VERSION=8.12.1
# Update all existing packages
RUN yum update -y

# Optimize compilation for size to try and stay below Lambda's 250 MB limit
# This reduces filesize by over 90% (!) compared to the default -O2
ENV CFLAGS "-Os"
ENV CXXFLAGS $CFLAGS

# RUN yum groupinstall "Development Tools"
RUN yum install -y tar gzip libjpeg-devel libpng-devel libtiff-devel libwebp-devel

###############################################################################
# GhostScript
###############################################################################

WORKDIR /root

RUN curl -LO \
  https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/ghostscript-${GHOSTSCRIPT_VERSION}.tar.gz
RUN tar zxvf ghostscript-${GHOSTSCRIPT_VERSION}.tar.gz

WORKDIR /root/ghostscript-${GHOSTSCRIPT_VERSION}
RUN ./configure --prefix=/opt
RUN make install

###############################################################################
# libvips
###############################################################################

WORKDIR /root

RUN yum install -y gtk-doc gobject-introspection-devel expat-devel openjpeg2 openjpeg2-devel openjpeg2-tools

RUN curl -o libvips-${LIBVIPS_VERSION}.tar.gz \
  https://codeload.github.com/libvips/libvips/tar.gz/v${LIBVIPS_VERSION}
RUN tar zxvf libvips-${LIBVIPS_VERSION}.tar.gz

WORKDIR /root/libvips-${LIBVIPS_VERSION}
RUN ./autogen.sh --prefix=/opt
RUN ./configure --prefix=/opt
RUN make install

###############################################################################
# RPM dependencies
###############################################################################

WORKDIR /root

# Install yumdownloader and rpmdev-extract
RUN yum install -y yum-utils rpmdevtools

RUN mkdir rpms
WORKDIR rpms

# Download dependency RPMs
RUN yumdownloader libjpeg-turbo.x86_64 libpng.x86_64 libtiff.x86_64 \
  libgomp.x86_64 libwebp.x86_64 jbigkit-libs.x86_64 openjpeg2.x86_64 \
  glib2.x86_64 libmount.x86_64 libblkid.x86_64 libwebp.x86_64

# Extract RPMs
RUN rpmdev-extract *.rpm
RUN rm *.rpm

# Copy all package files into /opt/rpms
RUN cp -vR */usr/* /opt

# The x86_64 packages extract as lib64, we need to move these files to lib
RUN yum install -y rsync
RUN rsync -av /opt/lib64/ /opt/lib/
RUN rm -r /opt/lib64

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
RUN PKG_CONFIG_PATH=/opt/lib/pkgconfig ./build-sharp.sh

###############################################################################
# Zip all dependencies
###############################################################################

WORKDIR /opt
RUN zip -r /root/sharp-lambda-layer.zip *

###############################################################################
# Entrypoint: Copy zip file to host
###############################################################################

ENTRYPOINT ["/bin/cp", "/root/sharp-lambda-layer.zip", "/dist"]
