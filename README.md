# mongolab

Example source code for the blog post [Slow batch insert with MongoDB sharding and how I debugged it](http://cfc.kizzx2.com/index.php/slow-batch-insert-with-mongodb-sharding-and-how-i-debugged-it/)

## Usage

    sh mongolab.sh

    # Default settings -- verify that sharding+batch insert is slow
    mongo localhost:37017/shard_test test.js

    # Default settings -- verify that non-sharding+batch insert is fast
    mongo localhost:47017/shard_test test.js

    # Change test.js to run sequential and/or using the rnd key

## Summary

Time in ms (lower is better):

                            | No-Shard   | No-Shard (with `rnd`)   | Shard `{ id: "hashed" }`   | Shard `{ rnd: 1 }`   
----------------------------|------------|-------------------------|----------------------------|----------------------
 Batch insert               | 640        | 740                     | 21038                      | 1004                 
 Normal (sequential) insert | 1404       | 1468                    | 1573                       | 1790                 
