#!/usr/bin/env ruby

require 'open-uri'
require 'json'

class DataAccesser
  attr_reader :data
  def initialize(data)
    @data = data
  end
  def get(path, sep='.')
    data = @data
    path.split(sep).each { |m| data = data[m] }
    data
  end
end

class DateInfo
  attr_reader :year, :month
  def initialize(str)
    if str =~ /(\d{4})-(\d\d)/
      @year = $1.to_i
      @month = $2.to_i
    else
      fail "unknown format: #{str}"
    end
  end
end

class HQSinaIntf
  def initialize()
    @url_pfx = 'http://hq.sinajs.cn/list='
    build_contract_title
    build_stock_title
  end
  def getVarText(codes)
    list = []
    code = codes.kind_of?(Array) ? codes.join(',') : codes
    open(@url_pfx + code).each do |line|
      if line =~ /var\s+(\w+)="(.*)"/
        list << [ $1, $2 ]
      else
        fail "Bad string: #{line}"
      end
    end
    list
  end
  def getList(code)
    vars = getVarText(code)
    vars.first[1].split(',')
  end
  def getInfo(codes, title)
    getVarText(codes).map do |v, t|
      h = [title, t.split(',')].transpose.to_h
      h['js_var_name'] = v
      h
    end
  end
  def build_contract_title
     title = %w[ res0 res1 price res3 res4 hold_num gain
                exe_price yesterday_price start_price upper_limit lower_limit ]
    5.downto(1) { |i|
      title << 'sell_price_' + i.to_s
      title << 'sell_num_' + i.to_s
    }
    1.upto(5) { |i|
      title << 'buy_price_' + i.to_s
      title << 'buy_num_' + i.to_s
    }
    title += %w[ time is_major res32 res33 stock cname amplitude
                 highest_price lowest_price deal_num turnover res41 ]
    @con_op_title = title
  end
  def getContractInfo(codes)
    codes.each do |code|
      fail "Bad code: #{code}" if code !~ /^CON_OP_/
    end
    getInfo(codes, @con_op_title)
  end
  def build_stock_title
    title = %w[ name start_price yesterday_price cur_price highest_price lowest_price
                buy_1_price sell_1_price deal_num turnover ]
    1.upto(5) { |i|
      title << 'buy_price_' + i.to_s
      title << 'buy_num_' + i.to_s
    }
    1.upto(5) { |i|
      title << 'sell_price_' + i.to_s
      title << 'sell_num_' + i.to_s
    }
    title += %w[ date time res32 ]
    @stock_info_title = title
  end
  def getStockInfo(codes)
    getInfo(codes, @stock_info_title)
  end
end

class XLStockOptionInfo
  attr_reader :avail_month
  def initialize()
    stockinfo_url = 'http://stock.finance.sina.com.cn/futures/api/openapi.php/StockOptionService.getStockName'
    js = JSON.load(open(stockinfo_url))
    res = DataAccesser.new(js).get('result.data.contractMonth')
    @avail_month = res.uniq.map{|s| DateInfo.new(s) }
    @hq = HQSinaIntf.new
  end
  def getMonthContracts(date)
    mon = date.year % 100 * 100 + date.month
    cons = OpenStruct.new
    cons.up   = @hq.getList("OP_UP_510050" + mon.to_s)
    cons.down = @hq.getList("OP_DOWN_510050" + mon.to_s)
    cons.month = "%d-%02d" % [date.year, date.month]
    cons
  end
  def getContractDetail(codes)
    @hq.getContractInfo(codes)
  end
end

def getContractsThisMonth()
  xlso = XLStockOptionInfo.new
  cons = xlso.getMonthContracts(xlso.avail_month.first)
  cons.up = xlso.getContractDetail(cons.up)
  cons.down = xlso.getContractDetail(cons.down)
  cons
end

# main
if $0 == __FILE__
  xlso = XLStockOptionInfo.new
  cons = xlso.getMonthContracts(xlso.avail_month.first)
  
  puts "UP contracts:"
  xlso.getContractDetail(cons.up).each do |op|
    puts "#{op.exe_price} #{op.buy_price_1} #{op.sell_price_1}"
  end
  
  puts "DOWN contracts:"
  xlso.getContractDetail(cons.down).each do |op|
    puts "#{op.exe_price} #{op.buy_price_1} #{op.sell_price_1}"
  end
end

