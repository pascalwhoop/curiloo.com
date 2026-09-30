+++
title = 'Can a tiny model keep private chats out of your AI analytics?'
date = 2026-09-30T07:30:00-04:00
draft = false
author = 'Pascal'
+++

{{< fimg cover.jpg Crop "1920x1080" />}}

"ok make it a bit softer and cut the PIP paragraph". Nothing in that message is private. The message before it was a draft termination letter. A filter that reads only the words lets it through.

**TL;DR:** I tested small "System One" decision models on two jobs. The first job was to tag 1,400 messages from my own coding-agent sessions. The second job was to filter HR and personal content out of employee AI chats before anyone analyses them. The open model I started with (Laya, on MLX) was fast but close to random on the hard questions. The hosted model (Jev) caught all 45 sensitive test cases at a false alarm rate of 13% on tricky negatives. The problem: a privacy filter reads everything, so it must be self-hosted. That is the part I have not solved yet.

## Motivation

I use coding agents a lot (obviously, everyone does now). After three weeks I had about 100 sessions and wanted to know which questions I keep asking. The lazy option is to give all of it to a big LLM. That is slow and expensive, and I do not like to send my full history anywhere just to find patterns.

Then a second, bigger question came up. Companies start to collect the AI chats of their employees to learn how people use the tools. Some of these chats are about a bad performance review, a salary, a medical leave, or a divorce. Nobody wants the tooling team to read those. So the order of operations matters: filter first, then analyse.

Both jobs have the same shape. You have thousands of messages, and for each message you need a few small, typed decisions. You do not need an essay.

## What a "System One" model is

A System One model does not generate text. You give it a state (a message, a JSON object) and a set of typed questions. It returns numbers:

- **choice:** pick one label from a list, with probabilities for each label.
- **noul:** the probability that a statement is true (a yes/no question).
- **score:** an expected position on an ordered scale.

I think of it as the sorting clerk in a post office. The clerk reads the envelope and puts the letter into the right bin, very fast. The clerk never writes a reply. For filtering and tagging, that is exactly the job.

I tested two models:

| | Laya | Jev |
|---|---|---|
| Access | open weights, runs locally on MLX | hosted API only |
| Base | ModernBERT / mmBERT encoder, 322M-421M parameters | not published |
| Context | 512 tokens by default, 8k with a configuration change | 64k |

For this whole test I used the multilingual Laya checkpoint with `max_len` set to 8192. Their documentation states that the model starts degrading after 4k tokens but still this is not a luxury: 13% of my messages were longer than 512 tokens. So a 512 token default configuration is just silly.

## A detour: read the package before you install it

The MLX port of Laya had 6,623 GitHub stars. The repository was 10 days old and had 6 commits. That ratio does not look organic to me.

So before I installed it, I downloaded the wheel from PyPI and read the source. I searched for `exec`, `eval`, `subprocess`, `pickle`, `base64` and hardcoded URLs. The code was clean. It loads weights as safetensors (no pickle), and it calls `subprocess` only for `sysctl` and `ffmpeg` in a snake game demo. The stars still tell you nothing. Fifteen minutes of reading tells you a lot. Anyways, I'm paranoid so I sandboxed the server endpoint I built anyways.

## Experiment 1: tag my own sessions

