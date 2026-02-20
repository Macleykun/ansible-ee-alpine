######################################### BUILD #########################################
 
FROM python:alpine AS builder

# Add configuration files
COPY requirements/apk.build.list /requirements/ansible.yaml /requirements/

# Overridable args to pass to galaxy role/collection install
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS=
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS=

# Install system build dependencies
RUN apk add --no-cache $(cat /requirements/apk.build.list) && \
    python -m venv /opt/ansible_venv/ && PATH=/opt/ansible_venv/bin:${PATH} \
    ansible-galaxy role install ${ANSIBLE_GALAXY_CLI_ROLE_OPTS} \
      --role-file /requirements/ansible.yaml \
      --roles-path "/usr/share/ansible/roles" && \
    ansible-galaxy collection install ${ANSIBLE_GALAXY_CLI_COLLECTION_OPTS} \
      --requirements-file /requirements/ansible.yaml \
      --collections-path "/usr/share/ansible/collections" && \
    chmod -R a=rX /usr/share/ansible

######################################### RUNNER #########################################

FROM python:alpine

LABEL org.opencontainers.image.description="A really small Ansible Execution Environment that is easily customizable and maintainable withoud using the bloated ansible-builder ;)"

# Directory for executing Playbooks
WORKDIR /runner/

# Add runtime dependencies lists
COPY requirements/apk.list requirements/pip.list /requirements/
# Copy Ansible roles and collections
COPY --from=builder /usr/share/ansible /usr/share/ansible

# Add non-root user
ARG USER=ansible && \
    GROUP=ansible && \
    UID=1000 && \
    GID=1000
# Make the user, install packages, pip modules and make the python interpeter system default
RUN addgroup ${GROUP} --gid ${GID} && \
    adduser  ${USER}  --uid ${UID} \
      --ingroup "${GROUP}" \
      --disabled-password && \
    chown ${USER}:${GROUP} /runner/ /home/"${USER}"/ && \
    apk add --no-cache $(cat /requirements/apk.list) && \
    pip install --no-cache-dir --requirement /requirements/pip.list && \
    ln -s /usr/local/bin/python3 /usr/bin/python3

# Set user and Ansible required args/paths
ENV HOME=/home/"${USER}" \
    PATH=/opt/ansible_venv/bin:${PATH} \
    ANSIBLE_ROLES_PATH=roles:/runner/roles:/usr/share/ansible/roles \
    ANSIBLE_COLLECTIONS_PATH=collections:/runner/collections:/usr/share/ansible/collections \
    ANSIBLE_LOCAL_TEMP=/tmp \
    ANSIBLE_INVENTORY_PLUGINS=/runner/project/plugins \
    ANSIBLE_SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s" \
    ANSIBLE_SSH_PIPELINING=True \
    ANSIBLE_HASH_BEHAVIOUR=merge
#    ANSIBLE_SSH_HOST_KEY_CHECKING=False \

# Switch to non-root user
USER ${UID}:${GID}