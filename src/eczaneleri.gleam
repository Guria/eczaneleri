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
    Ok(_) -> {
      io.println("Scraper completed successfully")
    }
    Error(snag) -> {
      io.print(snag.pretty_print(snag))
    }
  }
}

fn do_main() {
  use browser <- result.try(launch_browser())
  {
    use page <- result.try(open_page(
      browser,
      "https://www.antalyaeo.org.tr/tr/nobetci-eczaneler",
    ))
    use eczaneleri <- result.try(parser.parse_eczaneleri(page))
    let eczane_page = html_builder.build_page(eczaneleri)
    write_html(eczane_page)
  }
  |> result.try(fn(_) { quit_browser(browser) })
  |> result.map_error(fn(snag) {
    let _ = quit_browser(browser)
    snag
  })
}

fn launch_browser() {
  io.println("Launching browser")
  chrobot.launch()
  // |> result.try(fn(_) { Error(chrome.UnknowOperatingSystem) })
  |> map_error_to_snag("Failed to launch browser")
}

fn open_page(browser, url) {
  io.println("Opening page")
  chrobot.open(browser, url, 5000)
  // |> result.try(fn(_) { Error(chrome.PortError) })
  |> map_error_to_snag("Failed to open page")
}

fn write_html(html) {
  io.println("Writing html")
  simplifile.write("./priv/static/index.html", html)
  // |> result.try(fn(_) { Error(simplifile.Eacces) })
  |> map_error_to_snag("Failed to write html")
}

fn quit_browser(browser) {
  chrobot.quit(browser)
  |> map_error_to_snag("Failed to quit browser")
}
