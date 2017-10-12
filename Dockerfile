FROM alpine:3.6

# update and base settings
RUN apk --update add \
    bzip2-dev \
    readline-dev \
    alpine-sdk \
    bash \
    curl \
    git \
    linux-headers \
    openssl \
    openssl-dev \
    sqlite-dev \
    wget \
    zlib-dev

# install python
ENV PYTHON_VERSION 3.5.4

RUN git clone https://github.com/yyuu/pyenv.git ~/.pyenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv --version
RUN pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
RUN python -V
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# install django
RUN pip install django

# install nginx
ENV NGINX_VERSION 1.13.6

RUN apk --update add pcre-dev openssl-dev \
  && apk add --virtual build-dependencies build-base curl \
  && curl -SLO http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar xzvf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION} \
  && ./configure \
       --with-http_ssl_module \
       --with-http_gzip_static_module \
       --prefix=/usr/share/nginx \
       --sbin-path=/usr/local/sbin/nginx \
       --conf-path=/etc/nginx/conf/nginx.conf \
       --pid-path=/var/run/nginx.pid \
       --http-log-path=/var/log/nginx/access.log \
       --error-log-path=/var/log/nginx/error.log \
  && make \
  && make install \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && cd / \
  && apk del build-dependencies \
  && rm -rf \
       nginx-${NGINX_VERSION} \
       nginx-${NGINX_VERSION}.tar.gz \
       /var/cache/apk/*

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]