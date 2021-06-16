Rebol[]


input: to-text/relax read %"Working Radar Fund.csv"

input-f2: to-text/relax read %"Working Radar Fund - F2.csv"

input-lines: split input newline

input-f2-lines: split input-f2 newline

split-csv-line: func [line] [
    elements: copy []
    csv-line-rule: [
        some [
            [
                {"}
                copy element to {"}
                {"}
                thru ","
                (append elements element)
            ]
            |
            [
                copy element to ","
                thru ","
                (append elements element)
            ]
        ]
        to end
    ]

    parse line csv-line-rule
    return elements
]


tx-values: copy make map! [
    
]

either exists? %tx-map.r3 [
    do load %tx-map.r3
] [
    tx-map: make map! []
]

for-each line input-f2-lines [
    
    items: split-csv-line line
    if all [not empty? items not null? items/20 ] [
       print items/20
       tx-values/(items/20): ""
    ]
;    print unspaced ["Amount: " items/3 ", TxHash: " items/15]

]

index: 0

;; problem hashes:

;; 0xcdfb55f846a243a969d6734841bf22716e8faac501df49e7a2473f08d1761a92



;scrape-transactions-from-hash "0xfd1b810dbf898e28447c19e56facdb4417d1baea79c8b71642bda399fffac297"
; save %prob.html to-text/relax read https://etherscan.io/tx/0xfd1b810dbf898e28447c19e56facdb4417d1baea79c8b71642bda399fffac297


scrape-transactions-from-hash: func [hash] [
    url: to url! probe append copy https://etherscan.io/tx/ hash
    transactions: copy []
    sections: copy []
    detagged-sections: copy []
    transaction-strings: copy []

    single-transaction-page-rule: [
        from-section-rule
        to-section-rule
        value-section-rule

        (replace/all usd-amount complement charset [{$.,} #"a" - #"z" #"0" - #"9"] {})
        (parse sender address-rule)
        (sender: address)
        (parse receiver address-rule)
        (receiver: address)
        (print compose [(hash) (to text! sender) (to text! receiver) (to text! token-amount)  (to text! usd-amount) ])
        (append transactions compose [(hash) (to text! sender) (to text! receiver) (to text! token-amount)  (to text! usd-amount) ])
        to end
    ]

    to-section-rule: [
        thru "</i>To:</div>"
        thru "<a"
        thru ">"
        copy receiver to "<"
    ]

    from-section-rule: [

        thru "</i>From:</div>"
        thru "<span"
        thru ">"
        copy sender to "<"
    ]

    value-section-rule: [
        (usd-amount: "" token-amount: "")
        thru "</i>Value:</div"

            [
                thru "The amount of ETH to be transferred to the recipient with the transaction'>"
                copy token-amount to "</span"
            
        ;|
        ;    [
        ;        thru "<span"
        ;        thru "<span"
        ;        thru "<span"
        ;        thru ">"
        ;        copy token-amount to "</span"
                (if (find token-amount "<") [ 
                    parse token-amount detag-rule

                    token-amount: output
                    token-amount: replace/all token-amount " " ""
                    token-amount: replace/all token-amount "ether" ""
                    token-amount: replace/all token-amount "Ether" ""
                ])
                thru "</span>"
            ]
        [  
            thru {LitOldPrice = "(}
            copy usd-amount to ")"
        ]

        |
        [
            copy usd-amount to "<"

        ]
        
    ]

    multiple-transaction-page-rules: [
        some section
        to end
    ]

    ;; the transaction section starts with this HTML
    section-start: {<hr class='hr-space'><div class='row'><div class='col-md-3 font-weight-bold font-weight-sm-normal mb-1 mb-md-0'>}

    ;; the transaction section ends with this HTML
    section-end: {<hr class="hr-space">}

    section: [

        thru section-start

        copy sec thru section-end

        (append sections sec)
    ]


    ;removes all tags
    detag-rule: [
        (output: copy "")
        some [
            copy text to "<"
            (append output text  append output " ")
            thru ">"
        ]
        copy text to end
        (append output text)
    ]

    section-to-transaction-rule: [
        some [
            thru "<b>From</b>"
            [

                copy transaction to "<b>From</b>" 
                (append transaction-strings transaction)
                |
                copy transaction to section-end 
                (append transaction-strings transaction)
            ]

        ]
        to end
    ]

    transaction-rule:
    [
        thru "title='" 
        copy sender to "'" 
        
        thru "<b>To</b>"
        thru "title='" 
        copy receiver to "'" 
        [
            thru "<b>For</b>"
            thru "<span"

            thru "<span"
            thru ">"
            copy token-amount to "<"
            thru "Estimated Value on Day of Transfer'"
            thru "value='"
            copy usd-amount to "'"
            |
            thru "<b>For</b>"
            thru "<span"
            thru ">"
            copy token-amount to "<"
            (usd-amount: "n/a")
        ]
        (replace/all usd-amount complement charset [{$.,} #"a" - #"z" #"0" - #"9"] {})
        (parse sender address-rule)
        (sender: address)
        (parse receiver address-rule)
        (receiver: address)
        (print compose [(hash) (to text! sender) (to text! receiver) (to text! token-amount)  (to text! usd-amount) ])
        (append transactions compose [(hash) (to text! sender) (to text! receiver) (to text! token-amount)  (to text! usd-amount) ])
        to end
    ]


    address-rule: [
    [
        copy name to "("
        "("
        copy other-name to ")"
        ")"
        thru "("
        copy address to ")"
        to end
        ]
        |

        [
        copy name to "("
        "("
        copy address to ")"
        to end
        ]
        |
        copy address to end
    ]

    site: to-text/relax read url

    save %test.html site

    parse site multiple-transaction-page-rules

    for-each section sections [
        parse section section-to-transaction-rule
    ]

    for-each transaction-string transaction-strings [
        parse transaction-string transaction-rule
    ]

    if (length-of transactions) = 0 [
        parse site single-transaction-page-rule
    ]

    return transactions
]



for-each [hash empty] tx-values [
    print unspaced ["Scraping Progress: " index " of " length-of tx-values " hash: " hash " empty: " empty]
    

    if (not hash = "Txhash")  [


        if tx-map/(hash) == null or ((length-of tx-map/(hash)) = 0) [
            trans: scrape-transactions-from-hash hash


            tx-map/(hash): trans
            
            wait 10 
        ]
    ]

    index: index + 1
]



save %tx-map.r3 compose [tx-map: (tx-map)]

csv-data: "TxHash,To,From,TokenAmount,UsdAmount"
append csv-data newline

for-each [hash trans] tx-map [
    if trans == [] [

        append csv-data unspaced reduce [hash ", CHECK , CHECK, CHECK, CHECK" newline]
    ]
    for-each [hash from to token-amount usd-amount] trans [
        replace token-amount "Ether" ""
        replace token-amount "ether" ""
        append csv-data unspaced reduce [hash "," from "," to {,"} token-amount {","} usd-amount {"} newline]
    ]
]

save %transactions.csv csv-data