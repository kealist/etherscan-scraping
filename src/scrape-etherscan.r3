Rebol[]


input: to-text/relax read %"Working Radar Fund.csv"

input-lines: split input newline


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




for-each line input-lines [
    

    items: split-csv-line line

    probe items

]


tx-map: make map! [
    
]


scrape-transactions-from-hash: func [hash] [
    url: to url! probe append copy https://etherscan.io/tx/ hash
    transactions: copy []
    sections: copy []
    detagged-sections: copy []
    transaction-strings: copy []
    transaction-page-rules: [
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
            thru "Estimated Value on Day of Transfer'"
            thru "value='"
            copy amount to "'"
            |
            thru "<b>For</b>"
            thru "<span"
            thru ">"
            copy amount to "<"
        ]
        (replace/all amount complement charset [{$.} #"a" - #"z" #"0" - #"9"] {})
        (parse sender address-rule)
        (sender: address)
        (parse receiver address-rule)
        (receiver: address)

        (append transactions compose [(hash) (to text! sender) (to text! receiver) (to text! amount) ])
        to end
    ]


    address-rule: [
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

    parse site  transaction-page-rules

    for-each section sections [
        parse section section-to-transaction-rule
    ]

    for-each transaction-string transaction-strings [
        parse transaction-string transaction-rule
    ]

    return transactions
]


trans: scrape-transactions-from-hash "0x213b583e77066b0fa8f180b20bc31975a556fc306f161a5ce151d5b5fd9e4cc8"

csv-data: "TxHash,To,From,Amount"
append csv-data newline

for-each [hash from to amount] trans [
    append csv-data unspaced reduce [hash "," from "," to "," amount newline]
]

save %transactions.csv csv-data