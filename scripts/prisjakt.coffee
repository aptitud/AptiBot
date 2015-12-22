# Commands:
#   hubot /sök i prisjakt efter <produkt> - svarar med riktigt och specialpris

module.exports = (robot) ->
  robot.respond /sök i prisjakt efter (.*)/i, (res) ->
      prisjaktUrl = 'http://www.prisjakt.nu/ajax/server.php?class=Search_Supersearch&method=search&skip_login=1&modes=product,book,raw&limit=12&q='
      query = prisjaktUrl + res.match[1]
      res.send "Anropar Prisjakt (håll tummarna att inte deras api har förändrats)"
      res.http(query)
        .headers('Content-Type': 'application/json; charset=utf-8')
        .headers('User-Agent': 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36')
        .get() (err, result, body) ->
          json = JSON.parse body
          if err
            res.send "Encountered an error :( #{err}"
            return
          if result.statusCode == 200 && json.error == false
            i = 0
            items = json.message.product.items
            while i < items.length
              item = items[i]
              beforePrice = item.price.in_stock
              specialPrice = caclulateSpecialPrice beforePrice
              message = item.url + ' ' + item.name + ' ' + item.price.in_stock + 'kr vilket ger ' + specialPrice + 'kr i specialpris'  
              res.send message
              i++
            
            res.send ''
            res.send 'Disclaimer: should probably only be used in a laid-back way and together w/ the right people. Also, any defects cannot not be blamed on the developers. :)'
            return

  caclulateSpecialPrice = (beforePrice) ->
    price = parseFloat beforePrice
    vat = parseFloat 25
    tax = parseFloat 57
    actualprice = price * (price / (price + (price * (vat / 100)))) * ((100 - tax) / 100)
    return parseInt actualprice