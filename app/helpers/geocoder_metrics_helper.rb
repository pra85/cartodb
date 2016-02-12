# encoding: utf-8

require_relative '../../services/dataservices-metrics/lib/geocoder_usage_metrics'
require_relative '../../services/dataservices-metrics/lib/routing_usage_metrics'

module DataServicesMetricsHelper
  def get_user_geocoding_data(user, from, to)
    get_geocoding_data(user, from, to)
  end

  def get_organization_geocoding_data(organization, from, to)
    return if organization.owner.nil?
    get_geocoding_data(organization.owner, from, to)
  end

  def get_user_routing_data(user, from, to)
    get_routing_data(user, from, to)
  end

  def get_organization_routing_data(organization, from, to)
    return if organization.owner.nil?
    get_routing_data(organization.owner, from, to)
  end

  private

  def get_geocoding_data(user, from, to)
    orgname = user.organization.nil? ? nil : user.organization.name
    usage_metrics = CartoDB::GeocoderUsageMetrics.new(user.username, orgname)
    geocoder_key = user.google_maps_geocoder_enabled? ? :geocoder_google : :geocoder_here
    cache_hits = 0
    countable_requests = 0
    from.upto(to).each do |date|
      success = usage_metrics.get(geocoder_key, :success_responses, date)
      countable_requests += success unless success.nil?
      empty = usage_metrics.get(geocoder_key, :empty_responses, date)
      countable_requests += empty unless empty.nil?
      hit = usage_metrics.get(:geocoder_cache, :success_responses, date)
      cache_hits += hit unless hit.nil?
    end
    countable_requests + cache_hits
  end

  def get_routing_data(user, from, to)
    orgname = user.organization.nil? ? nil : user.organization.name
    usage_metrics = CartoDB::RoutingUsageMetrics.new(user.username, orgname)
    routing_key = :routing_here
    countable_requests = 0
    from.upto(to).each do |date|
      success = usage_metrics.get(routing_key, :success_responses, date)
      countable_requests += success unless success.nil?
      empty = usage_metrics.get(routing_key, :empty_responses, date)
      countable_requests += empty unless empty.nil?
    end
    countable_requests
  end

end
