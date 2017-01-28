FROM python:2.7

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bash \
    make \
    jq \
    tree \
    tar \
    zip \
 && rm -rf /var/lib/apt/lists/* \
 && rm /bin/sh && ln -sf /bin/bash /bin/sh \
 && echo "export PS1='\n\u@\h \w [\#]:\n\$ ' " >> ~/.bashrc \
 && echo "alias ll='ls -al'" >> ~/.bashrc \
 && echo "" >> ~/.bashrc

ENV PROJECT_DIR=/src/pyweb \
    SHELL=/bin/bash

RUN mkdir -p "$PROJECT_DIR"

WORKDIR $PROJECT_DIR

# specify exposed port
EXPOSE 8888

# ENTRYPOINT ["/bin/bash", "-c"]

CMD ["/bin/bash"]
