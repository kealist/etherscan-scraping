Rebol[]

scrape-transactions-from-hash: func [hash] [
    url: to url! probe append copy https://etherscan.io/tx/0x hash



    rules: [
        some [ 
            thru "<b>From</b>" 
            thru "title='" 
            copy sender to "'" 
            
            thru "<b>To</b>"
            thru "title='" 
            copy receiver to "'" 

            thru "<b>For</b>"
            thru "<span"
            thru ">" thru ">"
            copy amount to "<"
            (print spaced ["From" to text! sender "TO" to text! receiver "AMOUNT" to text! amount ])
        ]
        to end
    ]

    site: to-text/relax read url

    parse site rules


]


scrape-transactions-from-hash "213b583e77066b0fa8f180b20bc31975a556fc306f161a5ce151d5b5fd9e4cc8"