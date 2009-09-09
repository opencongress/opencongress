module OpenIdAuthentication
  class Association < ActiveRecord::Base
    set_table_name :open_id_authentication_associations

    def from_record
      OpenID::Association.new(handle, secret, issued, lifetime, assoc_type)
    end

  # override the rails attribute (getter)
  def secret
    Base64::decode64(self[:secret])
  end
 
  # override the rails attribute (setter)
  def secret=(value)
    self[:secret] = Base64::encode64(value)
  end


  end
end
