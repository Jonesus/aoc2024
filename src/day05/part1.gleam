import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import lib/utils
import simplifile

const filepath = "./src/day05/input.txt"

type Pages =
  List(String)

type Rules =
  dict.Dict(String, List(String))

pub fn get_rules_and_pages(filename: String) {
  let assert Ok(contents) = simplifile.read(filename)

  contents
  |> string.split(on: "\n\n")
  |> fn(xs) {
    case xs {
      [rules, pages] -> #(
        string.split(rules, on: "\n")
          |> list.map(string.split(_, on: "|")),
        string.split(pages, on: "\n")
          |> list.map(string.split(_, on: ",")),
      )
      _ -> panic
    }
  }
}

pub fn get_rule_dict(rules_list: List(List(String))) -> Rules {
  rules_list
  |> list.group(fn(rule) {
    case rule {
      [page, _] -> page
      _ -> panic
    }
  })
  |> dict.to_list
  |> list.map(fn(page_and_rules) {
    pair.map_second(page_and_rules, list.map(_, fn(item) {
      case item {
        [_, ordering] -> ordering
        _ -> panic
      }
    }))
  })
  |> dict.from_list
}

type PageRuleMapping =
  dict.Dict(String, #(Int, List(String)))

pub fn get_page_rule_mapping(
  rules: Rules,
  pages: Pages,
) -> #(Pages, PageRuleMapping) {
  let page_rule_map =
    list.index_map(pages, fn(page, index) {
      case dict.get(rules, page) {
        Ok(page_rules) -> #(page, #(index, page_rules))
        Error(_) -> #(page, #(index, []))
      }
    })
    |> dict.from_list

  #(pages, page_rule_map)
}

pub fn check_rules(pairs: #(Pages, PageRuleMapping)) {
  let #(pages, page_rule_map) = pairs

  list.all(pages, fn(page) {
    case dict.get(page_rule_map, page) {
      Ok(#(index, page_rules)) -> {
        list.all(page_rules, fn(rule) {
          case dict.get(page_rule_map, rule) {
            Ok(#(ruled_index, _)) -> index < ruled_index
            Error(_) -> True
          }
        })
      }
      Error(_) -> False
    }
  })
}

pub fn get_middle_value(xs: List(a)) {
  let middle =
    xs
    |> list.index_map(fn(x, index) { #(index, x) })
    |> list.drop_while(fn(x) { x.0 < list.length(xs) / 2 })
    |> list.first

  case middle {
    Ok(#(_, value)) -> value
    Error(_) -> panic
  }
}

pub fn main() {
  let #(rules, pages_list) =
    get_rules_and_pages(filepath)
    |> pair.map_first(get_rule_dict)

  list.map(pages_list, get_page_rule_mapping(rules, _))
  |> list.map(check_rules)
  |> list.zip(pages_list)
  |> list.filter(pair.first)
  |> list.map(pair.second)
  |> utils.deep_map(int.parse)
  |> list.map(result.values)
  |> list.map(get_middle_value)
  |> utils.print_sum
}
