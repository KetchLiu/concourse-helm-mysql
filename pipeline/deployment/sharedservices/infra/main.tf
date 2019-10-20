# Configure the Azure Provider

/*provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  # VGC
  version = ">1.28.0"
  environment = "${var.azurerm_environment}"
  subscription_id = "${var.azurerm_subscription_id}"
  tenant_id       = "${var.azurerm_tenant_id}"
}
*/

/* provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  # Group Services Subscription
  version = ">1.28.0"
  environment = "China"
  subscription_id = "1735c12f-21a4-4ca2-9c7c-a1c4dbbcf513"
  tenant_id       = "a12a82ff-eb68-4d6d-b3c7-c4fb2d2220e5"
}
 */
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.gsbproxy_rg}"
  location = "${var.gsbproxy_location}"
}

data "azurerm_resource_group" "sharedservice-rg" {
  name = "${var.shared_service_rg}"
}


# Create avset
/* resource "azurerm_availability_set" "gsbproxy-avset" {
  name                = "vm-dp-sharedservices-gsbproxy-preprod-avset"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = 2
  platform_fault_domain_count = 2
  managed = true

  tags = {
    environment = "Production"
  }
} */


# Create a virtual network within the resource group

data "azurerm_virtual_network" "sharedservice-vnet" {
  name                = "${var.shared_service_vnet}"
  resource_group_name = "${data.azurerm_resource_group.sharedservice-rg.name}"
}

data "azurerm_subnet" "gsb-subnet" {
  name                 = "${var.shared_service_subnet}"
  virtual_network_name = "${data.azurerm_virtual_network.sharedservice-vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.sharedservice-rg.name}"
}

/* resource "azurerm_virtual_network" "vnet" { 
  name                = "vnet-dp-gsb-preprod" 
  location            = "${azurerm_resource_group.rg.location}" 
  address_space       = ["10.231.102.0/24"]
  resource_group_name = "${azurerm_resource_group.rg.name}" 
} 

# Create s subnet 
resource "azurerm_subnet" "trasfter" { 
  name                 = "sbn-dp-gsb-transfter-preprod" 
  virtual_network_name = "${azurerm_virtual_network.vnet.name}" 
  resource_group_name  = "${azurerm_resource_group.rg.name}" 
  address_prefix       = "10.231.102.0/24" 
}
 */
# Create network interface 
/* resource "azurerm_network_interface" "gsbproxy-nic" { 
   name                = "vm-dp-sharedservices-gsbproxy-${count.index}-preprod-nic" 
   location            = "${azurerm_resource_group.rg.location}" 
   resource_group_name = "${azurerm_resource_group.rg.name}" 
   count = 2
 
 
   ip_configuration { 
     name                                    = "ipconfig${count.index}" 
     subnet_id                               = "${azurerm_subnet.trasfter.id}" 
     private_ip_address_allocation           = "Dynamic" 
    } 
 }  */

# Create virtual machine
/* resource "azurerm_virtual_machine" "gsbproxy" {
  name                  = "vm-dp-sharedservices-gsbproxy-${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  availability_set_id   = "${azurerm_availability_set.gsbproxy-avset.id}"
  network_interface_ids = ["${element(azurerm_network_interface.gsbproxy-nic.*.id, count.index)}"]
  vm_size               = "Standard_B2s"
  delete_os_disk_on_termination = true
  count = 2
  
 storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vm-dp-sharedservices-gsbproxy-${count.index}_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm-dp-sharedservices-gsbproxy-${count.index}"
    admin_username = "${local.admin_username}"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${file("~/.ssh/id_rsa.pub")}"
      path = "/home/${local.admin_username}/.ssh/authorized_keys"
      
    }
  
  }
  tags = {
    environment = "Production"
  }
} */

