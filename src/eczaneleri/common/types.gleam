import birl
import gleam/option.{type Option}

pub type Position {
  Position(latitude: Float, longitude: Float)
}

pub type Eczane {
  Eczane(
    name: String,
    address: String,
    phone: String,
    province: String,
    district: String,
    coordinates: Option(Position),
  )
}

pub type ParseResult {
  ParseResult(eczaneleri: List(Eczane), update_time: birl.Time)
}
