

load './SimpleHTML.rb'


def gen_main_page(out, cons)
  html = SimpleHTML.new out
  html.head "HTML StockOption"
  html.body {
    _p "HTML test page"
    _hr
    _table('border=1') {
      put_table_head ['Sell 1', 'Buy 1', 'Exec Price', 'Buy 1', 'Sell 1']
      #_tr {
      #  _th 
      #}
      [cons.up, cons.down].transpose.each do |up, dn|
        fail if up.exe_price != dn.exe_price
        _tr {
          _td up.sell_price_1
          _td up.buy_price_1
          _td up.exe_price
          _td dn.buy_price_1
          _td dn.sell_price_1
        }
      end
    }
    _hr
    _p "UP Contracts:"
    _table('border=1') {
      put_table_head ['Exec Price', 'Buy 1', 'Sell 1']
      cons.up.each{ |op|
        _tr {
          _td op.exe_price
          _td op.buy_price_1
          _td op.sell_price_1
        }
      }
    }
    _p "DOWN Contracts:"
    _table('border=1') {
      put_table_head ['Exec Price', 'Buy 1', 'Sell 1']
      cons.up.each{ |op|
        _tr {
          _td op.exe_price
          _td op.buy_price_1
          _td op.sell_price_1
        }
      }
    }
  }
  html.close
end

