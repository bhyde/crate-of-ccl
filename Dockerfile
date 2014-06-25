FROM ubuntu:latest
MAINTAINER Ben Hyde <bhyde@pobox.com>
ADD ./build-script.sh /root/build-script.sh
RUN bash -v /root/build-script.sh
CMD ccl
EXPOSE 4005
