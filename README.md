# Automated ELK Stack Deployment

This document contains the following details:
- Description of the Topology
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build
- Access Policies

### Description of the Topology
This repository includes code defining the infrastructure below. 

![]https://github.com/aavzta/ELK-Stack/blob/main/Diagram/U13%20ELK.png

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the "D*mn Vulnerable Web Application"

Load balancing ensures that the application will be highly **available**, in addition to restricting **inbound access** to the network. The load balancer ensures that work to process incoming traffic will be shared by both vulnerable web servers. Access controls will ensure that only authorized users — namely, ourselves — will be able to connect in the first place.

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the **file systems of the VMs on the network**, as well as watch **system metrics**, such as CPU usage; attempted SSH logins; `sudo` escalation failures; etc.

The configuration details of each machine may be found below.

| Name     |   Function  | IP Address | Operating System |
|----------|-------------|------------|------------------|
| Jump Box | Gateway     | 10.0.0.4   | Linux            |
| Web-1    | Web Server  | 10.0.0.5   | Linux            |
| Web-2    | Web Server  | 10.0.0.6   | Linux            |
| ELK      | Monitoring  | 10.1.0.4   | Linux            |

In addition to the above, Azure has provisioned a **load balancer** in front of all machines except for the jump box. The load balancer's targets are organized into the following availability zones:
- **Availability Zone 1**: Web-1 + Web-2

## ELK Server Configuration
The ELK VM exposes an Elastic Stack instance. **Docker** is used to download and manage an ELK container.

Rather than configure ELK manually, we opted to develop a reusable Ansible Playbook to accomplish the task. This playbook is duplicated below.


To use this playbook, one must log into the Jump Box, then issue: `ansible-playbook install_elk.yml elk`. This runs the `install_elk.yml` playbook on the `elk` host.

### Access Policies
The machines on the internal network are _not_ exposed to the public Internet. 

Only the **jump box** machine can accept connections from the Internet. Access to this machine is only allowed from the IP address `180.xxx.xx.xx`

Machines _within_ the network can only be accessed by **each other**. The Web-1 and Web-2 VMs send traffic to the ELK server.

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible (Port) | Allowed IP Addresses |
|----------|----------------------------|----------------------|
| Jump Box | Yes (SSH 22)               | 180.xxx.xx.xx        |
| ELK      | Yes (HTTP 5601)            | 180.xxx.xx.xx        |
| Web-1    | No  (SSH 22)               | 180.xxx.xx.xx        |
| Web-2    | No  (SSH 22)               | 180.xxx.xx.xx        |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because:

- App deployment, configuration management, workflow orchestration can be performed quickly, repetitively and at scale. 
- Human readable automation, tasks are executed in order, no special coding skills needed.

### Ansible Playbooks

The following playbooks are used in build & deployment:

#### Install-elk.yml
- install Docker
- install Python3
- install Docker Python module
- increase memory map area (262144)
- download and launch Docker elk container on boot

#### filebeat-playbook.yml
- download and install filebeat.deb
- enable and configure the system module
- setup and start the filebeat service on boot

#### metricbeat-playbook.yml
- download and install metricbeat.deb
- enable and configure the docker module for metricbeat
- setup and start the metricbeat service on boot


The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

  ![] https://github.com/aavzta/ELK-Stack/blob/main/Screen%20Shot%202022-05-27%20at%201.13.25%20pm.png
  
The playbook is duplicated below.
```yaml
---
- name: Configure Elk VM with Docker
  hosts: elk
  remote_user: azadmin
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        name: docker.io
        state: present

      # Use apt module
    - name: Install pip3
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

      # Use pip module
    - name: Install Docker python module
      pip:
        name: docker
        state: present

      # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: "262144"
        state: present
        reload: yes

      # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        published_ports:
          - 5601:5601
          - 9200:9200
          - 5044:5044

      # Use systemd module
    - name: Enable service docker on boot
      systemd:
        name: docker
        enabled: yes


```

### Target Machines & Beats
This ELK server is configured to monitor the Web-1 and Web-2 VMs, at `10.0.0.5` and `10.0.0.6`, respectively.

We have installed the following Beats on these machines:
- Filebeat
- Metricbeat

These Beats allow us to collect the following information from each machine:
- **Filebeat**: Filebeat detects changes to the filesystem. Specifically, we use it to collect Apache logs.
- **Metricbeat**: Metricbeat detects changes in system metrics, such as CPU usage. We use it to detect SSH login attempts, failed `sudo` escalations, and CPU/RAM statistics.

```yaml
---
- name: Installing and Launch Filebeat
  hosts: webservers
  become: yes
  tasks:
    # Use command module
  - name: Download filebeat .deb file
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb

    # Use command module
  - name: Install filebeat .deb
    command: dpkg -i filebeat-7.4.0-amd64.deb

    # Use copy module
  - name: Drop in filebeat.yml
    copy:
      src: /etc/ansible/files/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml

    # Use command module
  - name: Enable and Configure System Module
    command: filebeat modules enable system

    # Use command module
  - name: Setup filebeat
    command: filebeat setup

    # Use command module
  - name: Start filebeat service
    command: service filebeat start

    # Use systemd module
  - name: Enable service filebeat on boot
    systemd:
      name: filebeat
      enabled: yes
```

```yaml
---
- name: Install metric beat
  hosts: webservers
  become: true
  tasks:
    # Use command module
  - name: Download metricbeat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb

    # Use command module
  - name: install metricbeat
    command: dpkg -i metricbeat-7.4.0-amd64.deb

    # Use copy module
  - name: drop in metricbeat config
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

    # Use command module
  - name: enable and configure docker module for metric beat
    command: metricbeat modules enable docker

    # Use command module
  - name: setup metric beat
    command: metricbeat setup

    # Use command module
  - name: start metric beat
    command: service metricbeat start

    # Use systemd module
  - name: Enable service metricbeat on boot
    systemd:
      name: metricbeat
      enabled: yes
```


### Using the Playbooks
In order to use the playbooks, you will need to have an Ansible control node already configured. We use the **jump box** for this purpose.

To use the playbooks, we must perform the following steps:
- Copy the playbooks to the Ansible Control Node
- Update the ansible host file located /etc/ansible/hosts
```bash
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/IP can be a member of multiple groups
# You need only a [webservers] and [elkservers] group.

# List the IP Addresses of your webservers
# You should have at least 2 IP addresses
[webservers]
10.0.0.4 ansible_python_interpreter=/usr/bin/python3
10.0.0.5 ansible_python_interpreter=/usr/bin/python3
10.0.0.6 ansible_python_interpreter=/usr/bin/python3

# List the IP address of your ELK server
# There should only be one IP address
[elk]
10.1.0.4 ansible_python_interpreter=/usr/bin/python3
```

- Update the ansible configuration file located /etc/ansible/ansible.cfg and set remote user to sys admin (azadmin) of the web servers.

- Run each playbook on the appropriate targets, with the following steps:
```bash
#ssh the jumpbox via terminal
ssh azadmin@[Jumpbox public IP]

#start the ansible container
sudo docker start [ansible container name]
sudo docker attach [ansible container name]

#run ansible playbooks
ansible-playbook install-elk.yml
ansible-playbook filebeat-playbook.yml
ansible-playbook metricbeat.yml

```


To verify success, wait five minutes to give ELK time to start up. 

Then, via browser access Kibana on [http://elk server IP:5601/app/kibana#/home] This is the address of Kibana. Navigate via Discover icon, if the installation succeeded, filebeat logs, and metricbeat metrics will be available on the screen.
