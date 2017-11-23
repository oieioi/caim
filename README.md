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

```
2017-11-01 458 食費 昼ごはん
2017-11-01 195 交通費 バス
...
```

## TODO


cache category, genre and account

payment

    $ zaim_cli pay 200 --category 食費 --genre 飲物 --account 財布 --date 2017-11-23 --comment コカコーラ --place セブンイレブン一番町店
    $ zaim_cli pay 200 -c 食費 -g 飲物

income

    $ zaim_cli earn 20000 給与収入

filter

    $ zaim_cli list --category 食費

total amounts of each account

    $ zaim_cli amount

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
