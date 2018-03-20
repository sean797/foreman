FactoryBot.define do
  factory :smart_proxy_pool do
    sequence(:name) {|n| "SmartProxyPool Name #{n}" }
    sequence(:hostname) {|n| "someurl#{n}.net" }

    trait :with_puppet do
      smart_proxies { [FactoryBot.build(:puppet_and_ca_smart_proxy)] }
    end
  end
end
