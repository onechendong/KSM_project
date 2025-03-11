#!/bin/bash

# Set the number of VMs and parameters
VM_COUNT=5
VM_NAME_PREFIX="vm"
TEMPLATE_IMAGE="$HOME/vm_tmp_img/vm_tmp.qcow2"
VM_IMAGE_DIR="$HOME/vm_img"

# VM configuration
VM_MEMORY=512  # Memory (MB)
VM_CPU=1        # CPU cores
NETWORK_BRIDGE="virbr0"  # Default KVM network bridge

# Create cloud-init User Data for automatic Apache Server installation
cat > user-data <<EOF
#cloud-config
password: ubuntu
chpasswd: { expire: False }
ssh_pwauth: True
package_update: true
package_upgrade: true
packages:
  - apache2
runcmd:
  - systemctl enable apache2
  - systemctl start apache2

EOF


mkdir -p $VM_IMAGE_DIR

# Create 20 VMs
for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${VM_NAME_PREFIX}-${i}"
    VM_IMAGE="${VM_IMAGE_DIR}/${VM_NAME}.qcow2"
    
    echo "Creating VM: ${VM_NAME}"
    
    # Copy the template image
    cp ${TEMPLATE_IMAGE} ${VM_IMAGE}
    
    # Create the cloud-init seed image
    CLOUD_INIT_ISO="${VM_IMAGE_DIR}/${VM_NAME}-seed.iso"
    cloud-localds ${CLOUD_INIT_ISO} user-data 
    
    # Use virt-install to create the VM
    sudo virt-install \
        --name ${VM_NAME} \
        --ram ${VM_MEMORY} \
        --vcpus ${VM_CPU} \
        --disk path=${VM_IMAGE},format=qcow2 \
        --disk path=${CLOUD_INIT_ISO},device=cdrom \
        --os-type linux \
        --os-variant ubuntu22.04 \
        --network bridge=${NETWORK_BRIDGE},model=virtio \
        --graphics none \
        --console pty,target_type=serial \
        --noautoconsole \
        --import &
    
    echo "VM ${VM_NAME} created and Apache Server started"
done
wait