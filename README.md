## Installation

### Dependencies

- ruby
- bundler

### Install

Clone this repository and

    $ bundle install --path vendor/bundle
    $ bundle exec ./bin/zaim_cli login

## Usage

Get list

    $ zaim_cli list
    $ zaim_cli list 2017-11

    2017-11-01 458 食費 昼ごはん
    2017-11-01 195 交通費 バス
    ...

## TODO


cache categories, genres and accounts

    $ zaim_cli category update
    $ zaim_cli category show

    id name ...

payment

    $ zaim_cli pay 150 --category 食費 --genre 飲物 --account 財布 --date 2017-11-23 --comment コカコーラ --place セブンイレブン一番町店
    $ zaim_cli pay 150 -c 食費 -g 飲物

income

    $ zaim_cli earn 200000 給与収入

filter

    $ zaim_cli list --category 食費

summary

    $ zaim_cli sum 2017-11
    $ zaim_cli sum 2017-11 -c 食費

    2000

total amounts of each account

    $ zaim_cli account

    財布 2000
    口座 20
    クレジット -10000
    ...



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
