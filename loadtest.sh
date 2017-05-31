/opt/redislabs/bin/memtier_benchmark \
  -s 10.136.4.5 -p 12000 \
  --hide-histogram --pipeline=10 \
  -c 12 -t 24 --key-maximum=3636363 \
  -n allkeys -d 1000 --key-pattern=P:P --ratio=1:0
