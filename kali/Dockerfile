FROM kalilinux/kali-rolling

# Update package lists and install basic tools
RUN apt-get update && apt-get upgrade -y

# Install essential packages
RUN apt-get install -y \
    bash \
    curl \
    wget \
    vim \
    nano \
    nmap \
    git \
    net-tools \
    iputils-ping \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root

# make /opt/dns
RUN mkdir -p /opt/dns
RUN mkdir -p /opt/ip
RUN mkdir -p /opt/http



# Install python packages
#RUN pip3 install --upgrade pip && \
#    pip3 install \
#    requests \
#    dnspython 

# install pipx via apt
RUN apt-get update && apt-get install -y pipx && \
    pipx ensurepath


# check MDI
    RUN git clone https://github.com/expl0itabl3/check_mdi/  
    cd check_mdi && \
    pip3 install -r requirements.txt 


# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default command to run bash
CMD ["/bin/bash"]
