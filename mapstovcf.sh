#!/bin/bash
#
# script to convert a Google Maps directions url
# to vCard entries for each waypoint so they can
# be used in Waze
#

if ! [[ -n $1 ]]; then
    echo "Usage: mapstovcf.sh map_url"
    echo "       mapstovcf.sh map_url entry_name"
    echo "       mapstovcf.sh map_url entry_name label_name"
    exit 0
fi

echo "I: Starting conversion..."

vcard_file=out.vcf
category=waze

if [[ -n $2 ]]; then
    route_name="$2"
else
    route_name="ABRP"
fi

if [[ -n $3 ]]; then
    category="$3"
else
    category="waze"
fi

temp_file_1=tf1.txt


if [[ -f $1 ]]; then
    cp $1 $temp_file_1
else
    echo "$1" > $temp_file_1
fi

sed -i 's/\/@.*$//' $temp_file_1

if grep -q "entry" $temp_file_1; then
    echo "E: sed error, aborting."
    exit 1
fi

sed -i 's/.*dir\///' $temp_file_1

if grep -q "http" $temp_file_1; then
    echo "E: sed error, aborting."
    exit 1
fi

if [[ -f $vcard_file ]]; then
    rm $vcard_file
echo "   removing previous $vcard_file..."
fi

line_count=1

IFS='/'

coords=`cat $temp_file_1`
read -ra coordvar <<< "$coords"

for i in "${coordvar[@]}"; do

    echo "BEGIN:VCARD" >> $vcard_file
    echo "VERSION:3.0" >> $vcard_file
    printf "FN: $route_name %02d\n" $line_count >> $vcard_file
    printf "N: $route_name %02d;;;\n" $line_count >> $vcard_file
    printf "ORG: $route_name %02d\n" $line_count >> $vcard_file
    echo "ADR: $i" >> $vcard_file
    echo "CATEGORIES: $category" >> $vcard_file
    echo "END:VCARD" >> $vcard_file

    let "line_count=line_count+1"
done

IFS=' '

echo "   cleaning up..."
rm $temp_file_1
echo "I: Finished."
