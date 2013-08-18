#!/bin/sh

# Warning: Do not run on production server -- may kill your existing mongod

set -e
set -x

n_shards=8

mongos_port=37017
standalone_port=47017

function on_error() {
  echo "Cleaning up..."
  set +e
  killall -9 mongos
  killall -9 mongod
  rm -rf mongolab
}

trap 'on_error' ERR

mkdir mongolab

mkdir mongolab/config1
mkdir mongolab/config2
mkdir mongolab/config3

echo "Starting config servers..."

mongod --configsvr --dbpath mongolab/config1 --logpath mongolab/config1/mongo.log --port 31001 -v --nojournal &
mongod --configsvr --dbpath mongolab/config2 --logpath mongolab/config2/mongo.log --port 31002 -v --nojournal &
mongod --configsvr --dbpath mongolab/config3 --logpath mongolab/config3/mongo.log --port 31003 -v --nojournal &

sleep 3

echo "Starting mongos..."

mongos --configdb localhost:31001,localhost:31002,localhost:31003 --logpath mongolab/mongos.log --port $mongos_port &

sleep 3

mkdir mongolab/db
mongod --dbpath mongolab/db --logpath mongolab/db/mongo.log --port $standalone_port -v --nojournal &

echo "Starting shards..."

for i in $(seq 1 $n_shards)
do
  mkdir mongolab/sh$i
  mongod --dbpath mongolab/sh$i --logpath mongolab/sh$i/mongo.log --port 3500$i -v --nojournal &
done

sleep 5

echo "Adding shards..."

for i in $(seq 1 $n_shards)
do
  mongo --host localhost --port $mongos_port --eval "sh.addShard('localhost:3500$i')"
done

mongo localhost:$mongos_port/shard_test --eval 'db.dropDatabase()'
mongo localhost:$mongos_port/shard_test --eval 'sh.enableSharding("shard_test")'
mongo localhost:$mongos_port/shard_test --eval "sh.shardCollection('shard_test.foos', {_id: 'hashed'})"
mongo localhost:$mongos_port/shard_test --eval "sh.shardCollection('shard_test.rnd_foos', {rnd: 1})"

increment=$(echo "scale = 4; 1 / ($n_shards + 1)" | bc)

for i in $(seq 1 $n_shards)
do
  split=$(echo "scale = 4; $increment * $i" | bc)
  mongo localhost:$mongos_port/admin --eval "db.runCommand({ split: 'shard_test.rnd_foos', middle: { rnd: $split } })"
done

mongo localhost:$mongos_port/shard_test --eval 'sh.status()'
