# eczaneleri

Static website for pharmacy (eczane) locations in Turkey.
Currently parsing and publishing is done only for Antalya.

See website as [GH pages](https://guria.github.io/eczaneleri/).

## Current Features

- Web scraping of pharmacy data for Antalya
- Static site generation with responsive design
- Integration with map services (Google Maps, Yandex Maps, OpenStreetMap)
- Client-side location-based distance calculation
- WhatsApp integration for mobile numbers
- Social media meta tags for better sharing

## Tech Stack

- Backend: Gleam (compiles to Erlang)
- Frontend: HTML/CSS (generated via Gleam), JavaScript
- Libraries: chrobot, birl, lustre, sketch, simplifile, snag

## TODO

- [x] Basic scraping and page generation for Antalya
- [x] Responsive design
- [x] Map service integrations
- [x] Client-side distance calculation
- [ ] Organize codebase for scalability
- [ ] Parse all provinces in Turkey
- [ ] Generate pages for all provinces
- [ ] Use lustre SSG for more advanced static site generation
- [ ] Enhance FE logic to find closest pharmacy by location
- [ ] Implement pagination or lazy loading for larger datasets
- [ ] Add comprehensive error handling
- [ ] Create a configuration file for easy customization
- [ ] Develop a test suite (unit and integration tests)
- [ ] Improve inline documentation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your chosen license here]
