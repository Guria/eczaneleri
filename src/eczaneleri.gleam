import chrobot
import eczaneleri/antalya/html_builder
import eczaneleri/antalya/parser
import gleam/io
import simplifile

pub fn main() {
  io.println("Starting eczaneleri scraper")
  let assert Ok(browser) = chrobot.launch()
  io.println("Browser launched successfully")
  use <- chrobot.defer_quit(browser)
  let assert Ok(page) =
    browser
    |> chrobot.open("https://www.antalyaeo.org.tr/tr/nobetci-eczaneler", 30_000)
  io.println("Page opened successfully")

  let assert Ok(eczaneleri) = parser.parse_eczaneleri(page)
  io.println("Eczaneleri parsed successfully")
  let eczane_page = html_builder.build_page(eczaneleri)
  io.println("HTML page built")
  let assert Ok(_) = simplifile.write("./priv/static/index.html", eczane_page)
  io.println("HTML file written successfully")
}
