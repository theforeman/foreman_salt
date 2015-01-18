module ForemanSalt
  class FactImporter < ::FactImporter
    def fact_name_class
      ForemanSalt::FactName
    end

    def self.support_background
      true
    end

    def self.authorized_smart_proxy_features
      'Salt'
    end

    private

    attr_accessor :original_facts

    def add_new_facts
      @counters[:added] = 0
      add_missing_facts(unsparse(original_facts))
      logger.debug("Merging facts for '#{host}': added #{@counters[:added]} facts")
    end

    def add_missing_facts(tree_hash, parent = nil, prefix = '')
      tree_hash.each do |name, value|
        name_with_prefix = prefix.empty? ? name : prefix + FactName::SEPARATOR + name

        compose = value.is_a?(Hash)
        if fact_names[name_with_prefix].present?
          fact_name_id = fact_names[name_with_prefix]
        else
          fact_name_id = fact_name_class.create!(:name      => name_with_prefix,
                                                 :parent_id => parent,
                                                 :compose   => compose).id
        end

        if compose
          add_fact(name_with_prefix, nil, fact_name_id)
          add_missing_facts(value, fact_name_id, name_with_prefix)
        else
          add_fact(name_with_prefix, value, fact_name_id)
        end
      end
    end

    def add_fact(name, value, fact_name_id)
      if facts_to_create.include?(name)
        host.fact_values.send(method,
                              :value => value, :fact_name_id => fact_name_id)
        @counters[:added] += 1
      end
    end

    def facts_to_create
      @facts_to_create ||= facts.keys - db_facts.keys
    end

    def fact_names
      @fact_names ||= fact_name_class.maximum(:id, :group => 'name')
    end

    # if the host does not exists yet, we don't have an host_id to use the fact_values table.
    def method
      @method ||= host.new_record? ? :build : :create!
    end

    def normalize(facts)
      @original_facts = super(facts)
      @facts = completify(@original_facts)
    end

    def completify(hash)
      new_facts = hash.dup
      hash.each do |fact_name, value|
        name_parts = fact_name.split(FactName::SEPARATOR)

        name_parts.inject([]) do |memo, name|
          memo += [name]
          key = memo.join(FactName::SEPARATOR)
          new_facts[key] ||= name_parts == memo ? value : nil
          memo
        end
      end
      new_facts
    end

    def sort_by_key(hash)
      hash.sort_by { |k, _v| k.to_s }
    end

    def sparse(hash, options = {})
      hash.map do |k, v|
        prefix = (options.fetch(:prefix, []) + [k])
        next Sparsify.sparse(v, options.merge(:prefix => prefix)) if v.is_a? Hash
        { prefix.join(options.fetch(:separator, FactName::SEPARATOR)) => v }
      end.reduce(:merge) || {}
    end

    def unsparse(hash, options = {})
      ret = {}
      sparse(hash).each do |k, v|
        current            = ret
        key                = k.to_s.split(options.fetch(:separator, FactName::SEPARATOR))
        current            = (current[key.shift] ||= Hash.new) until (key.size <= 1)
        current[key.first] = v
      end
      ret
    end
  end
end
