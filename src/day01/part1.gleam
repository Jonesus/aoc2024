import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const filepath = "./src/day01/input.txt"

pub fn get_lists(contents: String) {
  contents
  |> string.split(on: "\n")
  |> list.map(string.split(_, on: " "))
  |> list.map(list.filter(_, fn(x) { x != "" }))
  |> list.map(fn(pair) {
    let parsed = case pair {
      [a, b] -> #(int.parse(a), int.parse(b))
      _ -> panic as "lol"
    }
    case parsed {
      #(Ok(a), Ok(b)) -> #(a, b)
      _ -> panic as "lol"
    }
  })
  |> list.unzip
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  get_lists(contents)
  |> fn(x) {
    list.zip(list.sort(x.0, int.compare), list.sort(x.1, int.compare))
  }
  |> list.map(fn(x) { int.max(x.0, x.1) - int.min(x.0, x.1) })
  |> int.sum
  |> int.to_string
  |> io.println
}
