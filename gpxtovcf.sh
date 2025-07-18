#!/bin/bash

if ! command -v gpsbabel 2>&1 >/dev/null; then
    echo "E: gpsbabel not found!"
    exit 0
fi

if [[ -n $1 ]]; then
echo "I: Starting..."

vcard_file=out.vcf
category=waze

if [[ -n $2 ]]; then
    route_name=$2
else
    route_name=ABRP
fi

temp_file_1=tf1.gpx
temp_file_2=tf2.csv

echo "   gpsbabel conversion..."
gpsbabel -i gpx -f $1 -x nuketypes,tracks,routes -o gpx -F $temp_file_1
gpsbabel -i gpx -f $temp_file_1 -o csv -F $temp_file_2

if [[ -f $vcard_file ]]; then
    rm $vcard_file
echo "   removing previous $vcard_file..."
fi

line_count=1

while IFS=, read -r lat lon name; do
    echo "   processing wpt $line_count..."

    echo "BEGIN:VCARD" >> $vcard_file
    echo "VERSION:3.0" >> $vcard_file
    echo "FN: $route_name $line_count" >> $vcard_file
    echo "N: $route_name $line_count;;;" >> $vcard_file
    echo "ORG: $route_name $line_count" >> $vcard_file
    echo "ADR: $lat,$lon" >> $vcard_file
    echo "CATEGORIES: $category" >> $vcard_file
    echo "END:VCARD" >> $vcard_file

    let "line_count=line_count+1"
done <$temp_file_2

echo "   cleaning up..."
rm $temp_file_1 $temp_file_2
echo "I: Finished."

else
    echo "Usage: gpxtovcf.sh infile.gpx"
fi
