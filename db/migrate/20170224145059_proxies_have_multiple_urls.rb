class ProxiesHaveMultipleUrls < ActiveRecord::Migration
  def up
    create_table :smart_proxy_urls do |t|
      t.references :smart_proxy, :null => false
      t.string :url, :limit => 255
      t.boolean :primary, :default => false

      t.timestamps :null => true
    end
    SmartProxy.unscoped.each do |proxy|
      SmartProxyUrl.new(:smart_proxy_id => proxy.id, :url => proxy.read_attribute(:url), :primary => true).save
    end
    remove_column :smart_proxies, :url

    add_column :hosts, :puppet_ca_proxy_url_id, :integer
    add_column :hosts, :puppet_proxy_url_id, :integer
    Host.unscoped.each do |host|
      if host.read_attribute(:puppet_ca_proxy_id)
        host.puppet_ca_proxy_url_id = SmartProxyUrl.unscoped.where(:smart_proxy_id => host.read_attribute(:puppet_ca_proxy_id), :primary => true).first.id
      end
      if host.read_attribute(:puppet_proxy_id)
        host.puppet_proxy_url_id = SmartProxyUrl.unscoped.where(:smart_proxy_id => host.read_attribute(:puppet_proxy_id), :primary => true).first.id
      end
      host.save
    end
    remove_column :hosts, :puppet_ca_proxy_id
    remove_column :hosts, :puppet_proxy_id

    add_column :hostgroups, :puppet_ca_proxy_url_id, :integer
    add_column :hostgroups, :puppet_proxy_url_id, :integer
    Hostgroup.unscoped.each do |group|
      if group.read_attribute(:puppet_ca_proxy_id)
        group.puppet_ca_proxy_url_id = SmartProxyUrl.where(:smart_proxy_id => group.read_attribute(:puppet_ca_proxy_id), :primary => true).first.id
      end
      if group.read_attribute(:puppet_proxy_id)
        group.puppet_proxy_url_id = SmartProxyUrl.where(:smart_proxy_id => group.read_attribute(:puppet_proxy_id), :primary => true).first.id
      end
      group.save
    end
    remove_column :hostgroups, :puppet_ca_proxy_id
    remove_column :hostgroups, :puppet_proxy_id

    add_foreign_key "hostgroups", "smart_proxy_urls", :name => "hostgroups_puppet_ca_proxy_url_id_fk", :column => "puppet_ca_proxy_url_id"
    add_foreign_key "hostgroups", "smart_proxy_urls", :name => "hostgroups_puppet_proxy_url_id_fk", :column => "puppet_proxy_url_id"
    add_foreign_key "hosts", "smart_proxy_urls", :name => "hosts_puppet_ca_proxy_url_id_fk", :column => "puppet_ca_proxy_url_id"
    add_foreign_key "hosts", "smart_proxy_urls", :name => "hosts_puppet_proxy_url_id_fk", :column => "puppet_proxy_url_id"
  end

  def down
    add_column :hosts, :puppet_ca_proxy_id, :integer
    add_column :hosts, :puppet_proxy_id, :integer
    Host.unscoped.each do |host|
      if host.puppet_ca_proxy_url_id
        host.puppet_ca_proxy_id = SmartProxyUrl.unscoped.where(:id => host.puppet_ca_proxy_url_id).first.smart_proxy_id
      end
      if host.puppet_proxy_url_id
        host.puppet_proxy_id = SmartProxyUrl.unscoped.where(:id => host.puppet_proxy_url_id).first.smart_proxy_id
      end
      host.save!(:validate => false)
    end
    remove_column :hosts, :puppet_ca_proxy_url_id
    remove_column :hosts, :puppet_proxy_url_id

    add_column :hostgroups, :puppet_ca_proxy_id, :integer
    add_column :hostgroups, :puppet_proxy_id, :integer
    Hostgroup.unscoped.each do |group|
      if group.puppet_ca_proxy_url_id
        group.puppet_ca_proxy_id = SmartProxyUrl.unscoped.where(:id => group.puppet_ca_proxy_url_id).first.smart_proxy_id
      end
      if group.puppet_proxy_url_id
        group.puppet_proxy_id = SmartProxyUrl.unscoped.where(:id => group.puppet_proxy_url_id).first.smart_proxy_id
      end
      group.save!(:validate => false)
    end
    remove_column :hostgroups, :puppet_ca_proxy_url_id
    remove_column :hostgroups, :puppet_proxy_url_id

    add_column :smart_proxies, :url, :string
    SmartProxy.reset_column_information
    SmartProxyUrl.unscoped.each do |url|
      if url.primary?
        sm = SmartProxy.unscoped.where(:id => url.smart_proxy_id).first
        sm.url = url.url
        sm.save
      end
    end
    drop_table :smart_proxy_urls

    add_foreign_key "hostgroups", "smart_proxies", :name => "hostgroups_puppet_ca_proxy_id_fk", :column => "puppet_ca_proxy_id"
    add_foreign_key "hostgroups", "smart_proxies", :name => "hostgroups_puppet_proxy_id_fk", :column => "puppet_proxy_id"
    add_foreign_key "hosts", "smart_proxies", :name => "hosts_puppet_ca_proxy_id_fk", :column => "puppet_ca_proxy_id"
    add_foreign_key "hosts", "smart_proxies", :name => "hosts_puppet_proxy_id_fk", :column => "puppet_proxy_id"
  end
end
