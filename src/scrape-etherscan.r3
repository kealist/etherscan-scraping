Rebol[]

scrape-transactions-from-hash: func [hash] [
    url: to url! probe append copy https://etherscan.io/tx/0x hash

    sections: copy []
    detagged-sections: copy []

    transaction-page-rules: [

        some section
        to end


    ]

    section-start: "<hr class='hr-space'><div class='row'><div class='col-md-3 font-weight-bold font-weight-sm-normal mb-1 mb-md-0'>"

    section-end: {<hr class="hr-space">}

    section: [
        thru section-start

        copy sec to section-end

        (append sections sec)
    ]

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

    parse site  transaction-page-rules

    for-each section sections [

        parse section detag-rule
        append detagged-sections output
    ]
    probe detagged-sections

    parse site rules
]


scrape-transactions-from-hash "213b583e77066b0fa8f180b20bc31975a556fc306f161a5ce151d5b5fd9e4cc8"