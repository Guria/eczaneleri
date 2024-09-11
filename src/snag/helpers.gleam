import gleam/io
import gleam/result
import snag

fn to_snag(error, message) {
  io.debug(error)
  snag.new(message)
}

pub fn map_error_to_snag(result, message) {
  result
  |> result.map_error(to_snag(_, message))
}