I wrote a small CLI (Typer and Pydantic) that pulls my sessions from [agentsview](https://github.com/wesm/agentsview). It keeps my prompts and the last text reply of the agent per turn. Then it sends each message through a versioned schema. I did three rounds of "define classes, run a sample of 60, read the result, sharpen".

The biggest lesson had nothing to do with the model. **Extraction noise was the main problem.** In round one, the "most important" messages were thinking blocks, rendered tool calls, and text that the agent harness injects into the user turn. When I removed these, 1,717 messages became 1,370. Only after that did the scores start to mean something.

The other lessons, in short:

- An "other" option attracts everything. With "other" in the topic list, half of the sample went there. When I removed it, `app_development` became the new sink.
- Short replies are unreadable alone. "agreed, let's go with those two" means nothing without the message before it. When I added the previous agent reply as `replying_to`, the "does the user commit to a decision" question became usable.
- Yes/no questions are less independent than they look. My "is this the first contact with a topic" question correlated at +0.88 with "is this message important". It measured "this message stands out", not novelty.
- Laya is fast. The median was 37-83 ms per message for all questions together, on a laptop.

Two signals worked well: "is this message worth keeping" and "does the agent make a recommendation". The multi-class questions (topic, intent) stayed at a confidence of about 0.5. My favourite catch for "friction" was a message of mine to an agent: "like a flag in the wind. you have no spine". Fair enough, I guess.

## Experiment 2: Laya against Jev on 200 real messages

I ran the same schema on the same 200 messages with both models.

| Question | Agreement |
|---|---|
| intent (8 labels) | 21% (Cohen's kappa 0.13) |
| topic (8 labels) | 35% (kappa 0.23) |
| is this message key | 43% (correlation of the probabilities: 0.03) |
| does the user commit | 49% |
| does the agent recommend | 56% |
| does the user show friction | 77% |

Agreement tells you that the models disagree. It does not tell you who is right. So I read the most confident disagreements for each question. On intent, topic and "does the user commit", Jev was right in almost all of them. One example: "any way why you can't push yourself? I don't get it". Laya gave it 0.98 as a decision. It is a question. Jev gave it 0.05.

Jev had a median latency of 283 ms, and the 200 messages cost less than one cent. With 8 parallel requests I hit the rate limit. With 3 parallel requests, all calls passed.

> Small plug, I used orq.ai gateway for accessing jev. I can't be bothered to create a new account every time some new lab pops up. Shout out to Sohrab & team.

My first impression of Laya was "the Temu version of Jev". For these questions, the numbers are kind of in line with that impression.

## Experiment 3: a privacy filter, tested on synthetic data

For the privacy question I did not want to use real chats at all. I'd probably get fired if I did and also, I don't have access to them anyways. So I wrote 100 synthetic cases with fictional names:

- **45 sensitive cases:** HR matters about a specific person (10), pay (8), health (8), personal life (7), and complaints or legal matters (7). Another 5 cases are only sensitive because of the message before them, like the PIP message at the top of this post.
- **30 hard negatives:** text that looks sensitive but is normal work. Examples are clinical trial data, the pay of public executives, a job description, a colleague named in normal work, and HR software.
- **25 plain work messages.** Three of them use the exact words of a context case but follow a harmless reply. This test shows if a model reads the context or only the words.

The hard negatives are the most important part. For a pharma or healthcare team, medical content is normal work. A filter with the rule "health = sensitive" removes half of the useful data.

I asked each model two versions of the question. The naive version was one line: "Does `message` contain sensitive HR or personal information?" The policy version said what counts as private and what does not (research, public executives, general HR processes, colleagues in normal work).

For a filter, the important number is the cutoff that catches every sensitive case, and the false alarms at that cutoff.

| Model and question | AUC | Cutoff that catches all 45 | False alarms: hard / plain |
|---|---|---|---|
| **Jev, policy version** | **0.99** | 0.17 | **13% / 0%** |
| Jev, naive version | 0.97 | 0.07 | 47% / 0% |
| Laya, policy version | 0.47 | 0.002 | 100% / 100% |
| Laya, naive version | 0.73 | about 0 | 93% / 92% |

A few details stood out to me:

- The policy wording cut the false alarms of Jev on hard negatives from 47% to 13%. The words in the question are part of the model.
- The naive question missed all 5 context cases. The policy version tells the model to read `replying_to`, and then it caught all of them.
- The Jev category question (which kind of private information, or none) put every one of the 45 cases in the correct category. It answered "none" on 95% of the negatives.
- At a cutoff of 0.5, Jev missed five cases. Three were about personal life: a dating profile (0.29), a plan to leave the company (0.32) and a mortgage budget (0.40). The other two were a whistleblower report (0.17) and an ADHD accommodation (0.43). So you must set the cutoff low. You cannot use 0.5.
- Laya with the policy version was at chance level. The English Laya checkpoint returned about 0.5 for every case. That contradicts an earlier test with plain text input, so it can be a setup problem on my side. I count it as inconclusive.

This test has limits. I wrote the cases and the labels myself, and I can argue with some of my own labels (for example, a lawsuit against a startup founder that is in a public court filing). Synthetic text is also cleaner than real chat. The numbers show which approach is workable. They are not a production accuracy.

## Why the best model here is the wrong answer

Jev won. But a filter must read every message to decide what to remove. If the filter is a hosted API, every HR chat goes to a third party first. That is a bigger exposure than the one the filter is there to prevent.

So I think at this point, we still have to wait a bit before system 1 models can help us with this tool, unless typesafe.ai starts hosting their endpoints on GCP/AWS/Azure. Because onboarding new vendors is not fun in most industries, but definitely not in health care or pharma.

A false negative (one missed HR chat) is the incident everybody is afraid of. A false positive only costs you some research data. So filtering is a recall problem, and it needs a model that is good at it and runs on your own hardware. Sadly we don't have this yet.

## Looking forward (where I am stuck)

I am keeping an eye out for a self hosted model like this (or a Jev announcement to host on cloud providers). 

A first search gave me three candidates to test next:

- **JevK5** (4B, Apache-2.0). It serves a Jev-style API, so for my CLI it is almost a base URL change. It runs on a Mac through llama.cpp. The limits are 16k context and English only.
- **gpt-oss-safeguard-20b.** You give it your written policy at runtime, and it returns a verdict with reasoning. For compliance, a reason per decision is super valuable. It is slower and does not give calibrated probabilities.
- **GLiNER2** (205M, CPU). It finds names, amounts and identifiers as spans, and it can extract relations. I see it as a second, independent signal and as a tool for extracting structured knowledge once we have solved the filtering.

A community benchmark (JevBench) shows several open 4B models at or above Jev on the total score. Most of that lead comes from speed and cost. On the reasoning score alone, Jev still leads, but narrowly. All of these numbers are self-reported or a few weeks old, and none of them tests privacy content. And after the star count on Laya, I am starting to doubt these benchmarks are even real. It's both exciting what age we live and sad that benchmarks are really not trustworthy. 

The bottom line, at least for now: **small decision models are the right tool for this kind of filter. But only the hosted one was good enough in my test.** The next step is to run JevK5 and gpt-oss-safeguard on the same 100 cases. If one of them gets close to the Jev numbers on hard negatives, the architecture above works without any chat leaving the building. If not, I guess the honest answer is a tenant split and no content filter at all.
