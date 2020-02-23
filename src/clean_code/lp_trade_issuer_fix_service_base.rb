require 'json'
require 'redis'
require_relative './errors.rb'

class LpTradeIssuerFixServiceBase
  def initialize
    @connection = Redis.new(url: 'redis://0.0.0.0:6379')
  end

  def issue(**params)
    return InvalidParamsError if ParametersValidationService.new(params).invalid?

    issue_fix_market_trade(params)
  end

  def issue_fix_market_trade(**params)
    raise 'Not implemented'
  end

  def wait_for_fix_response(order_id, lp)
    # blocking read waiting for a redis key where trade confirmation is stored
  end

  def wait_for_issuer_health_check(lp)
    # blocking read waiting for a redis key where issuer status is stored
    # it should be fast!
  end

  def handle_fix_trade_confirmation(fix_trade_confirmation)
    # trade confirmation will be persisted in db
    if fix_trade_confirmation[:success]
      { success: true, error: nil }
    else
      { success: false, error: TradeExecutionError }
    end
  end

  def send_to_redis(queue, command, payload = nil)
    redis_msg = payload == nil ? command : "#{command}::#{JSON.dump(payload)}"
    @connection.rpush queue, redis_msg

  rescue => error
    raise RedisConnectionDown
  end

  def fix_service_health_check_ok?(lp)
    redis_health_check_ok? && is_fix_service_alive?(lp)
  end

  def redis_health_check_ok?
    @connection.ping
    true
  rescue => error
    false
  end

  def is_fix_service_alive?(lp)
    send_to_redis(
      :health_check,
      'fix:health_check',
      {lp: lp}
    )

    response = wait_for_issuer_health_check(lp)
    response[:status] == 'ok'
  end
end
