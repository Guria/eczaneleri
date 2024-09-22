import birl
import eczaneleri/common/types.{type Eczane}
import eczaneleri/common/utils
import gleam/erlang/os
import gleam/float
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleroglero/outline
import lustre/attribute
import lustre/element
import sketch
import sketch/lustre as sketch_lustre
import sketch/lustre/element as sketch_element
import sketch/lustre/element/html
import sketch/size.{px}

pub fn is_ci() -> Bool {
  result.unwrap(os.get_env("CI"), "false") == "true"
}

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

fn posthog_script() {
  case is_ci() {
    True ->
      html.script_([], [
        html.text(
          "
    !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split('.');2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement('script')).type='text/javascript',p.async=!0,p.src=s.api_host.replace('.i.posthog.com','-assets.i.posthog.com')+'/static/array.js',(r=t.getElementsByTagName('script')[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a='posthog',u.people=u.people||[],u.toString=function(t){var e='posthog';return'posthog'!==a&&(e+='.'+a),t||(e+=' (stub)'),e},u.people.toString=function(){return u.toString(1)+'.people (stub)'},o='init capture register register_once register_for_session unregister unregister_for_session getFeatureFlag getFeatureFlagPayload isFeatureEnabled reloadFeatureFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSessionId getSurveys getActiveMatchingSurveys renderSurvey canRenderSurvey getNextSurveyStep identify setPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException loadToolbar get_property getSessionProperty createPersonProfile opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing clear_opt_in_out_capturing debug'.split(' '),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
    posthog.init('phc_1nrDGkBiA8RYx7u22I6YYjhzrKuFnjxPZgOXzTnPah3',{api_host:'https://eu.i.posthog.com', person_profiles: 'always'})
    ",
        ),
      ])
    False -> html.text("")
  }
}

fn build_head(province: String) {
  html.head([], [
    html.meta([attribute.accept_charset(["utf-8"])]),
    html.meta([
      attribute.name("viewport"),
      attribute.attribute("content", "width=device-width, initial-scale=1.0"),
    ]),
    html.title([], province <> " Eczaneleri"),
    posthog_script(),
    ..social_meta_tags(province)
  ])
}

fn social_meta_tags(province: String) {
  [
    html.meta([
      attribute.property("property", "og:title"),
      attribute.property("content", province <> " Eczaneleri"),
    ]),
    html.meta([
      attribute.property("property", "og:description"),
      attribute.property("content", "Find pharmacies on duty in " <> province),
    ]),
    html.meta([
      attribute.property("property", "og:image"),
      attribute.property("content", "/eczane.png"),
    ]),
    html.meta([
      attribute.property("property", "og:type"),
      attribute.property("content", "website"),
    ]),
    html.meta([
      attribute.name("twitter:card"),
      attribute.attribute("content", "summary_large_image"),
    ]),
    html.meta([
      attribute.name("twitter:title"),
      attribute.attribute("content", province <> " Pharmacies on Duty"),
    ]),
    html.meta([
      attribute.name("twitter:description"),
      attribute.attribute("content", "Find pharmacies on duty in " <> province),
    ]),
    html.meta([
      attribute.name("twitter:image"),
      attribute.attribute("content", "/eczane.png"),
    ]),
  ]
}

fn build_body(
  province: String,
  grouped_eczaneleri: List(#(String, List(Eczane))),
  update_time: birl.Time,
) {
  html.body(body_styles(), [], [
    main_container(province, grouped_eczaneleri),
    footer(update_time),
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
  html.main(
    sketch.class([
      sketch.max_width(px(1200)),
      sketch.margin_("auto"),
      sketch.padding(px(10)),
    ]),
    [],
    [page_title(province), district_list(grouped_eczaneleri)],
  )
}

fn footer(update_time: birl.Time) {
  let assert Ok(istanbul_time) =
    birl.set_timezone(update_time, "Europe/Istanbul")

  let formatted_time =
    birl.to_naive_date_string(istanbul_time)
    <> " "
    <> birl.to_naive_time_string(istanbul_time)

  html.footer(
    sketch.class([
      sketch.text_align("center"),
      sketch.padding(px(10)),
      sketch.font_size(px(14)),
    ]),
    [],
    [html.text("Last updated: " <> formatted_time)],
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
    [html.text(province <> " Pharmacies on Duty")],
  )
}

fn district_list(grouped_eczaneleri: List(#(String, List(Eczane)))) {
  html.div(
    sketch.class([sketch.margin_top(px(20))]),
    [],
    list.map(grouped_eczaneleri, fn(group) {
      let #(district, eczaneler) = group
      html.details(
        sketch.class([sketch.margin_bottom(px(20)), sketch.border("none")]),
        [attribute.open(True)],
        [district_title(district), eczane_grid(eczaneler)],
      )
    }),
  )
}

fn district_title(district: String) {
  html.summary(
    sketch.class([
      sketch.color("#2c3e50"),
      sketch.padding(px(15)),
      sketch.font_size(px(20)),
      sketch.font_weight("bold"),
      sketch.cursor("pointer"),
      sketch.user_select("none"),
      sketch.transition("background-color 0.3s"),
      sketch.hover([sketch.background_color("#e0e0e0")]),
      sketch.border_bottom("2px solid #3498db"),
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
      sketch.gap(px(15)),
      sketch.padding_block(px(15)),
      sketch.padding_inline(px(0)),
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
      sketch.gap(px(10)),
    ]),
    [attribute.class("h-card")],
    [
      eczane_name(eczane.name),
      eczane_details(eczane),
      eczane_phone_and_whatsapp(eczane.phone),
      html.div(
        sketch.class([
          sketch.display("flex"),
          sketch.justify_content("space-between"),
          sketch.align_items("center"),
          sketch.flex_wrap("wrap"),
          sketch.gap(px(10)),
        ]),
        [],
        [
          html.div(
            sketch.class([
              sketch.display("flex"),
              sketch.align_items("center"),
              sketch.gap(px(5)),
              sketch.color("#34495e"),
              sketch.font_size(px(14)),
            ]),
            [],
            [
              html.span(
                sketch.class([
                  sketch.display("inline-flex"),
                  sketch.align_items("center"),
                  sketch.justify_content("center"),
                  sketch.width(px(20)),
                  sketch.height(px(20)),
                ]),
                [],
                [sketch_element.styled(outline.map())],
              ),
              html.text("See on map"),
            ],
          ),
          eczane_map_links(eczane),
        ],
      ),
    ],
  )
}

fn eczane_details(eczane: Eczane) {
  html.div(
    sketch.class([
      sketch.flex("1"),
      sketch.display("flex"),
      sketch.flex_direction("column"),
      sketch.gap(px(10)),
    ]),
    [],
    [eczane_address(eczane.address)],
  )
}

fn eczane_name(name: String) {
  html.h3(
    sketch.class([
      sketch.font_size(px(18)),
      sketch.margin_top(px(0)),
      sketch.margin_bottom(px(0)),
      sketch.color("#2c3e50"),
    ]),
    [attribute.class("p-name")],
    [html.text(name)],
  )
}

fn eczane_address(address: String) {
  html.div(
    sketch.class([
      sketch.display("flex"),
      sketch.align_items("flex-start"),
      sketch.gap(px(8)),
      sketch.color("#34495e"),
      sketch.font_size(px(14)),
      sketch.line_height("20px"),
    ]),
    [attribute.class("p-adr")],
    [
      html.span(
        sketch.class([
          sketch.display("inline-flex"),
          sketch.align_items("center"),
          sketch.justify_content("center"),
          sketch.width(px(20)),
          sketch.height(px(20)),
          sketch.flex_shrink(0.0),
        ]),
        [],
        [sketch_element.styled(outline.map())],
      ),
      html.span_([], [html.text(address)]),
    ],
  )
}

fn eczane_phone_and_whatsapp(phone: String) {
  html.div(
    sketch.class([
      sketch.display("flex"),
      sketch.align_items("center"),
      sketch.gap(px(8)),
      sketch.color("#34495e"),
    ]),
    [],
    [
      html.span(
        sketch.class([
          sketch.display("inline-flex"),
          sketch.align_items("center"),
          sketch.justify_content("center"),
          sketch.width(px(20)),
          sketch.height(px(20)),
          sketch.flex_shrink(0.0),
        ]),
        [],
        [sketch_element.styled(outline.phone())],
      ),
      html.a(
        sketch.class([
          sketch.color("#3498db"),
          sketch.text_decoration("none"),
          sketch.transition("color 0.3s"),
          sketch.font_size(px(14)),
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
              sketch.margin_left(px(8)),
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
      sketch.display("inline-flex"),
      sketch.align_items("center"),
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
      sketch.gap(px(5)),
    ]),
    [attribute.href(url), attribute.target("_blank")],
    [html.span_([], [html.text(text)])],
  )
}
