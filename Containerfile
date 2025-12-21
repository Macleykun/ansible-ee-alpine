######################################### BUILD #########################################
 
FROM python:alpine AS builder

# Add configuration files
COPY requirements/apk.build.list requirements/pip.list /requirements/ansible.yaml /requirements/
 
# Install system build dependencies
RUN apk add --no-cache $(cat /requirements/apk.build.list)
RUN python -m venv /opt/ansible_venv/ && PATH=/opt/ansible_venv/bin:${PATH} \
    pip install --no-cache-dir --requirement requirements/pip.list

ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS=
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS=
RUN ansible-galaxy role install ${ANSIBLE_GALAXY_CLI_ROLE_OPTS} --role-file /requirements/ansible.yaml \
      --roles-path "/usr/share/ansible/roles" && \
    ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install ${ANSIBLE_GALAXY_CLI_COLLECTION_OPTS} \
      --requirements-file /requirements/ansible.yaml --collections-path "/usr/share/ansible/collections" && \
    chmod -R a=rX /usr/share/ansible

######################################### RUNNER #########################################
 
FROM python:alpine

LABEL org.opencontainers.image.description="A really small Ansible Execution Environment that is easily customizable and maintainable withoud using the bloated ansible-builder ;)"

# Directory for executing Playbooks
WORKDIR /runner/

# Add non-root user
ARG USER=ansible && \
    GROUP=ansible && \
    UID=1000 && \
    GID=1000
RUN addgroup ${GROUP} --gid ${GID} && \
    adduser  ${USER}  --uid ${UID} \
      --ingroup "${GROUP}" \
      --disabled-password && \
    chown ${USER}:${GROUP} /runner/ /home/"${USER}"/

# Add runtime dependencies lists
COPY requirements/apk.list /requirements/

RUN apk add --no-cache $(cat /requirements/apk.list) && \
    ln -s /usr/local/bin/python3 /usr/bin/python3 && \
    pip install --no-cache-dir ansible-core

# Copy python environment (Ansible required args and scripts)
ENV PATH=/opt/ansible_venv/bin:${PATH} \
    ANSIBLE_ROLES_PATH=roles:/runner/roles:/usr/share/ansible/roles \
    ANSIBLE_COLLECTIONS_PATH=collections:/runner/collections:/usr/share/ansible/collections \
    ANSIBLE_LOCAL_TEMP=/tmp \
    ANSIBLE_INVENTORY_PLUGINS=/runner/project/plugins \
    ANSIBLE_SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s" \
    ANSIBLE_SSH_PIPELINING=True \
    ANSIBLE_HASH_BEHAVIOUR=merge
#    ANSIBLE_SSH_HOST_KEY_CHECKING=False \
COPY --from=builder /opt/ansible_venv/ /opt/ansible_venv/

#COPY --from=builder /usr/share/ansible/roles /usr/share/ansible/roles
COPY --from=builder /usr/share/ansible/collections /usr/share/ansible/collections

RUN chmod -R a=rX /usr/share/ansible
ENV HOME=/home/"${USER}"

# Switch to non-root user
USER ${UID}:${GID}