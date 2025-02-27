provider "azurerm" {
  version = ">=2.0"
  # The "feature" block is required for AzureRM provider 2.x.
  features {}
}


resource "azurerm_resource_group" "RG-Terraform" {
  name     = "terraform-resource-group-2"
  location = "West Europe"
}

resource "azurerm_service_plan" "ASP-TerraForm" {
  name                = "terraform-appserviceplan"
  location            = azurerm_resource_group.RG-Terraform.location
  resource_group_name = azurerm_resource_group.RG-Terraform.name
  os_type             = "Windows"
  sku_name            = "P1v2"
  depends_on = [
    azurerm_resource_group.RG-Terraform
  ]
  
}

resource "azurerm_app_service" "AS-Terraform" {
  name                = "app-service-terraform"
  location            = azurerm_resource_group.RG-Terraform.location
  resource_group_name = azurerm_resource_group.RG-Terraform.name
  app_service_plan_id = azurerm_service_plan.ASP-TerraForm.id
 

  site_config {
    dotnet_framework_version = "v6.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.test.fully_qualified_domain_name} Database=${azurerm_sql_database.test.name};User ID=${azurerm_sql_server.test.administrator_login};Password=${azurerm_sql_server.test.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
   depends_on = [
    azurerm_resource_group.RG-Terraform,
    azurerm_service_plan.ASP-TerraForm
  ]
}

resource "azurerm_mssql_server" "test" {
  name                         = "terraform-sqlserver"
  resource_group_name          = azurerm_resource_group.RG-Terraform.name
  location                     = azurerm_resource_group.RG-Terraform.location
  version                      = "12.0"
  administrator_login          = "houssem"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  depends_on = [
    azurerm_resource_group.RG-Terraform
  ]
}

resource "azurerm_mssql_database" "test" {
  name                = "terraform-sqldatabase"
  resource_group_name = azurerm_resource_group.RG-Terraform.name
  location            = azurerm_resource_group.RG-Terraform.location
  server_name         = azurerm_mssql_server.test.name

  tags = {
    environment = "production"
  }
  depends_on = [
    azurerm_resource_group.RG-Terraform,
    azurerm_mssql_server.test.name
  ]
}
