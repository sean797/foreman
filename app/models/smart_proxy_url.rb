class SmartProxyUrl < ActiveRecord::Base
  belongs_to :smart_proxy, :class_name => 'SmartProxy'

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, [:puppet_ca_hosts, :hosts], [:puppet_ca_hostgroups, :hostgroups])

  has_many_hosts                                              :foreign_key => 'puppet_proxy_url_id'
  has_many :hostgroups,                                       :foreign_key => 'puppet_proxy_url_id'
  has_many :puppet_ca_hosts, :class_name => 'Host::Managed',  :foreign_key => 'puppet_ca_proxy_url_id'
  has_many :puppet_ca_hostgroups, :class_name => 'Hostgroup', :foreign_key => 'puppet_ca_proxy_url_id'

  validates :url, :length => {:maximum => 255}, :presence => true, :url_schema => ['http', 'https']
  validates_uniqueness_of :smart_proxy_id, :scope => :url
  validates_uniqueness_of :smart_proxy_id, :scope => :primary, if: :primary?

  before_save :sanitize_url

  attr_name :url

  def to_label
    return url
  end

  def self.for_select(feature)
    SmartProxy.with_features(feature).map do |proxy|
      [proxy.name, proxy.urls.map { |u| [u.url, u.id] }]
    end
  end

  def hostname
    URI(url).host
  end

  private

  def sanitize_url
    self.url = url.chomp('/') unless url.empty?
  end
end
