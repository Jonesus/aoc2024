import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import simplifile

const filepath = "./src/day14/input.txt"

// Y, X
//const dims = #(7, 11)
const dims = #(103, 101)

/// Y, X
type Pos =
  #(Int, Int)

/// dY, dX
type Vel =
  #(Int, Int)

type Robot =
  #(Pos, Vel)

fn parse_part(s: String) -> #(Int, Int) {
  let assert [_, vals] = string.split(s, "=")
  let assert [x_str, y_str] = string.split(vals, ",")

  let assert Ok(x) = int.parse(x_str)
  let assert Ok(y) = int.parse(y_str)

  #(y, x)
}

fn parse_line(s: String) -> #(Pos, Vel) {
  let assert [pos, vel] = string.split(s, " ")

  #(parse_part(pos), parse_part(vel))
}

fn move(current: Int, velocity: Int, limit: Int) -> Int {
  let candidate = current + velocity

  case candidate >= limit {
    True -> candidate - limit
    False ->
      case candidate < 0 {
        True -> limit + candidate
        False -> candidate
      }
  }
}

fn tick(r: Robot) -> Robot {
  let #(pos, vel) = r

  let pos_y = move(pos.0, vel.0, dims.0)
  let pos_x = move(pos.1, vel.1, dims.1)

  #(#(pos_y, pos_x), vel)
}

fn split_uneven(
  l: List(Robot),
  axis: fn(#(Int, Int)) -> Int,
) -> #(List(Robot), List(Robot)) {
  let left =
    list.filter(l, fn(r) {
      let #(pos, _) = r
      axis(pos) < axis(dims) / 2
    })
  let right =
    list.filter(l, fn(r) {
      let #(pos, _) = r
      axis(pos) > axis(dims) / 2
    })

  #(left, right)
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  let start =
    contents
    |> string.split("\n")
    |> list.map(parse_line)

  let end =
    list.repeat(Nil, 100)
    |> list.fold(start, fn(l, _) { list.map(l, tick) })

  let #(top, bottom) = split_uneven(end, pair.first)

  let #(topleft, topright) = split_uneven(top, pair.second)
  let #(bottomleft, bottomright) = split_uneven(bottom, pair.second)

  [topleft, topright, bottomleft, bottomright]
  |> list.map(list.length)
  |> list.reduce(int.multiply)
  |> io.debug
}
