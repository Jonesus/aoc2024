import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

const filepath = "./src/day13/input.txt"

type ClawMoves =
  #(Float, Float)

type PrizeCoords =
  #(Float, Float)

type Group =
  #(ClawMoves, ClawMoves, PrizeCoords)

fn parse_input(s: List(String)) -> Group {
  let assert [a, b, result] = s

  let assert Ok(a_re) = regexp.from_string("Button A: X\\+(\\d+), Y\\+(\\d+)")
  let assert Ok(b_re) = regexp.from_string("Button B: X\\+(\\d+), Y\\+(\\d+)")
  let assert Ok(result_re) = regexp.from_string("Prize: X=(\\d+), Y=(\\d+)")

  let assert [regexp.Match(_, captures)] = regexp.scan(a_re, a)
  let assert [ax, ay] =
    captures
    |> option.values
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))
    |> list.map(int.to_float)

  let assert [regexp.Match(_, captures)] = regexp.scan(b_re, b)
  let assert [bx, by] =
    captures
    |> option.values
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))
    |> list.map(int.to_float)

  let assert [regexp.Match(_, captures)] = regexp.scan(result_re, result)
  let assert [rx, ry] =
    captures
    |> option.values
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))
    |> list.map(int.add(_, 10_000_000_000_000))
    |> list.map(int.to_float)

  #(#(ax, ay), #(bx, by), #(rx, ry))
}

fn float_is_int(x: Float) -> Bool {
  x |> float.round |> int.to_float == x
}

fn solve(g: Group) -> Int {
  let #(#(ax, ay), #(bx, by), #(px, py)) = g

  let a = { py *. bx -. by *. px } /. { ay *. bx -. by *. ax }
  let b = { px *. ay -. ax *. py } /. { bx *. ay -. ax *. by }

  case float_is_int(a), float_is_int(b) {
    True, True -> 3 * float.round(a) + float.round(b)
    _, _ -> 0
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  contents
  |> string.split("\n\n")
  |> list.map(string.split(_, "\n"))
  |> list.map(parse_input)
  |> list.map(solve)
  |> int.sum
  |> io.debug
}
