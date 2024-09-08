import eczaneleri/common/types.{type Eczane}
import eczaneleri/common/utils
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn build_page(eczaneleri: List(Eczane)) -> String {
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
                              attribute.href(utils.google_maps_link(coords)),
                              attribute.target("_blank"),
                              attribute.class("map-link"),
                            ],
                            [html.text("Google Maps")],
                          ),
                          html.a(
                            [
                              attribute.href(utils.yandex_maps_link(coords)),
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
