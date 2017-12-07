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
  --comment コカコーラ \
  --place セブンイレブン一番町店
# Interactively
$ caim pay -i
```

Delete money

    $ caim delete money_id

## TODO

income

    $ caim earn 200000 genre_index -a account_index

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
