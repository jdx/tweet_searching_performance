Tweet Performance Examples
==========================

This is a collection of various ways to search databases for millions of records and their performance.


PostgreSQL
----------

Results: Terrible. Once it hits ~1,000,000 records the full-text searching
totally falls apart.

To setup:

Create database called `tweet_perf`, then:

```bash
$ ./postgres.rb
```

It will create a database table, ensure that it has 25m rows, then perform some benchmarking.
