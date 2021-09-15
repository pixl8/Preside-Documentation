FROM pixl8/docker-commandbox-lite:v2-rc
ENV COMMANDBOX_HOME=/root/.CommandBox

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN apk update
RUN apk add ruby zip
RUN gem install --no-doc s3_website

RUN curl -o $COMMANDBOX_HOME/engine/cfml/cli/lucee-server/deploy/pdf-extension-1.0.0.94.lex https://ext.lucee.org/pdf-extension-1.0.0.94.lex

ENTRYPOINT [ "/entrypoint.sh" ]
