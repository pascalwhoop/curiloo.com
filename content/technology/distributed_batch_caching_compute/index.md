## Problem statement

- We want to build a system that allows computing a large number of _expensive_ functions on rows in a dataset
- We want to do this in a distributed fashion
- The size of the dataset is larger than memory
- the functions are _expensive_ to compute and may either be executed through an API call or against a local GPU
- we want to cache the results in a storage system but ideally avoid long-running DBs to be running
- the system may be shared by multiple teams to benefit from economies of scale


## Solution approach

- the distribution of compute will be done via ray as it allows us to run large scale of huggingface models
- the caching layer is an open question
- the reading will happen with kedro and polars datasets in lazy mode
- polars will read the data in batches which will be passed to ray for processing
- we believe that we should determine _what_ needs calculating before passing to ray as we expect the % of the total data that needs computing to be very small in most
  moments

