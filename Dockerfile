FROM ubuntu:22.04

# Environment Variables
ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive


# Working Directory
WORKDIR /root
# make /opt/dns
RUN mkdir -p /opt/dns
RUN mkdir -p /opt/ip
RUN mkdir -p /opt/http
RUN mkdir -p /opt/asn
RUN mkdir -p /opt/wordlists

# Set architecture variable
ARG TARGETARCH
RUN ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64|arm64) echo "arm64";; *) echo $(uname -m);; esac) && \
    echo "Detected architecture: $ARCH" && \
    echo "export ARCH=$ARCH" >> /root/.bashrc


# Install Essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    tmux \
    gcc \
    iputils-ping \
    git \
    vim \
    wget \
    curl \
    make \
    nmap \
    sqlmap \
    whois \
    python3 \
    python3-pip \
    python3-dev \
    perl \
    nikto \
    hydra \
    medusa \
    jq \
    dnsutils \
    unzip \ 
    rsync \
    net-tools \
    lolcat \
    libpcap-dev \
    pipx \
    npm \
    libwww-perl \
    libio-socket-ssl-perl \
    libnet-ssleay-perl \
    libcrypt-ssleay-perl \
    zsh \
    gnupg2 \    
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Install SSH and enable SSH login as root
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:BalsamicToor12345' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    service ssh start && \
    systemctl enable ssh

# copy sshkeys.txt to authorized_keys
COPY sshkeys.txt /root/.ssh/authorized_keys

# golang - use detected architecture
RUN ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64|arm64) echo "arm64";; *) echo $(uname -m);; esac) && \
    wget https://dl.google.com/go/$(curl "https://go.dev/VERSION?m=text" | head -n 1).linux-${ARCH}.tar.gz && \
    tar -C /usr/local -xzf go*.linux-${ARCH}.tar.gz && \
    rm go*.linux-${ARCH}.tar.gz

# Set Go environment variables
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# install node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash && \
    . ~/.bashrc && \
    nvm install --lts

# configure python(s)
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    python -m pip install --upgrade pip


####################################
##### Helpers
####################################

# Easily turn single threaded command line applications into a fast, multi-threaded application with CIDR and glob support.
RUN cd /opt && git clone https://github.com/codingo/Interlace.git && cd Interlace && \
    pip install -r requirements.txt && pip install .

# Go tools
RUN go install github.com/OJ/gobuster/v3@latest
RUN go install -v github.com/tomnomnom/httprobe@master
RUN go install -v github.com/tomnomnom/anew@master

# ProjectDiscovery Tools
RUN go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest && pdtm -install-all && pdtm 

# cidr tools
RUN cd /opt/asn && git clone https://github.com/kafkaesqu3/hardcidr
RUN cd /opt/asn && git clone https://github.com/NetSPI/NetblockTool && cd NetblockTool && \
    pip install -r requirements.txt
RUN git clone https://github.com/vickywilsonj/asn-scraper



# amass - use detected architecture
RUN cd /opt/dns && wget https://github.com/owasp-amass/amass/releases/download/v4.2.0/amass_Linux_amd64.zip && \
    unzip amass_Linux_amd64.zip -d /usr/local/bin && \
    rm amass_Linux_amd64.zip && \
    mv /usr/local/bin/amass_Linux_amd64/amass /usr/local/bin/amass && \ 
    chmod +x /usr/local/bin/amass

####################################    
###### DNS tools
####################################

# check MDI
RUN cd /opt/dns && git clone https://github.com/expl0itabl3/check_mdi/ && \
    cd check_mdi && chmod +x check_mdi.py && \
    pip3 install -r requirements.txt && \
    ln -s `pwd`/check_mdi.py /usr/local/bin/check_mdi

# massdns
RUN cd /opt/dns && git clone https://github.com/blechschmidt/massdns.git && \
    cd massdns && make && make install

# whoxy
RUN go install github.com/milindpurswani/whoxyrm@latest


# pureDNS
RUN go install github.com/d3mondev/puredns/v2@latest


