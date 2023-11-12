# FROM homebrew/brew:4.1.19
FROM homebrew/brew:latest
ENV HOMEBREW_NO_ANALYTICS=1
RUN brew analytics off
RUN brew update --auto-update

WORKDIR /stackify
COPY init.sh /init.sh

RUN /init.sh --brew
RUN /init.sh --update

# pyenv configuration only needed for this testing image
# RUN /init.sh --pyenv-dependencies
# RUN /init.sh --pyenv
# RUN /init.sh --pyenv-init
# RUN /init.sh --python
# RUN CC=/home/linuxbrew/.linuxbrew/bin/gcc-13 CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib" /init.sh --python

# RUN /init.sh --set-python-version
RUN /init.sh --ansible

COPY main.yml /main.yml
COPY group_vars /group_vars
COPY lookup_plugins /lookup_plugins
COPY tasks /tasks
COPY modules /modules

# RUN ansible-playbook /main.yml

CMD [ "bash" ]