---
title: Installation
---
# Installation

``` ruby
# Gemfile
group :development do
  gem 'statik64', git: 'https://github.com/CHUReimsDSN/Statik64.git'
end
```

```sh
bundle install
```

## Cibler une branche spécifique

``` ruby
# Gemfile
group :development, :test do
  gem 'statik64', git: 'https://github.com/CHUReimsDSN/Statik64.git', branch: 'nom_de_la_branche'
end
```

## Dépendances

```ruby
# Runtime depedencies
"activerecord", ">= 6.0"
```
