#!/usr/bin/env ruby

require 'yaml'

$bin_dir = File.expand_path('..', __FILE__)

load $bin_dir + '/StockOption.rb'

def save_datas(file)
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

# main

dir = '/home/zpzhong/work/financial/data/daily/'
#dir = 'data/daily/'
file = dir + Time.new.strftime("stock_option_%Y-%m-%d_%H.yaml")
save_datas(file)

