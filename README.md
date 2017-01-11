# lita-pair

[![Build Status](https://travis-ci.org/recursivefaults/lita-pair.png?branch=master)](https://travis-ci.org/recursivefaults/lita-pair)

If you're crazy (And I do mean crazy) about pair programming as a team you may have experienced a certaind difficulty 
figuring out who to pair with, having lots of people swap around, or just choosing in general. Well, with lita-pair,
a bot that doesn't know or care about you, will decide exactly who you should pair with. Think of it, all that time
wasted deciding on who whould be the best pair to solve that urgent problem will be replaced with cold indifferent
automation. Usher in your new automated pair overlord today!

## Installation

Add lita-pair to your Lita instance's Gemfile:

``` ruby
gem "lita-pair"
```

## Usage

Currently lita-pair only has a few bare features. Let me know what you'd like!

1. We can add members that Lita can use to create pairs by using ```pair add <name>```
2. We can remove a member by using ```pair remove <name>```
3. We can have lita tell us who all the members are that it can use to pair by using: ```pair members```
4. We can have lita give us a pair by using ```pair one```
