FROM pixl8/docker-commandbox-lite:v2-rc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN apt update
RUN apt install -y rubygems
RUN gem install s3_website

ENTRYPOINT [ "/entrypoint.sh" ]
