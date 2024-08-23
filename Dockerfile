#FROM arm64v8/debian:bookworm
FROM docker.io/arm64v8/debian:bookworm
RUN apt -qq update
#RUN apt -qq upgrade -y

# DEPS
RUN apt -qq install -y python3 gcc g++ make build-essential git git-lfs libffi-dev libssl-dev libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 libx11-xcb1 libgdk-pixbuf-2.0-0 libgtk-3-0 libdrm2 libgbm1 ruby ruby-dev curl wget clang llvm lld clang-tools generate-ninja ninja-build pkg-config tcl wget
RUN gem install fpm
ENV USE_SYSTEM_FPM=true
RUN mkdir -p /usr/include/aarch64-linux-gnu/
# pulled from https://raw.githubusercontent.com/node-ffi-napi/node-ffi-napi/master/deps/libffi/config/linux/arm64/fficonfig.h because its not in debian
COPY fficonfig.h /usr/include/aarch64-linux-gnu/ 
COPY rustup-init /rustup-init
RUN chmod +x /rustup-init
RUN /rustup-init -y

# Buildscripts
COPY signal-buildscript.sh /
RUN chmod +x /signal-buildscript.sh

# Clone signal
RUN git clone https://github.com/signalapp/Signal-Desktop -b 7.21.x
COPY patches/0001-Remove-no-sandbox-patch.patch /
COPY patches/0001-Remove-stories-icon.patch /
COPY patches/0001-Minimize-gutter-on-small-screens.patch /
COPY patches/0001-reduce-minimum-dimensions-to-allow-for-mobile-screen.patch /
COPY patches/0001-Always-return-MIN_WIDTH-from-storage.patch /

# Sometimes crashes due to upstream running out of git-lfs download credit
RUN git clone https://github.com/signalapp/better-sqlite3.git || true
#COPY deps/sqlcipher.tar.gz /better-sqlite3/deps/


# NODE
# Goes last because docker build can't cache the tar.
# https://nodejs.org/dist/v14.15.5/
ENV NODE_VERSION=v20.15.1
RUN wget -q https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-arm64.tar.gz -O /opt/node-${NODE_VERSION}-linux-arm64.tar.gz
COPY node.sums /opt/
RUN shasum -c /opt/node.sums
RUN mkdir -p /opt/node
RUN cd /opt/; tar xf node-${NODE_VERSION}-linux-arm64.tar.gz
RUN mv /opt/node-${NODE_VERSION}-linux-arm64/* /opt/node/
#ENV PATH=/opt/node/bin:$PATH
ENV PATH=/Signal-Desktop/node_modules/.bin:/root/.cargo/bin:/opt/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
