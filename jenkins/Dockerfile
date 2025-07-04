FROM jenkins/jenkins:lts-jdk17

USER root

# Instalar dependencias necesarias
RUN apt-get update && \
    apt-get install -y lsb-release curl gnupg2 && \
    rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Agregar el usuario `jenkins` al grupo `docker`
RUN groupadd -f docker && usermod -aG docker jenkins

# Descargar la última versión de kubectl
RUN curl -LO https://dl.k8s.io/release/v1.30.2/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm -f kubectl

USER jenkins

# Instalar plugins de Jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
