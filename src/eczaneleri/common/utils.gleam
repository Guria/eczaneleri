import eczaneleri/common/types.{type Position, Position}
import gleam/float
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/uri

pub fn google_maps_link(coords: Position) -> String {
  "https://www.google.com/maps/search/?api=1&query="
  <> float.to_string(coords.latitude)
  <> ","
  <> float.to_string(coords.longitude)
}

pub fn yandex_maps_link(coords: Position) -> String {
  "https://yandex.com/maps/?pt="
  <> float.to_string(coords.longitude)
  <> ","
  <> float.to_string(coords.latitude)
  <> "&z=15&l=map"
}

pub fn parse_coordinates_from_google_maps_link(href: String) -> Option(Position) {
  let options = regex.Options(case_insensitive: False, multi_line: False)
  let assert Ok(regex) =
    regex.compile(
      "https://maps\\.google\\.com/maps\\?q=(?<latitude>[^,]+),(?<longitude>[^,]+)",
      with: options,
    )

  case regex.scan(regex, href) {
    [regex.Match(_, [Some(latitude), Some(longitude)])] -> {
      Some(Position(
        latitude: float.parse(latitude) |> result.unwrap(0.0),
        longitude: float.parse(longitude) |> result.unwrap(0.0),
      ))
    }
    _ -> None
  }
}

pub fn osm_link(coords: Position) -> String {
  "https://www.openstreetmap.org/?mlat="
  <> float.to_string(coords.latitude)
  <> "&mlon="
  <> float.to_string(coords.longitude)
  <> "#map=17/"
  <> float.to_string(coords.latitude)
  <> "/"
  <> float.to_string(coords.longitude)
}

pub fn google_maps_text_search(query: String) -> String {
  "https://www.google.com/maps/search/?api=1&query="
  <> uri.percent_encode(query)
}

pub fn yandex_maps_text_search(query: String) -> String {
  "https://yandex.com/maps/?text=" <> uri.percent_encode(query)
}

pub fn osm_text_search(query: String) -> String {
  "https://www.openstreetmap.org/search?query=" <> uri.percent_encode(query)
}
