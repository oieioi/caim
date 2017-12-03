# caim

caim is a terminal based [Zaim](https://zaim.net/) client.

## Installation

### Dependencies

- ruby
- bundler

### Install

Clone this repository and

    $ bundle install --path vendor/bundle
    $ bundle exec ./bin/caim login

## Usage

OAuth

    $ caim login

Get list

    $ caim list
    $ caim list 2017-11

    2017-11-01 458 食費 昼ごはん
    2017-11-01 195 交通費 バス
    ...

Get accounts, categories and genres with index

    $ caim account
    $ caim category
    $ caim genre

Pay payment

    $ caim pay 150 --yes \
      --genre genre_index \
      --account account_index \
      --date 2017-11-23 \
      --comment コカコーラ \
      --place セブンイレブン一番町店

Interactively determine genre and pay payment

    $ caim pay 150


## TODO

income

    $ caim earn 200000 genre_index -a account_index
    
Update money
    
    $ caim update

Delete money

format CSV

filter list

    $ caim list --category 食費

summary

    $ caim sum 2017-11
    $ caim sum 2017-11 食費

    2000

total amounts of each account

    $ caim account

    財布 2000
    口座 20
    クレジット -10000
    ...



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
