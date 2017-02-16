module Foreman::Controller::Parameters::SmartProxiesCommon
  extend ActiveSupport::Concern

  class_methods do
    def add_smart_proxies_common_params_filter(filter)
      filter.resource_class.registered_smart_proxies.keys.each do |proxy_url|
        filter.permit proxy_url, :"#{proxy_url}_id", :"#{proxy_url}_name"
      end
      filter
    end
  end
end
