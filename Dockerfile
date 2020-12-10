#FROM multiarch/alpine:aarch64-edge as builder
FROM alpine:latest as builder

ENV version=b31_mod_201906
ENV RTK_VER=demo5
ARG CONF_URL=https://raw.githubusercontent.com/rinex20/gnss_tools/master/conf/rtkrcv.conf
ARG RTKLIB_URL=https://github.com/rtklibexplorer/RTKLIB.git
# get conf file

RUN apk update \
   &&  apk --no-cache add build-base git autoconf automake libtool gfortran wget tar zlib-dev pcre-dev unzip patch linux-headers \
   && mkdir -p /data/rtk \
   && wget --no-check-certificate ${CONF_URL} -O /data/rtk/rtkrcv.conf \
   && git clone --depth 1 --branch ${RTK_VER} ${RTKLIB_URL} \
   && (cd RTKLIB/lib/iers/gcc/; make) \
   && (cd RTKLIB/app/rtkrcv/gcc; make; make install) \
   && (cd RTKLIB/app/str2str/gcc; make; make install)
#RUN apk del build-base git autoconf automake wget tar unzip patch linux-headers || true

#RUN rm -rf /data/rtk/RTKLIB

#FROM arm64v8/ubuntu:latest
#FROM multiarch/alpine:aarch64-edge
FROM alpine:latest

COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /data/rtk /data/
# run rtkrcv
EXPOSE 8077 8078 8001-8008
ENTRYPOINT ["rtkrcv", "-p", "8077", "-m", "8078", "-o", "/data/rtk/conf/rtkrcv.conf"] 
#CMD /usr/local/bin/rtkrcv -p 8077 -m 8078 -o /data/rtk/rtkrcv.conf
