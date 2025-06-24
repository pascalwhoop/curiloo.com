---
title: Crawling the Amsel multiple sclerosis forum
author: Pascal Brokmeier
layout: post
# cover: cover.jpg
date: 2025-05-24
# cover-credit: 
mathjax: false
categories:
 - technology
tags: 
 - crawling
 - amsel
 - multiple sclerosis
excerpt: TODO
---

Okay, so this blog post is going to be about me crawling the Amsel multiple sclerosis forum in, which is a German speaking multiple sclerosis forum. And the goal here is to crawl all posts and comments and conversations, and then extract from all of those conversations, key entities and questions that we have. So I'd like to essentially figure out like, was a specific medication mentioned? Were any side effects mentioned? Were people like what are the treatments that are that are being talked about? What doctors are being mentioned so that we can kind of get a bit of an analysis of? Yeah, what is the state of knowledge of the German MS community?


## 1. Crawling the forum data

Just when I started to get ready to crawl all of the posts, I thought, "Hey, actually let me check if anyone else has already written a crawler for this specific technology." Because everything is accessible as an API and I suspect there might already be ETL tools for extracting all of the posts from a forum like this one.

I found a tool
online which performs fairly well crawling all of the posts out of a discourse instance
and storing them in a DuckDB database. The only issue that I was facing was that the
GitHub repository I found was not supporting URLs that include a subpath. So I had Gemini
2.5 fix the code for me so that I could crawl it also with a subpath and send a PR to the
repository.

Steps: 

1. Initial solution provided by [Google Jules](https://jules.google.com/)
2. some adjustments from my side because it still did not work as expected
3. [Create a PR](https://github.com/trozzelle/DiscourseCrawler/pull/2)

## 3. Exploring the data 

I got  11k topics and 134k posts. 

```
page	371
topic	11114
post	134446
user	0
```

Looking closer at the posts, we have

```
sums
shape: (1, 2)
┌─────────────┬─────────┐
│ text_length ┆ reads   │
│ ---         ┆ ---     │
│ u32         ┆ i64     │
╞═════════════╪═════════╡
│ 75619964    ┆ 3031210 │
└─────────────┴─────────┘
avg
shape: (1, 2)
┌─────────────┬───────────┐
│ text_length ┆ reads     │
│ ---         ┆ ---       │
│ f64         ┆ f64       │
╞═════════════╪═══════════╡
│ 562.456034  ┆ 22.545929 │
└─────────────┴───────────┘
median
shape: (1, 2)
┌─────────────┬───────┐
│ text_length ┆ reads │
│ ---         ┆ ---   │
│ f64         ┆ f64   │
╞═════════════╪═══════╡
│ 374.0       ┆ 4.0   │
└─────────────┴───────┘
```

## 4. Building a processing pipeline

For this part of the work, I wanted to try a new machine learning framework for
structuring the pipelines because I'm quite used to kedro, so I tried [Prefect](https://docs.prefect.io/v3/get-started/quickstart).

I structured the pipeline in 3 pieces:

1. Extract data from the DB (a simple `SELECT`)
2. deconstruct the `json` into useful table columns 
3. Using [Curator](https://github.com/bespokelabsai/curator?tab=readme-ov-file), batch process the posts to extract entities such as doctors, symptoms and drugs
4. ...

What is interesting is that the library automatically creates a batch job for the API calls which cuts cost by ~ 50%. 


```
          Final Curator Statistics
╭────────────────────────────┬─────────────╮
│ Section/Metric             │ Value       │
├────────────────────────────┼─────────────┤
│ Model                      │             │
│ Model                      │ gpt-4o-mini │
│ Batches                    │             │
│ Total Batches              │ 1           │
│ Submitted                  │ 0           │
│ Downloaded                 │ 1           │
│ Requests                   │             │
│ Total Requests             │ 1000        │
│ Successful                 │ 1000        │
│ Failed                     │ 0           │
│ Tokens                     │             │
│ Total Tokens Used          │ 402,302     │
│ Total Input Tokens         │ 379,779     │
│ Total Output Tokens        │ 22,523      │
│ Average Tokens per Request │ 402         │
│ Average Input Tokens       │ 379         │
│ Average Output Tokens      │ 22          │
│ Costs                      │             │
│ Total Cost                 │ $0.029      │
│ Average Cost per Request   │ $0.000      │
│ Input Cost per 1M Tokens   │ $0.075      │
│ Output Cost per 1M Tokens  │ $0.300      │
│ Performance                │             │
│ Total Time                 │ 801.92s     │
│ Average Time per Request   │ 0.80s       │
│ Requests per Minute        │ 74.8        │
│ Input Tokens per Minute    │ 28415.1     │
│ Output Tokens per Minute   │ 1685.2      │
╰────────────────────────────┴─────────────╯
```


