---
title: Choosing the right blog technology in 2017
author: Pascal Brokmeier
layout: post
date: 2017-11-11
mathjax: false
tags: 
 - technology
excerpt: A guide to finding the right balance between absolute dead-simple usability and tech-savvy workflow allowing for a range of customisation and control abot your blog or website.
---

{{< fimg cover.jpg Crop "1920x1080" />}}

**TL;DR:** A list of choices ranging from the publishing service medium.com all the way to custom server,tech,build tools etc.

I was recently asked to help decide on a new setup for a website and its underlying technology. I decided to give several alternatives from "dead simple" but very restricted to "very geeky" but with full control over the whole development chain.

## Page requirements
The website is used by a few dozen authors to publish stories about Naples in Italy and might be expanded to offer more than just stories. It should be able to uphold to the current standards of web development which means:

-   Good Google Pagerank score
-   optimized assets for fast load time
-   attractive interface
-   mobile ready (duh)
-   allowing to send notifications to users
-   allow visitors to formulate stories that are passed into the common post approvement pipeline
-   allow authors to be "code shy". That means no Github commit to publish. ( :-( )

## The alternatives

Let us start from the dead simple one to start with:

### Medium.com
If all you want to do is blog and share your ideas, medium.com is probably the safest bet. It has a dead simple editor, nothing to install, nothing to learn. Just create an account and start writing, or if you want to have multiple people write under one brand name, [create a publication](https://help.medium.com/hc/en-us/articles/115004681607-Create-publication) and invite your authors to write for your publication. That's it. Mine looks like [this](https://medium.com/curiouscaloo), others can be found all over medium. The biggest (and most noteworthy in my eyes) is [freecodecamp](https://medium.freecodecamp.org/). What, that's a custom domain? Yes, Medium let's you do that. Add your own domain for a one-time payment and you can blog away under your own brand with a small medium branding here and there. It's mostly free for most use cases and let's you customize your page a weee little bit.

### squarespace.com

As a full online service, they are obviously on the higher end of the cost spectrum coming in at € 17 a month excluding the domain cost and assuming you fork over the whole year worth in one payment. They do however offer a fair amount of service for this as they give you dozens of very nicely designed website interfaces and layouts that you can customize to your desire with easy drop down and select lists.

![](images/2017-11-11/squarespace-screenshot.png)

[squarespace.com](http://squarespace.com)

### Content Management Systems

This is the classic way of creating a website. You take a server, put a CMS on it and then manage your website. There are more and less flexible ones, all sorts of languages implemented them and they usually have a database underneath the visible parts and an administration interface. There are several and I will just list a few from most to less known:

-   [Wordpress](https://wordpress.org/) is the worlds most used CMS. It is open source and let's you customize with thousands of plugins and themes. It is however based on php and some people have (more or less based on actual reasons) reservations against the language. I am not a fan myself and therefore prefer not to use it. I also don't like the idea of having to have a database for my posts. If the classic styles are too old school for you, maybe [trying these fresh ones](https://themebeans.com) is something you need to start liking it again.
-   [Contao](https://contao.org) Is another php based CMS and was recommended to me by a [good designer friend](www.marco-a.de) who uses it a lot for his clients. It allows you to mess with the code but still has click and point functionality.
-   [wagtail](https://wagtail.io/) is for those that learned python in University and want to make use of their skills. It's again a free and open source CMS and let's you mess with the underlying parts with the skills you bring from school. And since you already have a server with python, why not write some small backend functions and a small API to give your page the little bit of extra spice. If you have some interest in AI, then this is also for you, as python is the *cool kid on the block in Data Science*.
-   Going completely "[headless](https://headlesscms.org/)" with [netlify-cms](https://www.netlifycms.org/) is the approach that most frontend-developers would prefer. Keep all the frontend-code what it is and try to just manage your whole page without an actual backend but just based on JavaScript, APIs and Markup that is rendered at built time. This way you can have a purely "static" website that does not require server logic to be displayed. Just throw it on any webhost, point the DNS towards it and you're ready to go.

### The code way of doing it

If you don't mind getting your hands dirty and you want to learn while you make a website, this is the way. It uses many tools that are used by many large scale software projects and anyone who wants to learn the pipeline of modern application development or already knows and loves it should choose this one. But be aware, this is not for the code-shy among us, it requires knowledge of web technologies, git, some unix skills and some proprietary service skills like circle-ci and firebase.

**The stack is basically this**:

-   Start with **jekyll to generate your page** with templates and write the posts in markdown. You have full control over your page as it is all HTML, CSS and JavaScript/TypeScript/EcmaScript or whatever flavour you prefer. Spice it up with NodeJS workflows, jenkins plugins or whatever floats your boat. You're in control of the build toolchain.
-   **Choose your style**, for example on [html5up.net](https://html5up.net/) or [jekyllthemes.io](https://www.jekyllthemes.io/) or any other template page that you like. Many offer jekyll based templates
-   **Commit your code** to [Github](https://github.com) to share it with the world, get noticed by possible employers and use several tools and online services to keep walking. It's the "database" of your website, the "single point of truth" (although really, git is non-centralized I know) where all people working on it can meet, discuss and share their work with each other.
-   **Build your website** with [CircleCI](https://circleci.com) every time you commit code to Github. The service knows when you triggered a push to the repository and automatically creates a new version of your page. Tell it where to deploy it and it binds together the production environment with the code.
-   **Host your page** on [firebase](https://firebase.google.com) or AmazonAWS or any other service that hosts static assets. It should be on a global CDN to ensure fast load times though.

This allows you to have a quick, yet flexible workflow that, so far, is basically free. Only once your page generates so many hits that firebase charges you, will it start to cost money. By that time though, you probably should think about a business model anyways.
You can also leave the website on Github and use Github pages, but I like to have a few custom jekyll plugins and Github won't let us use those so we have to use other services. But using a CI tool like CircleCI is good practice anyways and getting used to Firebase is also not a bad idea.

This doesn't let you invite any code-shy people though. So to make the stack more approachable, maybe some additions are needed. Here is where netlify comes in:

#### Getting it "human friendly"

People that sneeze at the sight of html need to get a point-type-click-publish workflow. For this, we can use netlify. It's free tier allows you to create a *CMS like* experience for editors. What it actually does is perform actions against the Github API and commit code to the repository. All without a dedicated backend. Okay that is the very oversimplified version but once you understand what it does, you don't need the explanation anymore anyways and until then it will just cause confusion. You can do this in two ways:

-   Have everyone get a Github account (good first step for world improvement)
-   Use a Git Gateway service, as netlify and others [offer](https://www.netlifycms.org/docs/#configuration)

The first one is the absolutely lightweight one but it requires everyone who wants to perform an edit to login with their Github account or create one if they don't have one. The second one is definately simpler to setup, especially if you also would like guests to submit stories that you can then verify and publish if you please.

![](./pull-request-example.png )

For publishing you can either use the Github Website to merge the auto-created PR or you can use the `/admin` interface which was also used to create the post.

## Wrapping it up

To summarize, there are many ways to get your webpage or that of a customer going. it really depends on the technical capabilities of the people that will later work with the website. Generally, the more experience the people managing the website have, the more versatile are the abilities once you embrace code. Especially for software developers or soon-to-be ones, using the last version is especially helpful as it uses many tools that are also used in the every-day workflow. On the other hand, if the people that take care of the website really don't care about web technologies at all, using a "get it all" service provider such as squarespace.com is probably the best way to go. It's quick, easy and costs an acceptable amount of money.
