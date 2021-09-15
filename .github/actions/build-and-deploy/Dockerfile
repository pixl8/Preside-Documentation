FROM pixl8/docker-commandbox-lite:v2-rc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN apk update
RUN apk add ruby
RUN gem install rdoc
RUN gem install --no-doc s3_website

ENTRYPOINT [ "/entrypoint.sh" ]
