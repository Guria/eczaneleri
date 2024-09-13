import eczaneleri/common/types.{type Position, Position}
import gleam/float
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/string
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

pub fn whatsapp_link(phone: String) -> String {
  let cleaned_phone = clean_phone(phone)

  let whatsapp_phone = case string.starts_with(cleaned_phone, "90") {
    True -> cleaned_phone
    False -> "90" <> cleaned_phone
  }

  "https://wa.me/" <> whatsapp_phone
}

pub fn is_mobile_phone(phone: String) -> Bool {
  let cleaned_phone = clean_phone(phone)
  let assert Ok(regex) =
    regex.compile(
      "^(90|0)?5[0-9]{9}$",
      with: regex.Options(case_insensitive: False, multi_line: False),
    )
  regex.check(regex, cleaned_phone)
}

pub fn clean_phone(phone: String) -> String {
  let assert Ok(regex) =
    regex.compile(
      "[^0-9]",
      with: regex.Options(case_insensitive: False, multi_line: False),
    )
  regex.replace(regex, phone, "")
}