resource "azurerm_network_security_group" "gsbproxy-nsg" {
  name                = "${var.gsbproxy_vmss_nsg_name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

    security_rule {
    name                       = "allow_Inbound_proxy-80"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

    security_rule {
    name                       = "allow_Inbound_proxy-443"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

}

resource "azurerm_lb" "gsbproxylb" { 
   resource_group_name = "${azurerm_resource_group.rg.name}" 
   name                = "${var.gsbproxy_vmss_lb_name}" 
   location            = "${azurerm_resource_group.rg.location}" 
 
 
   frontend_ip_configuration { 
     name                 = "${var.gsbproxy_vmss_lb_name}-fe" 
     private_ip_address_allocation = "static"
     subnet_id ="${data.azurerm_subnet.gsb-subnet.id}"
     private_ip_address ="${var.gsbproxy_vmss_lb_ip}"
   } 
} 

resource "azurerm_lb_backend_address_pool" "backend_pool" { 
   resource_group_name = "${azurerm_resource_group.rg.name}" 
   loadbalancer_id     = "${azurerm_lb.gsbproxylb.id}" 
   name                = "${var.gsbproxy_vmss_lb_name}-be" 
} 

resource "azurerm_lb_rule" "lb_rule" { 
   resource_group_name            = "${azurerm_resource_group.rg.name}" 
   loadbalancer_id                = "${azurerm_lb.gsbproxylb.id}" 
   name                           = "${var.gsbproxy_vmss_lb_name}-rule-tcp80" 
   protocol                       = "tcp" 
   frontend_port                  = 80 
   backend_port                   = 80 
   frontend_ip_configuration_name = "${var.gsbproxy_vmss_lb_name}-fe" 
   enable_floating_ip             = false 
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}" 
   idle_timeout_in_minutes        = 5 
   probe_id                       = "${azurerm_lb_probe.lb_probe.id}" 
   load_distribution              = "SourceIP"
   depends_on                     = ["azurerm_lb_probe.lb_probe"] 
 } 

 resource "azurerm_lb_rule" "lb_rule1" { 
   resource_group_name            = "${azurerm_resource_group.rg.name}" 
   loadbalancer_id                = "${azurerm_lb.gsbproxylb.id}" 
   name                           = "${var.gsbproxy_vmss_lb_name}-rule-tcp443" 
   protocol                       = "tcp" 
   frontend_port                  = 443 
   backend_port                   = 443 
   frontend_ip_configuration_name = "${var.gsbproxy_vmss_lb_name}-fe" 
   enable_floating_ip             = false 
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}" 
   idle_timeout_in_minutes        = 5 
   probe_id                       = "${azurerm_lb_probe.lb_probe.id}" 
   load_distribution              = "SourceIP"
   depends_on                     = ["azurerm_lb_probe.lb_probe"] 
 } 


 resource "azurerm_lb_probe" "lb_probe" { 
   resource_group_name = "${azurerm_resource_group.rg.name}" 
   loadbalancer_id     = "${azurerm_lb.gsbproxylb.id}" 
   name                = "${var.gsbproxy_vmss_lb_name}-Probe" 
   protocol            = "tcp" 
   port                = 80 
   interval_in_seconds = 5 
   number_of_probes    = 2 
 } 

