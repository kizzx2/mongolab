# mongolab

Example source code for the blog post "Slow batch insert with MongoDB sharding"

## Usage

    sh mongolab.sh

    # Default settings -- verify that sharding+batch insert is slow
    mongo localhost:37017/shard_test test.js

    # Default settings -- verify that non-sharding+batch insert is fast
    mongo localhost:47017/shard_test test.js

    # Change test.js to run sequential and/or using the rnd key
