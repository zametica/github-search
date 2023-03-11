# Github Search Repositories

The main issue with fetching the repositories is hitting the rate limit on high concurrent load. There are a couple of possible solutions though but neither one of them solves the issue completely but rather prevents hitting the limits frequently.

Possible solutions:

* Cache results using in-memory storage (memcache or Redis)
  - The idea is to cache response from Github using the key as combination of search query and page param which would eventually prevent the same call to be performed multiple times in a predefined cache ttl
  - Balance between ttl and load has to be taken into account since it could easily run into out of memory issues
* Implement a worker to fetch repositories using `/repositories` endpoint instead of the search one
  - The worker would be responsible for pre-fetching repositories and persisting them in a db (NoSQL preferable)
  - Search would be performed on a db level
  - There is a `since` query param which could be used to get the repositories since the last run, but this could lead to data inconsistency issues since repositories could be altered (e.g. renamed)
  - Although it's supposed to be fast it could be a long and exhausting process and it does not guarantee a real-time data consistency
