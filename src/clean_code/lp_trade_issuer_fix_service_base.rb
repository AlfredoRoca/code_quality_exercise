require 'redis'
require_relative './errors.rb'

class LpTradeIssuerFixServiceBase
  def initialize()
    @connection = Redis.new(url: 'redis://0.0.0.0:6379')
  end

  def issue(**params)
    return InvalidParamsError if ParametersValidationService.new(params).invalid?

    issue_fix_market_trade(params)
  end

  def issue_fix_market_trade(**params)
    raise 'Not implemented'
  end

  def redis_health_check_ok?
    @connection.ping
    true
  rescue => error
    false
  end

  def wait_for_fix_response(order_id, lp)
    # blocking read waiting for a redis key where trade confirmation is stored
  end

  def handle_fix_trade_confirmation(fix_trade_confirmation)
    # trade confirmation will be persisted in db
  end

  def send_to_redis(queue, command, payload = nil)
    redis_msg = payload == nil ? command : "#{command}::#{JSON.dump(payload)}"
    @connection.rpush queue, redis_msg

  rescue => error
    raise RedisConnectionDown
  end
end
