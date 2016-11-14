#!/bin/bash


## Requires pandoc for Word Doc generation.
## Requires pandoc and texlive (600+ MB) for PDF generation.
## sudo apt-get update
## sudo apt-get install pandoc
## sudo apt-get install texlive


## Company name requried as arguement to script
die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "Usage: ./create-docs <customer-name> <customer-address> <total-amount>"

# Define the markdown document to convert
markdoc="README.md"

# Define your company name here
companyname="Design Company Name, Co."

# Define company's Governing Law State
governingstate="California"

# Define your quote's default currency type
currencytype="USD"

# Define your invoice's default payment terms in days.
paymentdays="20"


# Define your invoice's overdue debt percentage rate
overduepercent="15"


# Define the markdown document to convert
markdoc="README.md"

# Use csplit to split README.md by the following hidden markup tag:
# [//]: # "begin_document_below"

csplit $markdoc '/^\[//]: # "begin_document_below"$/' '{*}' > /dev/null


# If split successfully, there will be 2 new files named xx00 and xx01.
# Check if file "xx01" exists. If not, there was an error splitting the markdown document.
if [ ! -e "xx01" ]; then
       echo "Error splitting $markdoc"
       exit 1
fi

# Remove first line from xx01, it is the line we split by.
tail -n +2 "xx01" > "xx01.tmp" && mv "xx01.tmp" "xx01"

# Escape variables before using in sed command
escape_companyname=$(printf '%s\n' "$companyname" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_currencytype=$(printf '%s\n' "$currencytype" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_paymentdays=$(printf '%s\n' "$paymentdays" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_overduepercent=$(printf '%s\n' "$overduepercent" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_governingstate=$(printf '%s\n' "$governingstate" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_customername=$(printf '%s\n' "$1" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_customeraddress=$(printf '%s\n' "$2" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
escape_totalamount=$(printf '%s\n' "$3" | sed 's:[\/&]:\\&:g;$!s/$/\\/')

# Format total amount with thousands seperator
format_totalamount="$(command printf "%'.f\n" $escape_totalamount)"

# Replace variables in the markdown
sed -i "s/company_name_here/$escape_companyname/g" xx01
sed -i "s/payment_number_days/$escape_paymentdays/g" xx01
sed -i "s/quote_currency_type/$escape_currencytype/g" xx01
sed -i "s/overdue_percentage/$escape_overduepercent/g" xx01
sed -i "s/governing_law_state/$escape_governingstate/g" xx01
sed -i "s/customer_name_here/$escape_customername/g" xx01
sed -i "s/customer_address_here/$escape_customeraddress/g" xx01
sed -i "s/total_amount_here/$format_totalamount/g" xx01

# Convert to DOC
pandoc xx01 -o Website-Design-Contract.docx

# Convert to PDF
pandoc xx01 -o Website-Design-Contract.pdf

# Cleanup
rm xx00 xx01


