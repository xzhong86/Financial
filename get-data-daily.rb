#!/usr/bin/env ruby

require 'yaml'

$bin_dir = File.expand_path('..', __FILE__)

load $bin_dir + '/StockOption.rb'

def save_con_datas(file)
  if File.exists? file
    puts "file #{file} exists. exit!"
    return
  end
  xlso = XLStockOptionInfo.new
  datas = xlso.avail_month.map do |month|
    cons = xlso.getMonthContracts(month)
    cons.up = xlso.getContractDetail(cons.up)
    cons.down = xlso.getContractDetail(cons.down)
    cons.to_h
  end
  puts "save contracts data into \"#{file}\""
  File.open(file, 'w').write(YAML.dump(datas))
end

def save_stock_datas(file)
  if File.exists? file
    puts "file #{file} exists. exit!"
    return
  end
  hq = HQSinaIntf.new
  stocks  = %w[ sh000001 sh510050 sz399001 sz399005 sz399006 ]
  stocks += %w[ sz300315 sz001696 sz300223 sh600016 sh600036 ]
  datas = hq.getStockInfo(stocks)
  hdata = [ stocks, datas ].transpose.to_h
  puts "save stocks data into \"#{file}\""
  File.open(file, 'w').write(YAML.dump(hdata))
end

# main

dir = '/home/zpzhong/work/financial/data/daily/'
#dir = 'data/daily/'
file = dir + Time.new.strftime("stock_option_%Y-%m-%d_%H.yaml")
save_con_datas(file)

file = dir + Time.new.strftime("stock_data_%Y-%m-%d_%H.yaml")
save_stock_datas(file)

