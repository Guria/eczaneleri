import birl
import eczaneleri/common/types.{type Eczane}
import eczaneleri/common/utils
import gleam/float
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element
import sketch
import sketch/lustre as sketch_lustre
import sketch/lustre/element as sketch_element
import sketch/lustre/element/html
import sketch/size.{px}

pub fn build_page(
  province: String,
  grouped_eczaneleri: List(#(String, List(Eczane))),
  update_time: birl.Time,
) -> String {
  let assert Ok(cache) = sketch.cache(strategy: sketch.Ephemeral)
  sketch_lustre.ssr(view(province, grouped_eczaneleri, update_time), cache)
  |> element.to_document_string()
}

fn view(
  province: String,
  grouped_eczaneleri: List(#(String, List(Eczane))),
  update_time: birl.Time,
) {
  html.html([], [
    build_head(province),
    build_body(province, grouped_eczaneleri, update_time),
  ])
}

fn build_head(province: String) {
  html.head([], [
    html.meta([attribute.accept_charset(["utf-8"])]),
    html.meta([
      attribute.name("viewport"),
      attribute.attribute("content", "width=device-width, initial-scale=1.0"),
    ]),
    html.title([], province <> " Eczaneleri"),
    html.script_([], [
      html.text(
        "
    !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split('.');2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement('script')).type='text/javascript',p.async=!0,p.src=s.api_host.replace('.i.posthog.com','-assets.i.posthog.com')+'/static/array.js',(r=t.getElementsByTagName('script')[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a='posthog',u.people=u.people||[],u.toString=function(t){var e='posthog';return'posthog'!==a&&(e+='.'+a),t||(e+=' (stub)'),e},u.people.toString=function(){return u.toString(1)+'.people (stub)'},o='init capture register register_once register_for_session unregister unregister_for_session getFeatureFlag getFeatureFlagPayload isFeatureEnabled reloadFeatureFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSessionId getSurveys getActiveMatchingSurveys renderSurvey canRenderSurvey getNextSurveyStep identify setPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException loadToolbar get_property getSessionProperty createPersonProfile opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing clear_opt_in_out_capturing debug'.split(' '),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
    posthog.init('phc_1nrDGkBiA8RYx7u22I6YYjhzrKuFnjxPZgOXzTnPah3',{api_host:'https://eu.i.posthog.com', person_profiles: 'always'})
    ",
      ),
    ]),
  ])
}

fn build_body(
  province: String,
  grouped_eczaneleri: List(#(String, List(Eczane))),
  update_time: birl.Time,
) {
  html.body(body_styles(), [], [
    main_container(province, grouped_eczaneleri, update_time),
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
  update_time: birl.Time,
) {
  html.div(
    sketch.class([
      sketch.max_width(px(1200)),
      sketch.margin_("auto"),
      sketch.padding(px(10)),
    ]),
    [],
    [
      title_with_update_time(province, update_time),
      district_list(grouped_eczaneleri),
    ],
  )
}

fn title_with_update_time(province: String, update_time: birl.Time) {
  html.div(
    sketch.class([
      sketch.display("flex"),
      sketch.justify_content("center"),
      sketch.align_items("center"),
      sketch.gap(px(10)),
      sketch.margin_bottom(px(20)),
    ]),
    [],
    [page_title(province), update_time_icon(update_time)],
  )
}

fn page_title(province: String) {
  html.h1(
    sketch.class([
      sketch.color("#333"),
      sketch.font_size(px(24)),
      sketch.margin(px(0)),
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
    [attribute.class("h-card")],
    [eczane_name(eczane.name), eczane_details(eczane), eczane_map_links(eczane)],
  )
}

fn eczane_details(eczane: Eczane) {
  html.div(sketch.class([sketch.flex("1"), sketch.margin_bottom(px(10))]), [], [
    eczane_address(eczane.address),
    eczane_phone_and_whatsapp(eczane.phone),
  ])
}

fn eczane_name(name: String) {
  html.h3(
    sketch.class([
      sketch.font_size(px(18)),
      sketch.margin_top(px(0)),
      sketch.margin_bottom(px(10)),
      sketch.color("#2c3e50"),
    ]),
    [attribute.class("p-name")],
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
    [attribute.class("p-adr")],
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
        [attribute.href("tel:" <> phone), attribute.class("p-tel")],
        [html.text(phone)],
      ),
      case utils.is_mobile_phone(phone) {
        True ->
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
          )
        False -> html.text("")
      },
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
          html.span(
            sketch.class([sketch.display("none")]),
            [attribute.class("p-geo")],
            [
              html.span_([attribute.class("p-latitude")], [
                html.text(coords.latitude |> float.to_string),
              ]),
              html.span_([attribute.class("p-longitude")], [
                html.text(coords.longitude |> float.to_string),
              ]),
            ],
          ),
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

fn update_time_icon(update_time: birl.Time) {
  let assert Ok(istanbul_time) =
    birl.set_timezone(update_time, "Europe/Istanbul")

  let formatted_time =
    birl.to_naive_date_string(istanbul_time)
    <> " "
    <> birl.to_naive_time_string(istanbul_time)

  html.div(
    sketch.class([
      sketch.display("inline-flex"),
      sketch.align_items("center"),
      sketch.cursor("pointer"),
    ]),
    [attribute.attribute("title", "Son güncelleme: " <> formatted_time)],
    [
      html.svg_(
        [
          attribute.width(24),
          attribute.height(24),
          attribute.attribute("viewBox", "0 0 24 24"),
          attribute.attribute("fill", "none"),
          attribute.attribute("stroke", "currentColor"),
          attribute.attribute("stroke-width", "2"),
          attribute.attribute("stroke-linecap", "round"),
          attribute.attribute("stroke-linejoin", "round"),
        ],
        [
          sketch_element.element_(
            "circle",
            [
              attribute.attribute("cx", "12"),
              attribute.attribute("cy", "12"),
              attribute.attribute("r", "10"),
            ],
            [],
          ),
          sketch_element.element_(
            "polyline",
            [attribute.attribute("points", "12 6 12 12 16 14")],
            [],
          ),
        ],
      ),
    ],
  )
}
