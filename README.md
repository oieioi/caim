# caim

caim is a terminal based [Zaim](https://zaim.net/) client.

## Installation

### Dependencies

- ruby
- bundler

### Install

Clone this repository and

    $ bundle install
    $ echo alias caim=\"BUNDLE_GEMFILE=`pwd`/Gemfile bundle exec ruby `pwd`/bin/caim\" >> ~/.bash_profile
    $ source ~/.bash_profile

## Usage

OAuth

    $ caim login

Get list

    $ caim ls
    $ caim ls 2017-11
    $ caim ls --summary
    $ caim ls --category-summary
    $ caim ls --genre-summary
    $ caim ls --format json

Get accounts, categories and genres with index

    $ caim account
    $ caim category
    $ caim genre

Pay payment

```
$ caim pay 150 --yes \
  --genre genre_index \
  --account account_index \
  --date 2017-11-23 \
  --memo コカコーラ \
  --place セブンイレブン一番町店

# Interactively
$ caim pay -i
```

Earn income

```
$ caim earn 200000 \
  --category category_index \
  --account account_index \
  --memo 11月分給与 \
  --place バイト先 \
  --date 2017-11-25

# Interactively
$ caim earn -i
```

Remove money

    $ caim rm money_id

## TODO

transfer

    $ caim mv 20000 from_account_id to_account_id

Update money

    $ caim update money_id

filter list

    $ caim ls --category 食費

format CSV

    $ caim ls --all --format csv

summary

    $ caim sum 2017-11
    $ caim sum 2017-11 食費

Update master data

    $ caim category update
    $ caim genre update
    $ caim account update

total amounts of each account

    $ caim account

    財布 2000
    口座 20
    クレジット -10000
    ...

And publish as gem !


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
