#!/usr/bin/env ruby

require 'webrick'
require 'stringio'

load './StockOption.rb'
load './main-page.rb'

root = File.expand_path '.'
server = WEBrick::HTTPServer.new :Port => 8180, :DocumentRoot => root

trap 'INT' do server.shutdown end


server.mount_proc '/' do |req, res|
  cons = getContractsThisMonth()
  out = StringIO.new
  cons.up.map!{ |c| structuringHashData(c) }
  cons.down.map!{ |c| structuringHashData(c) }
  cons.etf50 = structuringHashData(cons.etf50)
  gen_main_page(out, cons)
  res.body = out.string
end

server.start

