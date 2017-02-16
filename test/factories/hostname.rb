FactoryBot.define do
  factory :hostname do
    sequence(:name) {|n| "SmartProxyPool Name #{n}" }
    sequence(:hostname) {|n| "someurl#{n}.net" }

    trait :with_puppet do
      smart_proxies { [FactoryBot.build(:puppet_and_ca_smart_proxy)] }
    end
  end
end
