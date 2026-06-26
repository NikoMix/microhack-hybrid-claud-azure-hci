# main.tf — shared base environment for the Azure Local Module B microhack.
# Built "Azure Verified Modules first"; the workload VM uses raw azurerm
# resources because the lab needs a plain, internet-reachable Ubuntu host that a
# later challenge will Azure Arc-onboard via the documented IMDS-block technique.

locals {
  suffix = "mhb-${var.initials}"

  # Common naming for all resources.
  resource_group_name = "rg-${local.suffix}"
  workspace_name      = "log-${local.suffix}"
  identity_name       = "uami-${local.suffix}"
  nsg_name            = "nsg-${local.suffix}"
  vnet_name           = "vnet-${local.suffix}"
  subnet_name         = "snet-${local.suffix}"
  public_ip_name      = "pip-${local.suffix}"
  nic_name            = "nic-${local.suffix}"
  vm_name             = "vm-${local.suffix}"
  os_disk_name        = "osdisk-${local.suffix}"

  admin_username = "azureuser"
}

# ---------------------------------------------------------------------------
# Resource group (AVM)
# ---------------------------------------------------------------------------
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = local.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = true
}

# ---------------------------------------------------------------------------
# Log Analytics workspace (AVM) — central log sink for later observability work
# ---------------------------------------------------------------------------
module "log_analytics" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                                      = local.workspace_name
  location                                  = var.location
  resource_group_name                       = module.resource_group.name
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_retention_in_days = 30
  tags                                      = var.tags
  enable_telemetry                          = true
}

# ---------------------------------------------------------------------------
# User-assigned managed identity (AVM) — reused by later challenges for RBAC
# ---------------------------------------------------------------------------
module "user_assigned_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.0"

  name                = local.identity_name
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
  enable_telemetry    = true
}

# ---------------------------------------------------------------------------
# Network security group (AVM) — SSH allowed only from the pupil's source
# ---------------------------------------------------------------------------
module "network_security_group" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = local.nsg_name
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
  enable_telemetry    = true

  security_rules = {
    allow_ssh_inbound = {
      name                       = "Allow-SSH-Inbound"
      access                     = "Allow"
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = var.allowed_ssh_source
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
      description                = "Allow SSH from the pupil's source IP/CIDR (set via allowed_ssh_source)."
    }
  }
}

# ---------------------------------------------------------------------------
# Virtual network + subnet (AVM) — NSG associated at the subnet level
# ---------------------------------------------------------------------------
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.19.0"

  name             = local.vnet_name
  location         = var.location
  parent_id        = module.resource_group.resource_id
  address_space    = ["10.10.0.0/16"]
  tags             = var.tags
  enable_telemetry = true

  subnets = {
    base = {
      name             = local.subnet_name
      address_prefixes = ["10.10.1.0/24"]
      network_security_group = {
        id = module.network_security_group.resource_id
      }
    }
  }
}

# ---------------------------------------------------------------------------
# SSH key pair (tls) — password auth is disabled on the VM
# ---------------------------------------------------------------------------
resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Persist the private key locally (0600) so pupils can SSH in immediately.
# Gitignored via infra/terraform/base/.gitignore (id_rsa_mhb*).
resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.vm.private_key_pem
  filename        = "${path.module}/id_rsa_mhb"
  file_permission = "0600"
}

# ---------------------------------------------------------------------------
# Workload VM: the "server to migrate" (raw azurerm)
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "vm" {
  name                = local.public_ip_name
  resource_group_name = module.resource_group.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "vm" {
  # checkov:skip=CKV_AZURE_119:Lab-only public IP — pupils SSH directly to the VM, which is later Azure Arc-onboarded.
  name                = local.nic_name
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.virtual_network.subnets["base"].resource_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  # checkov:skip=CKV_AZURE_50:Lab VM intentionally has no extension protection lock so later challenges can install the Arc agent.
  name                = local.vm_name
  computer_name       = local.vm_name
  resource_group_name = module.resource_group.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = local.admin_username
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.vm.id]

  # SSH-key auth only — password authentication is disabled.
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.admin_username
    public_key = tls_private_key.vm.public_key_openssh
  }

  os_disk {
    name                 = local.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Managed (platform) boot diagnostics — no storage account required.
  boot_diagnostics {}
}
