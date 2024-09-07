import chrobot
import gleam/dict
import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/regex
import gleam/result
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import simplifile

type Position {
  Position(latitude: Float, longitude: Float)
}

type Eczane {
  Eczane(
    name: String,
    address: String,
    phone: String,
    province: String,
    district: String,
    coordinates: Option(Position),
  )
}

pub fn main() {
  let assert Ok(browser) = chrobot.launch()
  use <- chrobot.defer_quit(browser)
  let assert Ok(page) =
    browser
    |> chrobot.open("https://www.antalyaeo.org.tr/tr/nobetci-eczaneler", 30_000)
  let assert Ok(container) = chrobot.await_selector(page, ".acilistaGizle")

  let assert Ok(ilce_container) =
    chrobot.select_all_from(page, container, ".ilce")

  let eczaneleri =
    list.map(ilce_container, fn(ilce) {
      let assert Ok(ilce_name_header) =
        chrobot.select_from(page, ilce, ".ilcebas")
      let assert Ok(ilce_name) = chrobot.get_text(page, ilce_name_header)
      let assert Ok(eczane_container) =
        chrobot.select_all_from(page, ilce, ".nobetciDiv")

      list.map(eczane_container, fn(eczane) {
        let assert Ok(eczane_name_element) =
          chrobot.select_from(page, eczane, "div:first-child>div>a:first-child")
        let assert Ok(eczane_name) = chrobot.get_text(page, eczane_name_element)
        let assert Ok(eczane_tel_element) =
          chrobot.select_from(page, eczane, "div:first-child>div>a:last-child")
        let assert Ok(eczane_tel) = chrobot.get_text(page, eczane_tel_element)
        let assert Ok(eczane_adres_element) =
          chrobot.select_from(page, eczane, "div:last-child>div")
        let assert Ok(eczane_adres) =
          chrobot.get_text(page, eczane_adres_element)

        let options = regex.Options(case_insensitive: False, multi_line: False)
        let assert Ok(regex) =
          // https://maps.google.com/maps?q=36.7891053615,31.4420337832
          regex.compile(
            "https://maps\\.google\\.com/maps\\?q=(?<latitude>[^,]+),(?<longitude>[^,]+)",
            with: options,
          )
        let coordinates = case
          chrobot.select_from(page, eczane, "div:last-child>div>a")
        {
          Ok(link_element) -> {
            case chrobot.get_attribute(page, link_element, "href") {
              Ok(href) -> {
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
              Error(_) -> None
            }
          }
          Error(_) -> None
        }

        Eczane(
          name: eczane_name,
          address: eczane_adres,
          phone: eczane_tel,
          province: "Antalya",
          district: ilce_name,
          coordinates: coordinates,
        )
      })
    })
    |> list.flatten

  let eczane_page = build_page(eczaneleri)
  simplifile.write("./priv/static/index.html", eczane_page)
}

fn build_page(eczaneleri: List(Eczane)) {
  let grouped_eczaneleri =
    list.group(eczaneleri, fn(eczane) { eczane.district })
    |> dict.to_list()
    |> list.sort(fn(a, b) {
      case a.0, b.0 {
        "Muratpaşa", _ -> order.Lt
        _, "Muratpaşa" -> order.Gt
        "Konyaaltı", _ -> order.Lt
        _, "Konyaaltı" -> order.Gt
        "Kepez", _ -> order.Lt
        _, "Kepez" -> order.Gt
        _, _ -> string.compare(a.0, b.0)
      }
    })

  html.html([], [
    html.head([], [
      html.meta([attribute.accept_charset(["utf-8"])]),
      html.title([], "Antalya Eczaneleri"),
      html.link([attribute.rel("stylesheet"), attribute.href("./styles.css")]),
    ]),
    html.body([], [
      html.div([attribute.class("container")], [
        html.h1([attribute.class("title")], [
          html.text("Antalya Nöbetçi Eczaneleri"),
        ]),
        html.div(
          [attribute.class("district-container")],
          list.map(grouped_eczaneleri, fn(group) {
            let #(district, eczaneler) = group
            [
              html.h2([attribute.class("district-title")], [html.text(district)]),
              html.div(
                [attribute.class("card-grid")],
                list.map(eczaneler, fn(eczane) {
                  html.div([attribute.class("card")], [
                    html.h2([attribute.class("card-title")], [
                      html.text(eczane.name),
                    ]),
                    html.p([attribute.class("card-address")], [
                      html.text(eczane.address),
                    ]),
                    html.p([attribute.class("card-phone")], [
                      html.a(
                        [
                          attribute.href("tel:" <> eczane.phone),
                          attribute.class("phone-link"),
                        ],
                        [html.text(eczane.phone)],
                      ),
                    ]),
                    case eczane.coordinates {
                      Some(coords) -> {
                        html.div([attribute.class("card-links")], [
                          html.a(
                            [
                              attribute.href(
                                "https://www.google.com/maps/search/?api=1&query="
                                <> float.to_string(coords.latitude)
                                <> ","
                                <> float.to_string(coords.longitude),
                              ),
                              attribute.target("_blank"),
                              attribute.class("map-link"),
                            ],
                            [html.text("Google Maps")],
                          ),
                          html.a(
                            [
                              attribute.href(
                                "https://yandex.com/maps/?pt="
                                <> float.to_string(coords.longitude)
                                <> ","
                                <> float.to_string(coords.latitude)
                                <> "&z=15&l=map",
                              ),
                              attribute.target("_blank"),
                              attribute.class("map-link"),
                            ],
                            [html.text("Yandex Maps")],
                          ),
                        ])
                      }
                      None -> html.text("")
                    },
                  ])
                }),
              ),
            ]
          })
            |> list.flatten,
        ),
      ]),
    ]),
  ])
  |> element.to_document_string()
}
