import chrobot
import eczaneleri/antalya/html_builder
import eczaneleri/antalya/parser
import gleam/io
import gleam/result
import simplifile
import snag
import snag/helpers.{map_error_to_snag}

pub fn main() {
  case do_main() {
    Ok(_) -> io.println("Scraper completed successfully")
    Error(snag) -> io.print(snag.pretty_print(snag))
  }
}

fn do_main() {
  use browser <- result.try(launch_browser())
  use <- defer_quit(browser)
  use page <- result.try(open_page(
    browser,
    "https://www.antalyaeo.org.tr/tr/nobetci-eczaneler",
  ))
  use eczaneleri <- result.try(parser.parse_eczaneleri(page))
  let eczane_page = html_builder.build_page(eczaneleri)
  write_html(eczane_page)
}

fn launch_browser() {
  io.println("Launching browser")
  chrobot.launch()
  |> map_error_to_snag("Failed to launch browser")
}

fn open_page(browser, url) {
  io.println("Opening page")
  chrobot.open(browser, url, 5000)
  |> map_error_to_snag("Failed to open page")
}

fn write_html(html) {
  io.println("Writing html")
  simplifile.create_directory_all("./priv/static")
  |> map_error_to_snag("Failed to create directory")
  |> result.try(fn(_) {
    simplifile.write("./priv/static/index.html", html)
    |> map_error_to_snag("Failed to write html")
  })
}

fn defer_quit(browser, body: fn() -> Result(_, snag.Snag)) {
  body()
  |> result.map(fn(_) { chrobot.quit(browser) })
  |> result.map_error(fn(snag) {
    let _ = chrobot.quit(browser)
    snag
  })
}
