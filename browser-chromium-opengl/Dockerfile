# noVNC + TurboVNC + VirtualGL
# http://novnc.com
# https://turbovnc.org
# https://virtualgl.org

FROM nvidia/opengl:1.0-glvnd-runtime

ARG TURBOVNC_VERSION=2.1.2
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG CHROMIUM_VERSION=TBD

ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

RUN echo "deb http://archive.canonical.com/ubuntu xenial partner" | tee /etc/apt/sources.list.d/flash-plugin.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        libc6-dev \
        libglu1 \
        libglu1:i386 \
        libsm6 \
        libxv1 \
        libxv1:i386 \
        make \
        python \
        python-numpy \
        x11-xkb-utils \
        xauth \
        xfonts-base \
        xkb-data \
        ca-certificates \
        python2.7 \
        python-pip \
        python2.7-dev \
        build-essential \
        python-openssl \
        libssl-dev libffi-dev \
        net-tools \
        dnsutils \
        pulseaudio \
        libopus-dev \
        gstreamer1.0 \
        libnss3-tools \
        wmctrl \
        jwm \
        adobe-flashplugin \
        sudo \
        autocutsel \
        gdebi
        


COPY ${CHROMIUM_VERSION} /tmp/${CHROMIUM_VERSION}

RUN  gdebi --non-interactive /tmp/${CHROMIUM_VERSION}/chromium-codecs-ffmpeg-extra_${CHROMIUM_VERSION}_amd64.deb && \
     gdebi --non-interactive /tmp/${CHROMIUM_VERSION}/chromium-browser_${CHROMIUM_VERSION}_amd64.deb && \   
     rm -rf /tmp/${CHROMIUM_VERSION}

RUN cd /tmp && \
    curl -fsSL -O https://svwh.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

RUN \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    cd /opt/websockify && make


RUN echo 'no-httpd\n\
no-x11-tcp-connections\n\
no-pam-sessions\n\
' > /etc/turbovncserver-security.conf

WORKDIR /app/


COPY requirements.txt /app/
RUN pip install -U setuptools pip
RUN pip install -U -r requirements.txt

ADD run_browser /usr/bin/run_browser

RUN rm -rf /var/lib/apt/lists/*

EXPOSE 6080
EXPOSE 6082
ENV DISPLAY :1


RUN useradd browser --shell /bin/bash --create-home \
  && usermod -a -G sudo browser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'browser:secret' | chpasswd



COPY audio_proxy.py /app/audio_proxy.py
COPY entry_point.sh /app/entrypoint.sh
COPY audio_stream.sh /app/audio_stream.sh
COPY run.sh /app/run.sh
COPY run_browser /app/run_browser
COPY jwmrc /home/browser/.jwmrc


RUN chmod +x /app/entrypoint.sh
RUN chmod +x /app/run.sh
RUN chmod +x /app/run_browser
RUN chmod +x /app/audio_stream.sh


USER browser

ENTRYPOINT ["/app/entrypoint.sh", "/app/run.sh"]
