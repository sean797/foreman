module BelongsToProxyUrls
  extend ActiveSupport::Concern
  module ClassMethods
    def belongs_to_proxy_url(name, options)
      register_smart_proxy_url(name, options)
    end

    def register_smart_proxy_url(name, options)
      self.registered_smart_proxies = registered_smart_proxies.merge(name => options)
      belongs_to name, :class_name => 'SmartProxyUrl'
    end
  end
end
