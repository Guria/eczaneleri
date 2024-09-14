import eczaneleri/common/types.{type Eczane, type ParseResult}
import eczaneleri/html_builder/page
import gleam/dict
import gleam/list
import gleam/order
import gleam/string

pub fn build_page(parse_result: ParseResult) -> String {
  let grouped_eczaneleri = group_and_sort_eczaneleri(parse_result.eczaneleri)
  page.build_page("Antalya", grouped_eczaneleri, parse_result.update_time)
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
