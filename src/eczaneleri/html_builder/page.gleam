import eczaneleri/common/types.{type Eczane}
import eczaneleri/common/utils
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element
import sketch
import sketch/lustre as sketch_lustre
import sketch/lustre/element/html
import sketch/size.{px}

pub fn build_page(
  province: String,
  grouped_eczaneleri: List(#(String, List(Eczane))),
) -> String {
  let assert Ok(cache) = sketch.cache(strategy: sketch.Ephemeral)
  sketch_lustre.ssr(view(province, grouped_eczaneleri), cache)
  |> element.to_document_string()
}

fn view(province: String, grouped_eczaneleri: List(#(String, List(Eczane)))) {
  html.html([], [
    html.head([], [
      html.meta([attribute.accept_charset(["utf-8"])]),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1.0"),
      ]),
      html.title([], province <> " Eczaneleri"),
    ]),
    html.body(body_styles(), [], [main_container(province, grouped_eczaneleri)]),
  ])
}

fn body_styles() {
  sketch.class([
    sketch.font_family("Arial, sans-serif"),
    sketch.background_color("#f0f0f0"),
    sketch.margin(px(0)),
    sketch.padding(px(10)),
    sketch.font_size(px(16)),
  ])
}

fn main_container(
  province: String,
  grouped_eczaneleri: List(#(String, List(Eczane))),
) {
  html.div(
    sketch.class([
      sketch.max_width(px(1200)),
      sketch.margin_("auto"),
      sketch.padding(px(10)),
    ]),
    [],
    [page_title(province), district_list(grouped_eczaneleri)],
  )
}

fn page_title(province: String) {
  html.h1(
    sketch.class([
      sketch.text_align("center"),
      sketch.color("#333"),
      sketch.font_size(px(24)),
      sketch.margin_bottom(px(20)),
    ]),
    [],
    [html.text(province <> " Nöbetçi Eczaneleri")],
  )
}

fn district_list(grouped_eczaneleri: List(#(String, List(Eczane)))) {
  html.div(
    sketch.class([sketch.margin_top(px(20))]),
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
      sketch.margin_bottom(px(15)),
      sketch.font_size(px(20)),
    ]),
    [],
    [html.text(district)],
  )
}

fn eczane_grid(eczaneler: List(Eczane)) {
  html.div(
    sketch.class([
      sketch.display("grid"),
      sketch.grid_template_columns("repeat(auto-fill, minmax(280px, 1fr))"),
      sketch.gap(px(15)),
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
      sketch.padding(px(15)),
      sketch.display("flex"),
      sketch.flex_direction("column"),
      sketch.min_height(px(180)),
    ]),
    [],
    [
      eczane_name(eczane.name),
      html.div(
        sketch.class([sketch.flex("1"), sketch.margin_bottom(px(10))]),
        [],
        [
          eczane_address(eczane.address),
          eczane_phone_and_whatsapp(eczane.phone),
        ],
      ),
      eczane_map_links(eczane),
    ],
  )
}

fn eczane_name(name: String) {
  html.h3(
    sketch.class([
      sketch.font_size(px(18)),
      sketch.margin_top(px(0)),
      sketch.margin_bottom(px(10)),
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
      sketch.margin_bottom(px(5)),
      sketch.color("#34495e"),
      sketch.font_size(px(14)),
    ]),
    [],
    [html.text(address)],
  )
}

fn eczane_phone_and_whatsapp(phone: String) {
  html.p(
    sketch.class([
      sketch.margin(px(0)),
      sketch.margin_bottom(px(5)),
      sketch.color("#34495e"),
      sketch.display("flex"),
      sketch.flex_wrap("wrap"),
      sketch.align_items("center"),
      sketch.gap(px(10)),
    ]),
    [],
    [
      html.a(
        sketch.class([
          sketch.color("#3498db"),
          sketch.text_decoration("none"),
          sketch.transition("color 0.3s"),
          sketch.font_size(px(16)),
        ]),
        [attribute.href("tel:" <> phone)],
        [html.text(phone)],
      ),
      html.a(
        sketch.class([
          sketch.color("#25D366"),
          sketch.text_decoration("none"),
          sketch.transition("color 0.3s"),
          sketch.font_size(px(14)),
          sketch.padding_block(px(2)),
          sketch.padding_inline(px(6)),
          sketch.border("1px solid #25D366"),
          sketch.border_radius(px(4)),
        ]),
        [attribute.href(utils.whatsapp_link(phone))],
        [html.text("WhatsApp")],
      ),
    ],
  )
}

fn eczane_map_links(eczane: Eczane) {
  case eczane.coordinates {
    Some(coords) -> {
      html.div(
        sketch.class([
          sketch.display("flex"),
          sketch.flex_wrap("wrap"),
          sketch.gap(px(10)),
          sketch.justify_content("flex-start"),
        ]),
        [],
        [
          map_link("Google", utils.google_maps_link(coords), False),
          map_link("Yandex", utils.yandex_maps_link(coords), False),
          map_link("OSM", utils.osm_link(coords), False),
        ],
      )
    }
    None -> {
      let query = eczane.name
      html.div(
        sketch.class([
          sketch.display("flex"),
          sketch.flex_wrap("wrap"),
          sketch.gap(px(10)),
          sketch.justify_content("flex-start"),
        ]),
        [],
        [
          map_link("Google", utils.google_maps_text_search(query), True),
          map_link("Yandex", utils.yandex_maps_text_search(query), True),
          map_link("OSM", utils.osm_text_search(query), True),
        ],
      )
    }
  }
}

fn map_link(text: String, url: String, is_text_search: Bool) {
  html.a(
    sketch.class([
      sketch.display("inline-block"),
      sketch.padding_block(px(6)),
      sketch.padding_inline(px(10)),
      sketch.background_color(case is_text_search {
        True -> "#e74c3c"
        False -> "#3498db"
      }),
      sketch.color("#fff"),
      sketch.text_decoration("none"),
      sketch.border_radius(px(4)),
      sketch.transition("background-color 0.3s"),
      sketch.font_size(px(14)),
    ]),
    [attribute.href(url), attribute.target("_blank")],
    [html.text(text)],
  )
}
