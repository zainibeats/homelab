# Azure Jump Server

Terraform for a single Azure Linux jump server.

Use this when Azure resources need one SSH entry point before connecting to
other cloud hosts or private resources.

## Layout

- This directory creates the Azure compute, network, SSH key, and monitoring resources.
- `terraform.tfvars.example` shows the required inputs and common overrides.

Set `trusted_ipv4_cidrs` in `terraform.tfvars` to the single public
IPv4 `/32` that should be allowed to SSH to the jump server.

By default, resource names are derived from `service_name` and `environment`.
Use the optional resource-name overrides in `terraform.tfvars` only
when you need to match existing Azure resources, imported resources, or an
organization-specific naming standard.

## Optional VM Extensions

`enable_aad_ssh_login` installs the Azure AD SSH Login extension and is enabled
by default.

Leave `enable_vm_access` disabled for normal provisioning. `VMAccessForLinux` is
a recovery extension for repair operations, not a general access bootstrapper;
enable it only when you also provide an explicit recovery configuration.

## VM Insights

Set `enable_azure_monitor_agent = true` to install the Azure Monitor Agent.
Set `enable_vm_insights_rule = true` only when you also provide
`log_analytics_workspace_resource_id`.

The Log Analytics workspace can be in a different resource group from the VM.
Use the full workspace resource ID, for example:

```hcl
log_analytics_workspace_resource_id = "/subscriptions/<subscription-id>/resourceGroups/<workspace-rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
```

When VM Insights is enabled, Terraform creates the data collection rule and
associates that rule with the VM.
