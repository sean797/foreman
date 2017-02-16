class SmartProxyPoolsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::SmartProxyPool

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @hostnames = resource_base_search_and_page
  end

  def new
    @hostname = SmartProxyPool.new
  end

  def create
    @hostname = SmartProxyPool.new(hostname_params)
    if @hostname.save
      process_success :object => @hostname
    else
      process_error :object => @hostname
    end
  end

  def edit
  end

  def update
    if @hostname.update_attributes(hostname_params)
      process_success :object => @hostname
    else
      process_error :object => @hostname
    end
  end

  def destroy
    if @hostname.destroy
      process_success :object => @hostname, :success_redirect => hostnames_path
    else
      process_error :object => @hostname
    end
  end
end
