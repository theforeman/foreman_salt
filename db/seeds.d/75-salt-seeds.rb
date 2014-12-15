# Create feature for Smart Proxy
Feature.find_or_create_by_name('Salt')

# Add new viewing permissions to Viewer role
viewer = Role.find_by_name('Viewer')

if viewer
  Permission.where(:name => [:view_smart_proxies_salt_keys, :view_smart_proxies_salt_autosign, :view_salt_modules]).each do |permission|
    viewer.add_permissions!([permission.name]) unless viewer.permissions.include? permission
  end
end
