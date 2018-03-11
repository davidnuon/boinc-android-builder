FROM ubuntu:16.04

RUN apt-get update
RUN apt-get upgrade
RUN apt-get -y install software-properties-common

RUN add-apt-repository ppa:ubuntu-desktop/ubuntu-make
RUN apt-get update
RUN apt-get upgrade

# Install the Desktop Tools
RUN apt-get --assume-yes install ubuntu-make git automake libtool wget

# Install NDK and SDK and Android Studio
RUN umake --verbose android android-studio --accept-license $HOME/Android/Android-Studio
RUN printf "\n# umake fix-up\nexport ANDROID_HOME=\$HOME/Android/Sdk\n" >> $HOME/.profile
RUN umake --verbose android android-sdk --accept-license $HOME/Android/Sdk
RUN printf "\n# umake fix-up\nexport NDK_ROOT=\$HOME/Android/Ndk\n" >> $HOME/.profile
RUN umake --verbose android android-ndk --accept-license $HOME/Android/Ndk
RUN yes | $HOME/Android/Sdk/tools/bin/sdkmanager --update
RUN yes | $HOME/Android/Sdk/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"
RUN mkdir $HOME/Desktop
RUN cp $HOME/.local/share/applications/android-studio.desktop $HOME/Desktop/
RUN chmod +x $HOME/Desktop/android-studio.desktop

# Setup toolchain
ENV OPENSSL_VERSION=1.0.2k
ENV CURL_VERSION=7.53.1

RUN git clone https://github.com/BOINC/boinc.git $HOME/BOINC --depth 1
ENV BUILD_TOOLS 25.0.0
ENV COMPILE_SDK 23
RUN echo $BUILD_TOOLS $COMPILE_SDK
RUN yes | $HOME/Android/Sdk/tools/bin/sdkmanager "build-tools;${BUILD_TOOLS}"
RUN yes | $HOME/Android/Sdk/tools/bin/sdkmanager "platforms;android-${COMPILE_SDK}"
RUN printf "\n# Build toolchains\nexport ANDROID_TC=\$HOME/Android/Toolchains\n" >> $HOME/.profile
WORKDIR $HOME/BOINC

# Setup 3rdParty
RUN mkdir $HOME/3rdParty
RUN wget -O /tmp/openssl.tgz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar xzf /tmp/openssl.tgz --directory=$HOME/3rdParty
RUN printf "\n# OpenSSL sources\nexport OPENSSL_SRC=\$HOME/3rdParty/openssl-${OPENSSL_VERSION}\n" >> $HOME/.profile
RUN wget -O /tmp/curl.tgz https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
RUN tar xzf /tmp/curl.tgz --directory=$HOME/3rdParty
RUN printf "\n# cURL sources\nexport CURL_SRC=\$HOME/3rdParty/curl-${CURL_VERSION}\n" >> $HOME/.profileRUN 
