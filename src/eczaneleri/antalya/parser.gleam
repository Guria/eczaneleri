import chrobot
import chrobot/chrome
import chrobot/protocol/runtime
import eczaneleri/common/types.{type Eczane, type Position, Eczane, Position}
import eczaneleri/common/utils
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None}
import gleam/result

pub fn parse_eczaneleri(
  page: chrobot.Page,
) -> Result(List(Eczane), chrome.RequestError) {
  io.println("Starting to parse eczaneleri")
  use container <- result.try(chrobot.await_selector(page, ".acilistaGizle"))
  io.println("Found main container")
  use ilce_container <- result.try(chrobot.select_all_from(
    page,
    container,
    ".ilce",
  ))

  ilce_container
  |> list.try_map(fn(ilce) {
    use ilce_name <- result.try(parse_ilce_name(page, ilce))
    io.println("Parsing ilce: " <> ilce_name)
    use eczane_container <- result.try(chrobot.select_all_from(
      page,
      ilce,
      ".nobetciDiv",
    ))

    eczane_container
    |> list.try_map(fn(eczane) {
      use eczane_name <- result.try(parse_eczane_name(page, eczane))
      use eczane_tel <- result.try(parse_eczane_tel(page, eczane))
      use eczane_adres <- result.try(parse_eczane_adres(page, eczane))
      use coordinates <- result.try(parse_coordinates(page, eczane))

      Ok(Eczane(
        name: eczane_name,
        address: eczane_adres,
        phone: eczane_tel,
        province: "Antalya",
        district: ilce_name,
        coordinates: coordinates,
      ))
    })
  })
  |> result.map(list.flatten)
  |> result.map(fn(eczaneler) {
    io.println(
      "Parsed " <> int.to_string(list.length(eczaneler)) <> " eczaneler",
    )
    eczaneler
  })
}

fn parse_ilce_name(
  page: chrobot.Page,
  ilce: runtime.RemoteObjectId,
) -> Result(String, chrome.RequestError) {
  use ilce_name_header <- result.try(chrobot.select_from(page, ilce, ".ilcebas"))
  chrobot.get_text(page, ilce_name_header)
}

fn parse_eczane_name(
  page: chrobot.Page,
  eczane: runtime.RemoteObjectId,
) -> Result(String, chrome.RequestError) {
  use eczane_name_element <- result.try(chrobot.select_from(
    page,
    eczane,
    "div:first-child>div>a:first-child",
  ))
  chrobot.get_text(page, eczane_name_element)
}

fn parse_eczane_tel(
  page: chrobot.Page,
  eczane: runtime.RemoteObjectId,
) -> Result(String, chrome.RequestError) {
  use eczane_tel_element <- result.try(chrobot.select_from(
    page,
    eczane,
    "div:first-child>div>a:last-child",
  ))
  chrobot.get_text(page, eczane_tel_element)
}

fn parse_eczane_adres(
  page: chrobot.Page,
  eczane: runtime.RemoteObjectId,
) -> Result(String, chrome.RequestError) {
  use eczane_adres_element <- result.try(chrobot.select_from(
    page,
    eczane,
    "div:last-child>div",
  ))
  chrobot.get_text(page, eczane_adres_element)
}

fn parse_coordinates(
  page: chrobot.Page,
  eczane: runtime.RemoteObjectId,
) -> Result(Option(Position), chrome.RequestError) {
  case chrobot.select_from(page, eczane, "div:last-child>div>a") {
    Ok(link_element) -> {
      case chrobot.get_attribute(page, link_element, "href") {
        Ok(href) -> Ok(utils.parse_coordinates_from_google_maps_link(href))
        Error(err) -> Error(err)
      }
    }
    Error(_) -> Ok(None)
  }
}
