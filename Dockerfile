FROM node:18-slim

# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

ENV LAMBDA_TASK_ROOT /var/task

# Set the Chrome version
ENV CHROME_VERSION "122.0.6261.57-1"

WORKDIR ${LAMBDA_TASK_ROOT}

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
# RUN apt-get update && apt-get install gnupg wget -y && \
#   wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
#   sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
#   apt-get update && \
#   apt-get install google-chrome-stable=121.0.6167.139-1 -y --no-install-recommends && \
#   rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
    gnupg \
    wget \
    cmake \
    autoconf \
    automake \
    libtool \
    g++ \
    make \
    unzip \
    libcurl4-openssl-dev \
    xvfb \
    fluxbox \
    wmctrl \
    gnupg2

# Download Package
RUN wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb

# Install Chrome
RUN apt-get install -y ./google-chrome-stable_${CHROME_VERSION}_amd64.deb

ENV DISPLAY=":99"

# RUN xvfb $DISPLAY -nolisten inet6 -nolisten tcp -nolisten unix -screen 0 1920x1280x24 +extension RANDR >/dev/null 2>&1 &
# RUN for i in 1 2 3 4 5; do xdpyinfo -display $DISPLAY >/dev/null 2>&1 && break || sleep '1s'; done
# RUN xdpyinfo -display $DISPLAY >/dev/null 2>&1 && echo 'In use' || echo 'Free'

# Copy the package.json and package-lock.json (if available)
COPY package*.json ${LAMBDA_TASK_ROOT}/

# Install NPM dependencies, including Puppeteer
RUN npm install

# Copy the rest of the application
COPY . ${LAMBDA_TASK_ROOT}/

# ENV npm_config_cache=/tmp/.npm

# ENV HOME /tmp

EXPOSE 3000

# Set the CMD to your handler (this should match the handler method in your Node.js application)
CMD ["npm", "run", "dev"]