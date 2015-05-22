#!/bin/bash

source /root/.openrc

nova flavor-delete m1.micro || :
nova flavor-create m1.micro --ephemeral 20 12 128 0 1
nova flavor-create m1.micro.avx 21 128 0 1
nova flavor-key 21 set "capabilities:cpu_info:features"="<in> avx"
nova flavor-create m1.micro.avx2 22 128 0 1
nova flavor-key 22 set "capabilities:cpu_info:features"="<in> avx2"

cd /root
glance image-create --name="cirros" --is-public=True \
            --container-format bare --disk-format qcow2 \
            < cirros-0.3.2-x86_64-disk.img

mkdir -p ~/.ssh
( umask 77 ; nova keypair-add testkey > ~/.ssh/id_rsa )

for i in $(seq 1 60) ; do # wait for image to finish uploading
        glance image-list|grep active && break
        sleep 5
done
glance image-list

echo "heat stack-create -f heat.yaml stack1"
