class TradeIssuerFixService
  require 'redis'

  LIQUIDITY_PROVIDER_A = "lpA"
  LIQUIDITY_PROVIDER_B = "lpB"

  def initialize(lp)
    @lp = lp
    @connection = Redis.new(url: 'redis://0.0.0.0:6379')
  end
  
  def issuer
    case @lp
    when LIQUIDITY_PROVIDER_A
      LpATradeIssuerService
    when LIQUIDITY_PROVIDER_B
      LpBTradeIssuerService
    end
  end

  def issue(side, size, currency, counter_currency, date, price, order_id)
    issuer.issue(side, size, currency, counter_currency, date, price, order_id)
  end

  def check_fix_service_status(lp)
    # it will throw an Exception if there is no connectivity with
    # this LP fix service  
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
  end
end