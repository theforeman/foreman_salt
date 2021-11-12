begin
  # Helper Extensions
  ::HostsHelper.include ForemanSalt::HostsHelperExtensions
  ::SmartProxiesHelper.include ForemanSalt::SmartProxiesHelperExtensions

  # Model Extensions
  ::Host::Managed.include ForemanSalt::Concerns::HostManagedExtensions
  ::Hostgroup.include ForemanSalt::Concerns::HostgroupExtensions

  # Controller Extensions
  ::HostsController.include ForemanSalt::Concerns::HostsControllerExtensions
  ::HostgroupsController.include ForemanSalt::Concerns::HostgroupsControllerExtensions
rescue StandardError => e
  Rails.logger.error "ForemanSalt: skipping engine hook (#{e})"
end