### DNSgen
RUN python -m pip install dnsgen
RUN go install github.com/bp0lr/dmut@latest

# CloudRecon
RUN go install github.com/g0ldencybersec/CloudRecon@latest

# bbot
RUN pipx install bbot

# github-subdomains
RUN go install github.com/gwen001/github-subdomains@latest

# TheHarvester
RUN cd /opt/dns && git clone https://github.com/laramies/theHarvester/ && \
    cd theHarvester && pipx install --python python3.11 . & \
    pipx ensurepath

# Shodan tools
RUN go install github.com/incogbyte/shosubgo@latest
RUN go install -v github.com/s0md3v/smap/cmd/smap@latest
RUN cd /opt/dns && git clone https://github.com/Dheerajmadhukar/karma_v2.git && \
    cd karma_v2 && pip install shodan mmh3 && \
    ln -s /usr/games/lolcat /usr/local/bin/lolcat && \
    ln -s `pwd`/karma_v2 /usr/local/bin/karma

####################################
############## worldist
####################################
# make /opt/wordlists
#RUN mkdir -p /opt/wordlists && cd /opt/wordlists && \
#    git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
#    wget -r --no-parent -R "index.html*" https://wordlists-cdn.assetnote.io/data/ -nH -e robots=off && \
#    wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt && \
#    git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb.git
#   git clone --depth 1 https://github.com/xmendez/wfuzz.git && \
#   git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
#   git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb.git && \
#   git clone --depth 1 https://github.com/daviddias/node-dirbuster.git && \
#   git clone --depth 1 https://github.com/v0re/dirb.git && \

####################################
############ HTTP tools
####################################

RUN git clone https://github.com/rezasp/joomscan.git && \
    cd joomscan && \
    ln -s `pwd`/joomscan.pl /usr/local/bin/joomscan

RUN go install github.com/lc/gau/v2/cmd/gau@latest
RUN go install github.com/tomnomnom/waybackurls@latest
RUN go install github.com/ffuf/ffuf/v2@latest
RUN go install github.com/puzzlepeaches/ffufw@latest

RUN cd /opt/http && git clone https://github.com/redhuntlabs/httploot.git && \
    cd httploot && \
    go build -o /usr/local/bin/httploot

RUN cd /opt/http && git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git
# Install dirsearch
RUN go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest
RUN cd /opt/http && git clone https://gist.github.com/9b/f5fe434bf9965d673963884b56d93d9a
RUN cd /opt/http && git clone --depth 1 https://github.com/maurosoria/dirsearch.git
# Install Arjun
RUN cd /opt/http && git clone --depth 1 https://github.com/s0md3v/Arjun.git

####################################
###### Subdomain takeover tools
####################################

# Install gowitness
RUN go install github.com/sensepost/gowitness@latest

# Install wpscan
RUN gem install wpscan

# Install wafw00f
RUN python3 -m pip install wafw00f

# Install gospider
RUN GO111MODULE=on go install github.com/jaeles-project/gospider@latest

# Install hakrawler
RUN go install github.com/hakluke/hakrawler@latest

# Install hakcheckurl
RUN go install github.com/hakluke/hakcheckurl@latest

# Install LinkFinder
RUN cd /opt/http && git clone https://github.com/GerbenJavado/LinkFinder && \
    cd LinkFinder && pip install -r requirements.txt && python setup.py install && \
    ln -s `pwd`/linkfinder.py /usr/local/bin/linkfinder


##### Metasploit
RUN curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
 chmod 755 msfinstall && ./msfinstall


##### Brute force tools
# Download crowbar
RUN mkdir -p /opt/brute
RUN cd /opt/brute && \
    git clone --depth 1 https://github.com/galkan/crowbar.git && \
# Download patator
    git clone --depth 1 https://github.com/lanjelot/patator.git


####### AI tools
#######

# codex
RUN npm install -g @openai/codex
# robotools



# Clean Go Cache
RUN go clean -cache && \
    go clean -testcache && \
    go clean -modcache






    



