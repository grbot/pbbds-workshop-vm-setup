# Setting up the server (with terraform)

Get repos
```
git https://github.com/grbot/pbbds-workshop-vm-setup.git
```
Change to `pbbds-workshop-vm-setup` directory
```
cd pbbds-workshop-vm-setup
```
Check Terraform version
```
terraform -version
Terraform v1.3.27
```
Clean up space if previous installation exists here
```
rm -rf  .terraform*
rm -rf terraform.tfstate*
```
Initialise Terraform environment
```
terraform init
```
Need to have a file called `terraform.tfvars` , with information below. The information can be retrieved from the OpenStack dashboard drop down on the right, select RC File v3.

```
# No need to change
ssh_key_public      = "~/.ssh/id_rsa.pub"
ssh_key_private     = "~/.ssh/id_rsa"
# Replace from here on
auth_url            = "XXX"
project_domain_name = "XXX"
user_domain_name    = "XXX"
region              = "XXX"
user_name           = "XXX"
password            = "XXX"
unique_network_name = "XXX"
floating_ip_pool    = "XXX"
server_name         = "XXX"   
```
A new key will be created `$server_name-key`. (If this already exist on the OpenStack dashboard remove it before continuing)

In `instances.tf` can change the `image_name` and `flavor_id` . (This information can be retreived from OpenStack dashboard/ or OpeStack CLI).

Set the `count` to the amount of servers needed. Also need to set the same number in the floatingip and floatingip_associate section.

Regarding naming

If
```
count = 25
name = "${var.server_name}-${count.index + 1}"
```
Thirty servers would be created each named e.g. `server-1`, `server-2` ... `server-25`

Lets get the servers up.
```
terraform apply
```

# Setting up the packages and users (with ansible)

Check Ansible version
```
ansible --version
ansible 2.10.8
```

Now create a file to drive the Ansible installation

First set OpenStack variables to be used in OpenStack CLI

```
export OS_USERNAME=username
export OS_PASSWORD=password
export OS_PROJECT_NAME=project_name
export OS_PROJECT_DOMAIN_ID=project_domain
export OS_USER_DOMAIN_ID=user_domain
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_URL=auth_url
```

Then create file
```
for i in $(seq 1 25); do echo "user"$i;done > prep/users
for i in $(seq 1 25); do p1=`pwgen -1`; p2=`pwgen -1`; echo -e $p1"\t"$p2;done > prep/passwords
for i in $(seq 1 25); do echo "pbbds-workshop-"$i;done > prep/servers
paste <(openstack server list --name pbbds-workshop -f json | jq '.[].Name' | sed 's/"//g') <(openstack server list --name pbbds-workshop -f json | jq '.[].Networks."cbio-net"[0]' | sed 's/"//g') <(openstack server list --name pbbds-workshop -f json | jq '.[].Networks."cbio-net"[1]' | sed 's/"//g') | sort -V -k 1 | grep -w -f prep/servers > prep/ips
paste prep/users prep/ips prep/passwords > prep/all
```

```
rm -rf all-plays/
./prep.sh prep/all
```

Now need to loop through above all for setting up machines

```
for i in $(seq 1 25); do echo all-plays/pbbds-workshop-$i; done | parallel "cd {}; ansible-playbook -i inventory.yaml playbook.yml > log.txt 2>&1"
```

Not sure why but the sshd restart handle does not take affect. This causes users (that requires a password login) to not be able to login. You would be presented with the error e.g. `user1@154.114.10.85: Permission denied (publickey)`

To resolve this a manual restart of the sshd was issued:

```
while read line; do ip=`echo $line | awk '{print $4}'`; echo $ip;ssh -n $ip sudo systemctl restart sshd; done< prep/all
```