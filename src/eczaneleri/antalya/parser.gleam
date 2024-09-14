import chrobot
import eczaneleri/common/types.{type Eczane, type Position, Eczane, Position}
import eczaneleri/common/utils
import gleam/io
import gleam/list
import gleam/option.{type Option, None}
import gleam/result
import snag.{type Snag}
import snag/helpers.{map_error_to_snag}

pub fn parse_eczaneleri(page) -> Result(List(Eczane), Snag) {
  io.println("Starting to parse Antalya eczaneleri")
  use container <- result.try(
    chrobot.await_selector(page, ".acilistaGizle")
    |> map_error_to_snag("Failed to find main container"),
  )
  io.println("Found main container")
  use ilce_container <- result.try(
    chrobot.select_all_from(page, container, ".ilce")
    |> map_error_to_snag("Failed to find ilce container"),
  )

  ilce_container
  |> list.try_map(fn(ilce) {
    use ilce_name <- result.try(parse_ilce_name(page, ilce))
    io.println("Parsing ilce: " <> ilce_name)
    use eczane_container <- result.try(
      chrobot.select_all_from(page, ilce, ".nobetciDiv")
      |> map_error_to_snag("Failed to find eczane container"),
    )

    eczane_container
    |> list.try_map(fn(eczane) {
      use eczane_name <- result.try(parse_eczane_name(page, eczane))
      io.println("Parsing eczane: " <> eczane_name)
      {
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
      }
      |> snag.context("Failed to parse eczane: " <> eczane_name)
    })
    |> snag.context("Failed to parse eczane in " <> ilce_name)
  })
  |> result.map(list.flatten)
  |> snag.context("Failed to parse eczaneleri")
}

fn parse_ilce_name(page, ilce) -> Result(String, Snag) {
  use ilce_name_header <- result.try(
    chrobot.select_from(page, ilce, ".ilcebas")
    |> map_error_to_snag("Failed to find ilce name header"),
  )
  chrobot.get_text(page, ilce_name_header)
  |> map_error_to_snag("Failed to parse ilce name")
}

fn parse_eczane_name(page, eczane) -> Result(String, Snag) {
  use eczane_name_element <- result.try(
    chrobot.select_from(
      page,
      eczane,
      ".nobetciDiv>div:first-child>div>a:first-child",
    )
    |> map_error_to_snag("Failed to find eczane name element"),
  )
  chrobot.get_text(page, eczane_name_element)
  |> map_error_to_snag("Failed to parse eczane name")
}

fn parse_eczane_tel(page, eczane) -> Result(String, Snag) {
  use eczane_tel_element <- result.try(
    chrobot.select_from(
      page,
      eczane,
      ".nobetciDiv>div:first-child>div>a:last-child",
    )
    |> map_error_to_snag("Failed to find eczane tel element"),
  )
  chrobot.get_text(page, eczane_tel_element)
  |> map_error_to_snag("Failed to parse eczane tel")
}

fn parse_eczane_adres(page, eczane) -> Result(String, Snag) {
  use eczane_adres_element <- result.try(
    chrobot.select_from(page, eczane, ".nobetciDiv>div:last-child>div")
    |> map_error_to_snag("Failed to find eczane adres element"),
  )
  chrobot.get_text(page, eczane_adres_element)
  |> map_error_to_snag("Failed to parse eczane adres")
}

fn parse_coordinates(page, eczane) -> Result(Option(Position), Snag) {
  case chrobot.select_from(page, eczane, ".nobetciDiv>div:last-child>div>a") {
    Ok(link_element) -> {
      case chrobot.get_attribute(page, link_element, "href") {
        Ok(href) -> Ok(utils.parse_coordinates_from_google_maps_link(href))
        Error(err) ->
          map_error_to_snag(Error(err), "Failed to get href attribute")
      }
    }
    Error(_) -> Ok(None)
  }
}
