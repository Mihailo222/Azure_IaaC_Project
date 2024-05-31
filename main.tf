#code9 project

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.104.0"
    }
  }
  backend "azurerm" {
  resource_group_name  = "Code9-12"
  storage_account_name = "code912terraform"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
features {}
subscription_id = ""
}

resource "azurerm_log_analytics_workspace" "log-code9-12" {
  name                = "workspace-code9-st12-weu-01"
  location            = "westeurope"
  resource_group_name = "Code9-12"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "api-code9-12" {
  name                = "appi-code9-st12-weu-01"
  location            = "westeurope"
  resource_group_name = "Code9-12"
  workspace_id        = azurerm_log_analytics_workspace.log-code9-12.id
  application_type    = "web"
}

#App service

resource "azurerm_service_plan" "plan-code9-api-01" {
  name                = "asp-code9-api-st12-weu-01"
  resource_group_name = "Code9-12"
  location            = "westeurope"
  sku_name            = "B1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "app-code9-api-01" {
  name     = "asp-code9-api-st12-weu-01"
  resource_group_name = "Code9-12"
  location            = "westeurope"
  service_plan_id     = azurerm_service_plan.plan-code9-api-01.id
  https_only = true
  site_config {
    
  }
}


resource "azurerm_mssql_server" "sql-code9-server-01" {
  name                         = "sqlcode9st12neu01"
  resource_group_name          = "Code9-12"
  location                     = "northeurope"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  minimum_tls_version = "1.2"
  public_network_access_enabled = true
}

resource "azurerm_mssql_database" "sqldb-code9-01" {
  name           = "sqldb-code9-st12-weu-01"
  server_id      = azurerm_mssql_server.sql-code9-server-01.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2
  sku_name       = "Basic"
  zone_redundant = false


  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}


resource "azurerm_storage_account" "st-code9-01" {
  name                     = "code9st12weu01"
  resource_group_name      = "Code9-12"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier = "Hot"
  public_network_access_enabled = true
}


resource "azurerm_storage_container" "st-code9-container-01" {
  name                  = "code9files"
  storage_account_name  = azurerm_storage_account.st-code9-01.name
  container_access_type = "private"
}
