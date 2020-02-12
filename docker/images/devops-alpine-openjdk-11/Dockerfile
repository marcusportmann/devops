FROM alpine:3.11.3

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8' TZ='Africa/Johannesburg'

RUN apk add --no-cache --virtual .build-deps curl binutils \
    && GLIBC_VER="2.29-r0" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && GCC_LIBS_URL="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-9.1.0-2-x86_64.pkg.tar.xz" \
    && GCC_LIBS_SHA256="91dba90f3c20d32fcf7f1dbe91523653018aa0b8d2230b00f822f6722804cf08" \
    && ZLIB_URL="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz" \
    && ZLIB_SHA256=17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5 \
    && curl -LfsS https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && SGERRAND_RSA_SHA256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2" \
    && echo "${SGERRAND_RSA_SHA256} */etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - \
    && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk > /tmp/glibc-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-${GLIBC_VER}.apk \
    && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk > /tmp/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-bin-${GLIBC_VER}.apk \
    && curl -Ls ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk > /tmp/glibc-i18n-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-i18n-${GLIBC_VER}.apk \
    && apk add -U tzdata \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
    && curl -LfsS ${GCC_LIBS_URL} -o /tmp/gcc-libs.tar.xz \
    && echo "${GCC_LIBS_SHA256} */tmp/gcc-libs.tar.xz" | sha256sum -c - \
    && mkdir /tmp/gcc \
    && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
    && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
    && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
    && curl -LfsS ${ZLIB_URL} -o /tmp/libz.tar.xz \
    && echo "${ZLIB_SHA256} */tmp/libz.tar.xz" | sha256sum -c - \
    && mkdir /tmp/libz \
    && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
    && mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib \
    && apk del --purge .build-deps glibc-i18n \
    && rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar.xz /tmp/libz /tmp/libz.tar.xz /var/cache/apk/* \
    && cp /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime \
    && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

ENV JAVA_VERSION jdk11u
ENV JAVA_HOME /opt/jdk
ENV JDK_HOME /opt/jdk

RUN apk add --no-cache --virtual .fetch-deps bash binutils curl \
    && ESUM='c00e5505c6bf439f7db88adbdec39169cd760930437a82420560f76320f1cc0d' \
    && BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-01-25-22-38/OpenJDK11U-jdk_x64_linux_hotspot_2020-01-25-22-38.tar.gz' \
    && curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL} \
    && echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c - \
    && mkdir -p $JAVA_HOME \
    && cd $JAVA_HOME \
    && tar -xf /tmp/openjdk.tar.gz --strip-components=1 \
    && export PATH="$JAVA_HOME/bin:$PATH" \
    && mkdir -p /tmp/slim-java \
    && curl -LfsSo /tmp/slim-java/slim-java.sh https://github.com/AdoptOpenJDK/openjdk-docker/raw/master/11/jdk/alpine/slim-java.sh \
    && curl -LfsSo /tmp/slim-java/slim-java_bin_del.list https://github.com/AdoptOpenJDK/openjdk-docker/raw/master/11/jdk/alpine/slim-java_bin_del.list \
    && curl -LfsSo /tmp/slim-java/slim-java_jmod_del.list https://github.com/AdoptOpenJDK/openjdk-docker/raw/master/11/jdk/alpine/slim-java_jmod_del.list \
    && curl -LfsSo /tmp/slim-java/slim-java_lib_del.list https://github.com/AdoptOpenJDK/openjdk-docker/raw/master/11/jdk/alpine/slim-java_lib_del.list \
    && curl -LfsSo /tmp/slim-java/slim-java_rtjar_del.list https://github.com/AdoptOpenJDK/openjdk-docker/raw/master/11/jdk/alpine/slim-java_rtjar_del.list \
    && curl -LfsSo /tmp/slim-java/slim-java_rtjar_keep.list https://github.com/AdoptOpenJDK/openjdk-docker/raw/master/11/jdk/alpine/slim-java_rtjar_keep.list \
    && chmod 0700 /tmp/slim-java/slim-java.sh \
    && /tmp/slim-java/slim-java.sh $JAVA_HOME \
    && sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/ $JAVA_HOME/conf/security/java.security \
    && apk del --purge .fetch-deps \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/slim-java \
    && rm -rf /tmp/openjdk.tar.gz

# Add an additional CA
# COPY CA.crt /tmp/ca.crt
# RUN  $JAVA_HOME/bin/keytool -importcert -noprompt -trustcacerts -alias "CA" -file /tmp/ca.crt -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit

ENV PATH="/opt/jdk/bin:$PATH"

CMD ["jshell"]


