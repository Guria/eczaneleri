import eczaneleri/common/types.{type Eczane}
import eczaneleri/common/utils
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string
import lustre/attribute
import lustre/element
import sketch
import sketch/lustre as sketch_lustre
import sketch/lustre/element/html
import sketch/size.{px}

pub fn build_page(eczaneleri: List(Eczane)) -> String {
  let grouped_eczaneleri = group_and_sort_eczaneleri(eczaneleri)
  let assert Ok(cache) = sketch.cache(strategy: sketch.Ephemeral)
  sketch_lustre.ssr(view(grouped_eczaneleri), cache)
  |> element.to_document_string()
}

fn group_and_sort_eczaneleri(
  eczaneleri: List(Eczane),
) -> List(#(String, List(Eczane))) {
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
}

fn view(grouped_eczaneleri: List(#(String, List(Eczane)))) {
  html.html([], [
    html.head([], [
      html.meta([attribute.accept_charset(["utf-8"])]),
      html.title([], "Antalya Eczaneleri"),
    ]),
    html.body(body_styles(), [], [main_container(grouped_eczaneleri)]),
  ])
}

fn body_styles() {
  sketch.class([
    sketch.font_family("Arial, sans-serif"),
    sketch.background_color("#f0f0f0"),
    sketch.margin(px(0)),
    sketch.padding(px(20)),
  ])
}

fn main_container(grouped_eczaneleri: List(#(String, List(Eczane)))) {
  html.div(
    sketch.class([sketch.max_width(px(1200)), sketch.margin_("auto")]),
    [],
    [page_title(), district_list(grouped_eczaneleri)],
  )
}

fn page_title() {
  html.h1(
    sketch.class([sketch.text_align("center"), sketch.color("#333")]),
    [],
    [html.text("Antalya Nöbetçi Eczaneleri")],
  )
}

fn district_list(grouped_eczaneleri: List(#(String, List(Eczane)))) {
  html.div(
    sketch.class([sketch.margin_top(px(30))]),
    [],
    list.map(grouped_eczaneleri, fn(group) {
      let #(district, eczaneler) = group
      [district_title(district), eczane_grid(eczaneler)]
    })
      |> list.flatten,
  )
}

fn district_title(district: String) {
  html.h2(
    sketch.class([
      sketch.color("#2c3e50"),
      sketch.border_bottom("2px solid #3498db"),
      sketch.padding_bottom(px(10)),
      sketch.margin_bottom(px(20)),
    ]),
    [],
    [html.text(district)],
  )
}

fn eczane_grid(eczaneler: List(Eczane)) {
  html.div(
    sketch.class([
      sketch.display("grid"),
      sketch.grid_template_columns("repeat(auto-fill, minmax(300px, 1fr))"),
      sketch.gap(px(20)),
      sketch.margin_bottom(px(30)),
    ]),
    [],
    list.map(eczaneler, eczane_card),
  )
}

fn eczane_card(eczane: Eczane) {
  html.div(
    sketch.class([
      sketch.background_color("#fff"),
      sketch.border_radius(px(8)),
      sketch.box_shadow("0 2px 4px rgba(0, 0, 0, 0.1)"),
      sketch.padding(px(20)),
    ]),
    [],
    [
      eczane_name(eczane.name),
      eczane_address(eczane.address),
      eczane_phone(eczane.phone),
      eczane_map_links(eczane.coordinates),
    ],
  )
}

fn eczane_name(name: String) {
  html.h2(
    sketch.class([
      sketch.font_size(px(18)),
      sketch.margin_top(px(0)),
      sketch.color("#2c3e50"),
    ]),
    [],
    [html.text(name)],
  )
}

fn eczane_address(address: String) {
  html.p(
    sketch.class([
      sketch.margin(px(0)),
      sketch.margin_bottom(px(10)),
      sketch.color("#34495e"),
    ]),
    [],
    [html.text(address)],
  )
}

fn eczane_phone(phone: String) {
  html.p(
    sketch.class([
      sketch.margin(px(0)),
      sketch.margin_bottom(px(10)),
      sketch.color("#34495e"),
    ]),
    [],
    [
      html.a(
        sketch.class([
          sketch.color("#3498db"),
          sketch.text_decoration("none"),
          sketch.transition("color 0.3s"),
        ]),
        [attribute.href("tel:" <> phone)],
        [html.text(phone)],
      ),
    ],
  )
}

fn eczane_map_links(coordinates: option.Option(types.Position)) {
  case coordinates {
    Some(coords) -> {
      html.div(sketch.class([sketch.display("flex"), sketch.gap(px(10))]), [], [
        map_link("Google Maps", utils.google_maps_link(coords)),
        map_link("Yandex Maps", utils.yandex_maps_link(coords)),
      ])
    }
    None -> html.text("")
  }
}

fn map_link(text: String, url: String) {
  html.a(
    sketch.class([
      sketch.display("inline-block"),
      sketch.padding_block(px(8)),
      sketch.padding_inline(px(12)),
      sketch.background_color("#3498db"),
      sketch.color("#fff"),
      sketch.text_decoration("none"),
      sketch.border_radius(px(4)),
      sketch.transition("background-color 0.3s"),
    ]),
    [attribute.href(url), attribute.target("_blank")],
    [html.text(text)],
  )
}
