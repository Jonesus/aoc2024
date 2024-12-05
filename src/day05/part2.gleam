import day05/part1
import gleam/bool
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import lib/utils

const filepath = "./src/day05/input.txt"

fn get_compare_pages(
  rules: List(#(String, String)),
) -> fn(String, String) -> order.Order {
  fn(a: String, b: String) {
    case
      list.find(rules, fn(target) { target == #(a, b) }),
      list.find(rules, fn(target) { target == #(b, a) })
    {
      Ok(_), Error(_) -> order.Lt
      Error(_), Ok(_) -> order.Gt
      _, _ -> order.Eq
    }
  }
}

fn get_rules_pairs(rules: List(List(String))) -> List(#(String, String)) {
  list.map(rules, fn(rule) {
    case rule {
      [a, b] -> #(a, b)
      _ -> panic
    }
  })
}

pub fn main() {
  let #(rules_list, pages_list) = part1.get_rules_and_pages(filepath)
  let rules = part1.get_rule_dict(rules_list)

  list.map(pages_list, part1.get_page_rule_mapping(rules, _))
  |> list.map(part1.check_rules)
  |> list.zip(pages_list)
  |> list.filter(fn(x) { bool.negate(pair.first(x)) })
  |> list.map(pair.second)
  |> list.map(fn(pages) {
    list.sort(pages, get_compare_pages(get_rules_pairs(rules_list)))
  })
  |> utils.deep_map(int.parse)
  |> list.map(result.values)
  |> list.map(part1.get_middle_value)
  |> utils.print_sum
}
