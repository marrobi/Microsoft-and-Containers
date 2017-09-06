FROM ubuntu:16.04

RUN apt-get update

RUN apt-get install imagemagick -y

ADD ./twitterhandle.png /tmp/twitterhandle.png
ADD ./sample.jpg /tmp/sample.jpg
ADD ./process.sh /tmp/

RUN mkdir /output

ENTRYPOINT ["bash","/tmp/process.sh"]

CMD  ["/tmp/sample.jpg","/tmp/twitterhandle.png","/composite.jpg"]
