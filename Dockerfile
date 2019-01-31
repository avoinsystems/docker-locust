FROM registry.opensource.zalan.do/stups/ubuntu:18.04-15

#=======================
# General Configuration
#=======================
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
RUN apt-get update && apt-get install -y jq python3-dev python3-zmq python3-pip unzip && rm -rf /var/lib/apt/lists/*

#==============
# Expose Ports
#==============
EXPOSE 8089
EXPOSE 5557
EXPOSE 5558

#======================
# Install dependencies
#======================
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

#=====================
# Install Odoo related stuff
#=====================
RUN curl -o locustodoorpc.zip -SL https://github.com/avoinsystems/locustodoorpc/archive/0.0.3-avoinsystems.zip \
        && unzip locustodoorpc.zip \
        && mv locustodoorpc-0.0.3-avoinsystems locustodoorpc \
        && cd locustodoorpc \
        && python3 setup.py install \
        && cd .. \
        && rm -rf locustodoorpc.zip

#=====================
# Start docker-locust
#=====================
COPY src /opt/src/
COPY setup.cfg /opt/
RUN mkdir /opt/result /opt/reports
RUN ln -s /opt/src/app.py /usr/local/bin/locust-wrapper
WORKDIR /opt
ENV PYTHONPATH /opt
ARG DL_IMAGE_VERSION=latest
ENV DL_IMAGE_VERSION=$DL_IMAGE_VERSION \
    SEND_ANONYMOUS_USAGE_INFO=true

CMD ["locust-wrapper"]
