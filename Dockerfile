FROM ubuntu:jammy

RUN set -eux; \
    apt-get update ; \
    apt-get upgrade -y 

RUN set -eux; \
    apt-get install -y wget gpg sudo apt-transport-https lsb-release

RUN set -eux; \
    wget -qO /tmp/hyperion.pub.key https://apt.hyperion-project.org/hyperion.pub.key ; \
    gpg --dearmor -o - /tmp/hyperion.pub.key > /usr/share/keyrings/hyperion.pub.gpg ; \
    echo "deb [signed-by=/usr/share/keyrings/hyperion.pub.gpg] https://apt.hyperion-project.org/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/hyperion.list ; \
    apt-get update
    
RUN set -eux; \
    apt-get install -y hyperion

# HTTP and HTTPS Web UI default ports
EXPOSE 8090

EXPOSE 8092

ENV UID=1000
ENV GID=1000

RUN groupadd -f hyperion
RUN useradd -r -s /bin/bash -g hyperion hyperion

RUN echo "#!/bin/bash" > /start.sh
RUN echo "groupmod -g \$2 hyperion" >> /start.sh
RUN echo "usermod -u \$1 hyperion" >> /start.sh
RUN echo "chown -R hyperion:hyperion /config" >> /start.sh
RUN echo "sudo -u hyperion /usr/bin/hyperiond -v --service -u /config" >> /start.sh

RUN chmod 777 /start.sh

VOLUME /config

CMD [ "bash", "-c", "/start.sh ${UID} ${GID}" ]