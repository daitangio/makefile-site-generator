---
title: Main Page
authors:
  - Giovanni Giorgi
categories:
  - intro
  - tech
  - software
---
## Main web site
This web site is a demo site for my own makefile site generator, called (after a long thinking) makefile-site-generator.
The project is a makefile for generating a nice static site: blazing fast, minimum dependencies.
It is based on the following articles:

- https://itnext.io/glorious-makefile-building-your-static-website-4e7cdc32d985
- https://www.karl.berlin/static-site.html
- https://github.com/patrickbr/hagel/

A good read of the [make manual](/make.html) taken from official https://www.gnu.org/software/make/manual/ is important too.

The template engine is based on [pandoc templates](https://pandoc.org/MANUAL.html#templates) so you can employ yaml metadata on every markdown file.

## Basic usage

On every page you can add a set of metadata like a list of authors and categories like the following:
```
---
title: Main Page
authors:
  - Giovanni Giorgi
categories:
  - intro
  - tech
  - software
---
```

## How categories works
For every category, you must define a file inside category/ to describe it.
The categroy page must have the following structure  






