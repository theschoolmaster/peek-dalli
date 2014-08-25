module Peek
  class DalliExpiresController < ApplicationController
    before_filter :restrict_non_access

    def expire
      @cache_key = CGI.unescape(params[:cache_key])

      # if you're using race_condition_ttl in you cache requests, just expire the key
      # if you're not and want the cache expired immediately, delete the cache object
      #cached_object = Rails.cache.read @cache_key
      #Rails.cache.delete @cache_key
      #success = Rails.cache.write @cache_key, cached_object, expires_in: 0.seconds, race_condition_ttl: 2.minutes
      #success = Rails.cache.expire @cache_key
      success = Rails.cache.delete @cache_key

      respond_to do |format|
        if success
          format.js { render 'success' }
        else
          format.js { render 'failure' }
        end
      end
    end

    private

    def restrict_non_access
      unless peek_enabled?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
