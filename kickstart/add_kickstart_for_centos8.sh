#! /bin/bash

source $HOME/settings_upi.env

IGNITION_ENDPOINT="https://api.${CLUSTER_NAME}.${BASE_DOMAIN}:22623/config/worker"
CORE_SSH_KEY=$(cat $HOME/.ssh/id_rsa.pub)
ENROLL_CENTOS_NODE=$(cat ./scripts/enroll_centos8_node.sh)
PODMAN_SERVICE=$(cat ./scripts/podman_service.sh)
KUBECONFIG_FILE=$(cat $KUBECONFIG_PATH)

cat > centos8-worker-kickstart.cfg <<EOT
lang en_US
keyboard us
timezone Etc/UTC --isUtc
rootpw --plaintext ${ROOT_PASSWORD}
reboot
cmdline
install
url --url=${OS_INSTALL_ENDPOINT}/
repo --name="AppStream" --baseurl=${OS_INSTALL_ENDPOINT}/AppStream/
bootloader --location=mbr --append="rhgb quiet crashkernel=auto"
zerombr
clearpart --all --initlabel
autopart --noswap --nohome
auth --passalgo=sha512 --useshadow
selinux --disabled
services --disabled firewalld,nftables

skipx
firstboot --disable
user --name=core --groups=wheel
%post --erroronfail --log=/root/ks-post.log

# Add core ssh key
mkdir -m0700 /home/core/.ssh
cat <<EOF > /home/core/.ssh/authorized_keys
${CORE_SSH_KEY}
EOF
chmod 0600 /home/core/.ssh/authorized_keys
chown -R core:core /home/core/.ssh
restorecon -R /home/core/.ssh

# enable passwordless sudo for wheel
echo "%wheel   ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/wheel
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# write pull secret
cat <<EOF > /opt/pull.json
${PULL_SECRET}
EOF

# write kubeconfig
mkdir -p /root/.kube
cat <<EOF > /root/.kube/config
${KUBECONFIG_FILE}
EOF

# write ignition endpoint
cat <<EOF > /opt/ignition_endpoint
${IGNITION_ENDPOINT}
EOF

# write enroll script
cat <<'EOF' > /opt/enroll_centos8_node.sh
${ENROLL_CENTOS_NODE}
EOF

# write runignition script
cat <<'EOF' > /opt/runignition.sh
${PODMAN_SERVICE}
EOF

chmod a+x /opt/runignition.sh
touch /opt/runonce

# execute enroll script
bash /opt/enroll_centos8_node.sh
%end
%packages
@base
%end
EOT
