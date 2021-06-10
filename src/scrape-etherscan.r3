Rebol[]
;save %text.html to-text/relax read https://etherscan.io/tx/0x213b583e77066b0fa8f180b20bc31975a556fc306f161a5cer51d5b5fd9

site: to-text/relax read https://etherscan.io/tx/0x213b583e77066b0fa8f180b20bc31975a556fc306f161a5cer51d5b5fd9

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

site: read %text.thml

parse site rules
