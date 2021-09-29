object @salt_variable

attribute :parameter
attributes :id, :variable, :salt_state, :salt_state_id, :description, :override,
           :variable_type, :hidden_value?, :validator_type,
           :validator_rule, :merge_overrides, :merge_default,
           :avoid_duplicates, :override_value_order, :created_at, :updated_at,
           :default_value

node do |salt_variable|
  {
    :override_values => partial(
      'api/v2/override_values/main',
      :object => salt_variable.lookup_values
    )
  }
end

node :override_values_count do |lk|
  lk.lookup_values.count
end
