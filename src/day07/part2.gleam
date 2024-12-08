import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import lib/utils

const filepath = "./src/day07/input.txt"

fn attempt(target: Int, parts: List(Int)) -> Bool {
  case parts {
    [] -> panic
    [a] -> a == target
    [a, b, ..rest] -> {
      let assert Ok(concatenated) =
        int.parse(string.append(int.to_string(a), int.to_string(b)))
      attempt(target, [a * b, ..rest])
      || attempt(target, [a + b, ..rest])
      || attempt(target, [concatenated, ..rest])
    }
  }
}

pub fn main() {
  let items =
    utils.file_to_lines(filepath)
    |> list.map(fn(line) {
      let assert [result_str, parts_str] = string.split(line, ": ")
      let assert Ok(result) = int.parse(result_str)
      let parts =
        string.split(parts_str, " ")
        |> list.map(int.parse)
        |> result.values
      #(result, parts)
    })

  let possibles =
    items
    |> list.map(fn(item) {
      let #(target, parts) = item
      attempt(target, parts)
    })

  possibles
  |> list.zip(items)
  |> list.filter(pair.first)
  |> list.map(fn(x) { x.1.0 })
  |> utils.print_sum
}
