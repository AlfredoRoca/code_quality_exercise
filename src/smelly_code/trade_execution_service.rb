#
# This service provides an interface for order routing AND trade execution  
# using different avaiable Liquidity Providers (aka "LPs") using two different
# protocols: REST (http) and FIX (Financial Information eXchange) 
#
# execution_service = TradeExecutionService.new
# execution_service.execute_order(
#   'buy', 10000, 'USD', 'EUR',
#   '11/12/2018', '1.1345', 'X-A213FFL'
#   )
#

class TradeExecutionService
  include HTTParty
  
  LIQUIDITY_PROVIDER_A = "lpA"
  LIQUIDITY_PROVIDER_B = "lpB"
  LIQUIDITY_PROVIDER_C = "lpC"
    
  def initialize
    @connection = Redis.new(url: 'my_redis_host_url')
  end

  def execute_order(side, size, currency, counter_currency, date, price, order_id)
    amount = amount_in_usd(size, currency)

    if amount < 10_000.to_money(USD) 
      lp = LIQUIDITY_PROVIDER_C
    elsif (amount >= 10_000.to_money(USD) && amount < 100_000.to_money(USD))
      lp = LIQUIDITY_PROVIDER_B
    else
      lp = LIQUIDITY_PROVIDER_A
    end

    if lp == LIQUIDITY_PROVIDER_C
      issue_rest_market_trade(side, size, currency, counter_currency, date, price, order_id)
    else
      issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id, lp)
    end
  rescue
    File.open('path_to_log_file/errors.log', 'a') do |f|
      f.puts "Execution of #{order_id} failed."
    end
  end

  def issue_rest_market_trade(side, size, currency, counter_currency, date, price, order_id)
    payload = {        
      order_type: 'market',
      order_id: order_id, 
      side: side, 
      order_qty: size, 
      ccy1: currency,
      ccy2: counter_currency,
      value_date: date, 
      price: price
    }
    json_payload = JSON.dump(payload)
    response = self.class.post('http://lp_c_host/trade', body: json_payload).response
    if response.code.to_i == 200
      handle_rest_trade_confirmation(response)
    else
      raise 'REST order execution failed.'
    end
  end

  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id, lp)
    check_fix_service_status(lp)
    if lp == LIQUIDITY_PROVIDER_A
      send_to_redis(
        :lp_acme_provider_queue, 
        'fix:order:execute',
        clOrdID: order_id, 
        side: side, 
        orderQty: size, 
        ccy1: currency, 
        ccy2: counter_currency,
        value_date: date, 
        price: price
      )
    else 
      send_to_redis(
        :lp_wall_street_provider_queue, 
        'fix:executetrade',
        ordType: 'D',
        clOrdID: order_id, 
        side: side,
        orderQty: size,
        currency_1: currency,
        currency_2: counter_currency,
        futSettDate: date,
        price: price
      )
    end

    response = wait_for_fix_response(order_id, lp)
    handle_fix_trade_confirmation(response)
  end

  def send_to_redis(queue, command, payload = nil)
    redis_msg = payload == nil ? command : "#{command}::#{JSON.dump(payload)}" 
    @connection.rpush queue, redis_msg
  end

  def handle_rest_trade_confirmation(rest_trade_confirmation)
    # trade confirmation will be persisted in db
  end

  def handle_fix_trade_confirmation(fix_trade_confirmation)
    # trade confirmation will be persisted in db
  end

  def wait_for_fix_response(order_id, lp)
    # blocking read waiting for a redis key where trade confirmation is stored
  end

  def check_fix_service_status(lp)
    # it will throw an Exception if there is no connectivity with
    # this LP fix service  
  end

  def amount_in_usd(size, currency)
    # it would return a Money object representing a USD amount
  end
end