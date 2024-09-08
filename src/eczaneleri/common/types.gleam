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
