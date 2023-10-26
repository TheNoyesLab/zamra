for f in $1/*.group.tsv
do
        mkdir -p $2
        tr -d '\r' < $f | tr -d ',' > $2/$(basename "$f" .tsv)-fixed.tsv
done

python3 amr_long_to_wide.py -i $2/*.tsv -o $3
