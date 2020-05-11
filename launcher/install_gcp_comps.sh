
#!/bin/bash

export PATH=$PATH:/usr/bin;

#rm -f /var/lib/apt/lists/lock;
#rm -f /var/cache/apt/archives/lock;
#rm -f /var/lib/dpkg/lock;
#dpkg --configure -a;

apt update -yq --fix-missing;

apt install dos2unix;
apt install -y unzip;

apt install -y git;

apt install -y software-properties-common ca-certificates apt-transport-https;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update -y;
apt install -y docker-ce;
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


#apt install -y python3.7;
#update-alternatives --install /usr/bin/python python /usr/bin/python3 10;
apt install -y python3-pip;
#pip3 install --upgrade pip;

#python3 -m pip uninstall pip;
#apt install python3-pip --reinstall;

apt-add-repository --yes --update ppa:ansible/ansible;
apt install -y ansible;

mkdir /terraform; chmod 755 /terraform; cd /terraform;
wget https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip;
unzip terraform_0.12.13_linux_amd64.zip;
rm terraform_0.12.13_linux_amd64.zip;
ln -s /terraform/terraform /usr/bin;

#### Install Kube*

apt install -y 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt update -y
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

### Install gcloud utility

# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk