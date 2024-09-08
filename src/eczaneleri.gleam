import chrobot
import eczaneleri/antalya/html_builder
import eczaneleri/antalya/parser
import simplifile

pub fn main() {
  let assert Ok(browser) = chrobot.launch()
  use <- chrobot.defer_quit(browser)
  let assert Ok(page) =
    browser
    |> chrobot.open("https://www.antalyaeo.org.tr/tr/nobetci-eczaneler", 30_000)

  let assert Ok(eczaneleri) = parser.parse_eczaneleri(page)
  let eczane_page = html_builder.build_page(eczaneleri)
  simplifile.write("./priv/static/index.html", eczane_page)
}
