

load './SimpleHTML.rb'


def gen_main_page(out, cons)
  html = SimpleHTML.new out
  html.head "HTML StockOption"
  html.body {
    _p "HTML test page"
    _p "StockOption data for " + cons.month
    _hr
    _p "50ETF current price %.4f" % [cons.etf50.cur_price]
    _table('border=1') {
      put_table_head ['Sell 1', 'TimeV', 'Buy 1', 'TimeV',
                      'Exec Price',
                      'Buy 1', 'TimeV', 'Sell 1', 'TimeV']
      #_tr {
      #  _th 
      #}
      [cons.up, cons.down].transpose.each do |up, dn|
        fail if up.exe_price != dn.exe_price
        etf = cons.etf50
        intrinsic_value_up = etf.cur_price - up.exe_price
        intrinsic_value_up = 0.0 if intrinsic_value_up < 0
        intrinsic_value_dn = dn.exe_price - etf.cur_price
        intrinsic_value_dn = 0.0 if intrinsic_value_dn < 0
        _tr {
          _td '%.4f' % up.sell_price_1
	  _td '%.4f' % [up.sell_price_1 - intrinsic_value_up]
          _td '%.4f' % up.buy_price_1
	  _td '%.4f' % [up.buy_price_1 - intrinsic_value_up]
          _td '%.3f' % up.exe_price
          _td '%.4f' % dn.buy_price_1
	  _td '%.4f' % [dn.buy_price_1 - intrinsic_value_dn]
          _td '%.4f' % dn.sell_price_1
	  _td '%.4f' % [dn.sell_price_1 - intrinsic_value_dn]
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

