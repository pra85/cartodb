# encoding: utf-8

require 'active_support/time'

module CartoDB
  # The purpose of this class is to encapsulate storage of usage metrics.
  # This shall be used for billing, quota checking and metrics.
  class RoutingUsageMetrics

    VALID_METRICS = [
      :total_requests,
      :failed_responses,
      :success_responses,
      :empty_responses,
      :isolines_generated
    ]

    VALID_SERVICES = [
      :routing_here
    ]

    def initialize(redis, username, orgname = nil)
      @username = username
      @orgname = orgname
      @redis = redis
    end

    def incr(service, metric, amount = 1, date = DateTime.current)
      check_valid_data(service, metric, amount)
      return if amount == 0

      # TODO We could add EXPIRE command to add TTL to the keys
      if !@orgname.nil?
        @redis.zincrby("#{org_key_prefix(service, metric, date)}", amount, "#{date_day(date)}")
      end

      @redis.zincrby("#{user_key_prefix(service, metric, date)}", amount, "#{date_day(date)}")
    end

    def get(service, metric, date = DateTime.current)
      check_valid_data(service, metric)

      if !@orgname.nil?
        @redis.zscore("#{org_key_prefix(service, metric, date)}", "#{date_day(date)}")
      else
        @redis.zscore("#{user_key_prefix(service, metric, date)}", "#{date_day(date)}")
      end
    end

    private

    def check_valid_data(service, metric, amount = 0)
      raise ArgumentError.new('Invalid service') unless VALID_SERVICES.include?(service)
      raise ArgumentError.new('Invalid metric') unless VALID_METRICS.include?(metric)
      raise ArgumentError.new('Invalid routing metric amount') if !amount.nil? and amount < 0
    end

    def user_key_prefix(service, metric, date)
      "user:#{@username}:#{service}:#{metric}:#{date_year_month(date)}"
    end

    def org_key_prefix(service, metric, date)
      "org:#{@orgname}:#{service}:#{metric}:#{date_year_month(date)}"
    end

    def date_day(date)
      date.strftime('%d')
    end

    def date_year_month(date)
      date.strftime('%Y%m')
    end

  end
end
