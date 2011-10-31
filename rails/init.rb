yml = YAML.load(IO.read(File.join(RAILS_ROOT, "config", "memcached.yml")))
memcache_config = yml[RAILS_ENV]
memcache_config.symbolize_keys! if memcache_config.respond_to?(:symbolize_keys!)

if defined?(DISABLE_CACHE_MONEY) || ENV['DISABLE_CACHE_MONEY'] == 'true' || memcache_config.nil? || memcache_config[:cache_money] != true
  Rails.logger.info 'cache-money disabled'
  class ActiveRecord::Base
    def self.index(*args)
    end
  end
else
  Rails.logger.info 'cache-money enabled'
  require 'cache_money'

  memcache_config[:logger] = Rails.logger
  memcache_servers =
    case memcache_config[:servers].class.to_s
      when "String"; memcache_config[:servers].gsub(' ', '').split(',')
      when "Array"; memcache_config[:servers]
    end
  $memcache = MemcachedWrapper.new(memcache_servers, memcache_config)

  #ActionController::Base.cache_store = :cache_money_mem_cache_store
  ActionController::Base.session_options[:cache] = $memcache if memcache_config[:sessions]
  #silence_warnings {
  #  Object.const_set "RAILS_CACHE", ActiveSupport::Cache.lookup_store(:cache_money_mem_cache_store)
  #}

  $local = Cash::Local.new($memcache)
  $lock  = Cash::Lock.new($memcache)
  $cache = Cash::Transactional.new($local, $lock)

  # allow setting up caching on a per-model basis
  unless memcache_config[:automatic_caching].to_s == 'false'
    Rails.logger.info "cache-money: global model caching enabled"
    class ActiveRecord::Base
      is_cached(:repository => $cache)
    end
  end
end
