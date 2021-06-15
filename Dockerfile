FROM python:3.9-alpine

RUN adduser -D microblog

WORKDIR /home/microblog

COPY requirements.txt requirements.txt
RUN python -m venv venv
RUN apk --update --no-cache add \
	python3-dev \
	libffi-dev \
	gcc \
	musl-dev \
	make \
	libevent-dev \
	build-base \
	openssl-dev \
	cargo
RUN venv/bin/pip install -r requirements.txt
RUN python -m pip install --upgrade pip
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
RUN venv/bin/pip install cryptography gunicorn pymysql

COPY app app
COPY migrations migrations
COPY microblog.py config.py boot.sh ./
RUN chmod +x boot.sh

ENV FLASK_APP microblog.py

RUN chown -R microblog:microblog ./
USER microblog

EXPOSE 5000
ENTRYPOINT ["./boot.sh"]