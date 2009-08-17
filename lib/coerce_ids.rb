class ActiveRecord::Base
  def self.find_from_ids_with_coercion(ids, options)
    ids = ids.flatten.collect{ |id| id.to_i }
    find_from_ids_without_coercion(ids, options)
  end

  class << self
    alias_method :find_from_ids_without_coercion, :find_from_ids
    alias_method :find_from_ids, :find_from_ids_with_coercion
  end

end