/*  resource "azurerm_network_interface_backend_address_pool_association" "dns-bk" {
  network_interface_id    = "${element(azurerm_network_interface.gsbproxy-nic.*.id, count.index)}"
  ip_configuration_name   = "ipconfig${count.index}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  count = 2
} */
/* resource "azurerm_virtual_machine_extension" "nginx" {
  name                 = "setting_nginx"
  location             = "${azurerm_resource_group.rg.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "vm-dp-sharedservices-gsbproxy-${count.index}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  count = 2

settings = <<SETTINGS
    {
      "fileUris": ["https://storaccchfshavm.blob.core.chinacloudapi.cn/nfsha/nfs-ha-cluster-ubuntu/gsbproxy.sh?sv=2018-03-28&ss=bfqt&srt=sco&sp=rwdlacup&se=2019-06-04T17:14:39Z&st=2019-05-17T09:14:39Z&spr=https&sig=nZhUh3qd%2ByM0proJSBRwjhMgiy4rokc2TFAKHUkmoQk%3D"]
    }
  SETTINGS
  
protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "bash -x gsbproxy.sh}"
    }
PROTECTED_SETTINGS
 depends_on = ["azurerm_virtual_machine.gsbproxy"]
  }  */

 data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
 }

 resource "azurerm_virtual_machine_scale_set" "gsbproxy-set" {
  name                = "${var.gsbproxy_vmss_name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  overprovision = false

  # automatic rolling upgrade
  automatic_os_upgrade = false
  upgrade_policy_mode = "Automatic"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = "${azurerm_lb_probe.lb_probe.id}"

  sku {
    name     = "Standard_D2_v2"
    tier     = "Standard"
    capacity = 2
  }
  identity {
    type = "SystemAssigned"
  }

  storage_profile_image_reference {
    id = "${data.azurerm_image.custom.id}"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type ="Linux"
  }

  os_profile {
    computer_name_prefix = "${var.gsbproxy_vmss_name}-"
    admin_username       = "${var.gsbproxy_vmss_username}"
    custom_data = <<HEREDOC
#!/bin/sh

#Application software configuration - to be moved from here when configuration tool available

apt-get update

apt-get --assume-yes install nginx -y
rm /etc/nginx/nginx.conf

cat << EOF | tee /tmp/self-signed.conf
ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
EOF

sudo cat << EOF | tee /tmp/ssl-params.conf
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
#resolver 8.8.8.8 8.8.4.4 valid=300s;
#resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/nginx/ssl/dhparam.pem;
EOF

# Set vault environment variables
export VAULT_ADDR="${var.vault_address}"
export VAULT_PATH="${var.vault_path}"

#DISABLE TLS_VERIFY (TEMPORARY!!!)
export VAULT_SKIP_VERIFY=true

# Install latest vault
apt-get --assume-yes install unzip -y
vault_releases="https://releases.hashicorp.com"
vault_latest_release=$(curl -kL "$vault_releases/vault/" | egrep -o "/vault/[0-9.]+/" | head -n 1)
latest_vault=$(curl -kL "$vault_releases$vault_latest_release" | egrep -o "vault_[0-9.]+_linux_amd64.zip" | head -n 1)

(curl -kfLRO "$vault_releases$vault_latest_release$latest_vault" && unzip "$latest_vault" -d /usr/sbin) &
wait

#Get the vault access token
apt-get --assume-yes install jq -y
export rolename='${var.vault_role}'
export jwt="$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.chinacloudapi.cn%2F' -H Metadata:true | jq -r '.access_token')"
tee /tmp/msi_payload.json > /dev/null << EOF
{"role":"$rolename", "jwt":"$jwt"}
EOF

export msi_token=$(curl -k --request POST --data @/tmp/msi_payload.json $VAULT_ADDR/v1/auth/jwt/login | jq -r '.auth' | jq -r '.client_token')
rm -f /tmp/msi_payload.json
vault login $msi_token


#Read he SSH Private key from vault
mkdir -p /root/.ssh
vault read -field=sshkey $VAULT_PATH/bitbucket > /root/.ssh/id_rsa

#copy nginx.conf from bitbucket
ssh-keygen -F "[devstack.vgc.com.cn]:7999" || ssh-keyscan -p 7999 devstack.vgc.com.cn >> /root/.ssh/known_hosts
#chmod 644 /root/.ssh/known_hosts
chmod 600 /root/.ssh/id_rsa
git clone ssh://git@devstack.vgc.com.cn:7999/mss/b-010-gsb-mbb-mvp-azure.git /tmp/bitbucket
cp /tmp/bitbucket/nginx.conf /tmp/nginx.conf
rm -r -f /tmp/bitbucket
rm -f /root/.ssh/id_rsa
ssh-keygen -R "[devstack.vgc.com.cn]:7999"
rm -f /root/.ssh/known_hosts.old

mkdir /etc/nginx/ssl
sudo chmod 757 /etc/nginx/
chmod 777 /tmp/nginx.conf
cp /tmp/nginx.conf /etc/nginx/nginx.conf
rm -f /tmp/nginx.conf
cp /tmp/self-signed.conf /etc/nginx/snippets/
cp /tmp/ssl-params.conf /etc/nginx/snippets/
rm -f /tmp/self-signed.conf
rm -f /tmp/ssl-params.conf

#Secret key Management
vault read -field=cert $VAULT_PATH/nginx-cert/vw-ca-root-05 > /etc/nginx/ssl/VW-CA-ROOT-05.pem
	mkdir /etc/nginx/ssl/tui
	vault read -field=cert $VAULT_PATH/nginx-cert/tui > /etc/nginx/ssl/tui/cert.pem
	vault read -field=key $VAULT_PATH/nginx-cert/tui > /etc/nginx/ssl/tui/cert.key

	mkdir /etc/nginx/ssl/pre
	vault read -field=cert $VAULT_PATH/nginx-cert/pre > /etc/nginx/ssl/pre/cert.pem
	vault read -field=key $VAULT_PATH/nginx-cert/pre > /etc/nginx/ssl/pre/cert.key

	mkdir /etc/nginx/ssl/prd
	vault read -field=cert $VAULT_PATH/nginx-cert/prd > /etc/nginx/ssl/prd/cert.pem
	vault read -field=key $VAULT_PATH/nginx-cert/prd > /etc/nginx/ssl/prd/cert.key

  mkdir /etc/nginx/ssl/dmo
	vault read -field=cert $VAULT_PATH/nginx-cert/dmo > /etc/nginx/ssl/dmo/cert.pem
	vault read -field=key $VAULT_PATH/nginx-cert/dmo > /etc/nginx/ssl/dmo/cert.key


#Create self-signed certificates
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=de/ST=test/L=test/O=test/OU=test/CN=gsbproxy/emailAddress=gsbproxy@volkswagen.de"
openssl dhparam -dsaparam -out /etc/nginx/ssl/dhparam.pem 2048

service nginx configtest
#Start nginx
service nginx start
#Check nginx status
service nginx status
#Restart nginx
service nginx restart

HEREDOC
}

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.gsbproxy_vmss_username}/.ssh/authorized_keys"
      key_data = "${var.gsbproxy_vmss_ssh_pub_key}"
    }
  }

  network_profile {
    name    = "networkprofile"
    primary = true
    network_security_group_id = "${azurerm_network_security_group.gsbproxy-nsg.id}"

    ip_configuration {
      name                                   = "IPConfig2"
      primary                                = true
      subnet_id                              = "${data.azurerm_subnet.gsb-subnet.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
    }

    dns_settings {
      dns_servers = ["${var.gsbproxy_vmss_dnsserver_ip}"]
    }
    
  }

  /* extension {

    name                 = "setting_nginx"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
      "fileUris": ["https://storaccchfshavm.blob.core.chinacloudapi.cn/nfsha/nfs-ha-cluster-ubuntu/gsbproxy.sh?st=2019-06-03T08%3A50%3A11Z&se=2020-06-04T08%3A50%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=6uHjsFxvcM4xuDlTnIhZRg0Zpbofaam%2FWFM9HojwsiY%3D"]
    }
  SETTINGS
  
    protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "bash -x gsbproxy.sh"
    }
PROTECTED_SETTINGS
}  */


  tags = {
    environment = "${var.gsbproxy_vmss_tag_environment}"
  }
}

resource "azurerm_monitor_autoscale_setting" "gsb-autoscale" {
  name                = "${var.gsbproxy_vmss_autoscale_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.gsbproxy_vmss_autoscale_location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.gsbproxy-set.id}"
  
  

  profile {
    name = "default"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.gsbproxy-set.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 85
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.gsbproxy-set.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 15
        
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
    
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }

}

 
