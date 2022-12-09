#####################
# Resources section #
#####################
resource "azurerm_monitor_diagnostic_setting" "diagnostic_logs" {
  name               = var.name
  target_resource_id = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id 

  dynamic "log" {
    for_each = var.diagnostic_logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.retention
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
