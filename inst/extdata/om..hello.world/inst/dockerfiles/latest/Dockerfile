FROM ubuntu:18.04

RUN echo "Hello world!" > hello.txt && \
    echo "------------" >> hello.txt && \
    cat /etc/lsb-release >> hello.txt

# outsider requires working_dir
RUN mkdir /working_dir

WORKDIR /working_dir
