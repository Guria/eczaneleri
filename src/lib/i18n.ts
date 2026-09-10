export const locales = ["tr", "en", "ru", "de"] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = "tr";

/** BCP-47 tags used for date/number formatting per locale. */
const intlLocale: Record<Locale, string> = {
  tr: "tr-TR",
  en: "en-GB",
  ru: "ru-RU",
  de: "de-DE",
};

export interface Strings {
  /** <html lang> value. */
  htmlLang: string;
  /** Native name for the language switcher. */
  nativeName: string;
  /**
   * Short code shown on the language-switcher trigger (uppercased two-letter
   * tag, e.g. "TR"). Kept separate from htmlLang so the label can differ.
   */
  shortCode: string;
  pageTitle: string;
  metaDescription: string;
  onDutyCount: (n: number) => string;
  lastUpdated: string;
  viewList: string;
  viewMap: string;
  viewGroupLabel: string;
  locate: string;
  locating: string;
  locateSorted: string;
  locateFailed: string;
  locateUnsupported: string;
  /** Button label to leave nearest mode and restore district grouping. */
  showGrouped: string;
  /** Heading above the flat distance-ordered list. */
  nearestHeading: string;
  /** Polite live-region announcement after sorting. */
  nearestAnnounce: (n: number) => string;
  /** Announcement when district grouping is restored. */
  groupedAnnounce: string;
  /** Suffix after a distance value, e.g. "3.2 km away". */
  distanceSuffix: string;
  call: string;
  whatsapp: string;
  directionsGoogle: string;
  directionsYandex: string;
  directionsOsm: string;
  searchOnMap: string;
  directionsShort: string;
  /** Title of the map-service picker opened by the directions button. */
  directionsChooser: string;
  /** Accessible label for closing the directions picker. */
  close: string;
  listAriaLabel: string;
  mapAriaLabel: string;
  mapRegionLabel: string;
  /** Accessible label for the docked list of pharmacy cards on the map. */
  mapCardsLabel: string;
  /** Announced when a pharmacy is selected on the map. */
  mapSelectedAnnounce: (name: string) => string;
  footer: string;
  languageLabel: string;
  /** Opt-in ask inside the directions dialog. */
  telemetryOptIn: string;
  telemetryDetailsLabel: string;
  telemetryDetails: string;
}

export const translations: Record<Locale, Strings> = {
  tr: {
    htmlLang: "tr",
    nativeName: "Türkçe",
    shortCode: "TR",
    pageTitle: "Antalya Nöbetçi Eczaneler",
    metaDescription:
      "Antalya nöbetçi eczaneler — adres, telefon ve yol tarifi.",
    onDutyCount: (n) => `${n} nöbetçi eczane`,
    lastUpdated: "Son güncelleme",
    viewList: "Liste",
    viewMap: "Harita",
    viewGroupLabel: "Görünüm seçimi",
    locate: "En yakın",
    locating: "Konum alınıyor…",
    locateSorted: "Mesafeye göre sıralandı",
    locateFailed: "Konum alınamadı, tekrar dene",
    locateUnsupported: "Konum desteklenmiyor",
    showGrouped: "İlçeler",
    nearestHeading: "Size en yakın eczaneler",
    nearestAnnounce: (n) => `${n} eczane mesafeye göre sıralandı`,
    groupedAnnounce: "Eczaneler yeniden ilçelere göre gruplandı",
    distanceSuffix: "uzaklıkta",
    call: "Ara",
    whatsapp: "WhatsApp",
    directionsGoogle: "Google Yol Tarifi",
    directionsYandex: "Yandex",
    directionsOsm: "OpenStreetMap",
    searchOnMap: "Haritada Ara",
    directionsShort: "Yol Tarifi",
    directionsChooser: "Harita uygulaması seç",
    close: "Kapat",
    listAriaLabel: "Eczane listesi",
    mapAriaLabel: "Harita görünümü",
    mapRegionLabel: "Nöbetçi eczaneler haritası",
    mapCardsLabel: "Haritadaki eczaneler",
    mapSelectedAnnounce: (name) => `${name} seçildi`,
    footer:
      "Veriler Antalya Eczacı Odası kaynaklıdır. Acil durumda eczaneyi arayarak teyit ediniz.",
    languageLabel: "Dil",
    telemetryOptIn:
      "Hizmeti desteklemek için anonim kullanım istatistiklerini paylaşmak istiyorum.",
    telemetryDetailsLabel: "Neler paylaşılır?",
    telemetryDetails:
      "Hangi sayfaların görüntülendiği ve hangi düğmelerin kullanıldığı, tarayıcı ve cihaz türü. Yazdığınız içerikler, ad, adres veya telefon toplanmaz. Veriler yalnızca bu sitenin istatistikleri için AB'deki PostHog sunucularında işlenir. Kapatınca cihazınızda saklanan her şey anında silinir.",
  },
  en: {
    htmlLang: "en",
    nativeName: "English",
    shortCode: "EN",
    pageTitle: "Antalya On-Duty Pharmacies",
    metaDescription:
      "On-duty (night-time) pharmacies in Antalya — address, phone and directions.",
    onDutyCount: (n) => `${n} pharmacies on duty`,
    lastUpdated: "Last updated",
    viewList: "List",
    viewMap: "Map",
    viewGroupLabel: "View selection",
    locate: "Nearest",
    locating: "Getting your location…",
    locateSorted: "Sorted by distance",
    locateFailed: "Couldn't get location, try again",
    locateUnsupported: "Location not supported",
    showGrouped: "Districts",
    nearestHeading: "Pharmacies nearest to you",
    nearestAnnounce: (n) => `${n} pharmacies sorted by distance`,
    groupedAnnounce: "Pharmacies grouped by district again",
    distanceSuffix: "away",
    call: "Call",
    whatsapp: "WhatsApp",
    directionsGoogle: "Google Directions",
    directionsYandex: "Yandex",
    directionsOsm: "OpenStreetMap",
    searchOnMap: "Search on Map",
    directionsShort: "Directions",
    directionsChooser: "Choose a map app",
    close: "Close",
    listAriaLabel: "Pharmacy list",
    mapAriaLabel: "Map view",
    mapRegionLabel: "Map of on-duty pharmacies",
    mapCardsLabel: "Pharmacies on the map",
    mapSelectedAnnounce: (name) => `${name} selected`,
    footer:
      "Data sourced from the Antalya Chamber of Pharmacists. In an emergency, call the pharmacy to confirm.",
    languageLabel: "Language",
    telemetryOptIn:
      "I want to support the service by sharing anonymous usage statistics.",
    telemetryDetailsLabel: "What is shared?",
    telemetryDetails:
      "Which pages are viewed and which buttons are used, plus browser and device type. Nothing you type, and no names, addresses or phone numbers. Data is processed on PostHog servers in the EU, only for this site's usage statistics. Switching off erases everything stored on your device immediately.",
  },
  ru: {
    htmlLang: "ru",
    nativeName: "Русский",
    shortCode: "RU",
    pageTitle: "Дежурные аптеки Антальи",
    metaDescription:
      "Дежурные (ночные) аптеки в Анталье — адрес, телефон и маршрут.",
    onDutyCount: (n) => `Дежурят ${n} аптек`,
    lastUpdated: "Обновлено",
    viewList: "Список",
    viewMap: "Карта",
    viewGroupLabel: "Выбор вида",
    locate: "Ближайшая",
    locating: "Определяем местоположение…",
    locateSorted: "Отсортировано по расстоянию",
    locateFailed: "Не удалось определить, попробуйте ещё раз",
    locateUnsupported: "Геолокация не поддерживается",
    showGrouped: "Округа",
    nearestHeading: "Ближайшие к вам аптеки",
    nearestAnnounce: (n) => `${n} аптек отсортированы по расстоянию`,
    groupedAnnounce: "Аптеки снова сгруппированы по округам",
    distanceSuffix: "от вас",
    call: "Позвонить",
    whatsapp: "WhatsApp",
    directionsGoogle: "Маршрут в Google",
    directionsYandex: "Yandex",
    directionsOsm: "OpenStreetMap",
    searchOnMap: "Найти на карте",
    directionsShort: "Маршрут",
    directionsChooser: "Выберите карту",
    close: "Закрыть",
    listAriaLabel: "Список аптек",
    mapAriaLabel: "Вид карты",
    mapRegionLabel: "Карта дежурных аптек",
    mapCardsLabel: "Аптеки на карте",
    mapSelectedAnnounce: (name) => `Выбрана ${name}`,
    footer:
      "Данные предоставлены Палатой фармацевтов Антальи. В экстренном случае позвоните в аптеку для подтверждения.",
    languageLabel: "Язык",
    telemetryOptIn:
      "Хочу поддержать сервис, делясь анонимной статистикой использования.",
    telemetryDetailsLabel: "Что передаётся?",
    telemetryDetails:
      "Какие страницы просмотрены и какие кнопки нажаты, тип браузера и устройства. Вводимый текст, имена, адреса и телефоны не собираются. Данные обрабатываются на серверах PostHog в ЕС только для статистики этого сайта. При выключении всё сохранённое на устройстве удаляется сразу.",
  },
  de: {
    htmlLang: "de",
    nativeName: "Deutsch",
    shortCode: "DE",
    pageTitle: "Antalya Notdienstapotheken",
    metaDescription:
      "Notdienstapotheken in Antalya — Adresse, Telefon und Routenbeschreibung.",
    onDutyCount: (n) => `${n} Apotheken im Notdienst`,
    lastUpdated: "Aktualisiert",
    viewList: "Liste",
    viewMap: "Karte",
    viewGroupLabel: "Ansicht",
    locate: "Nächste",
    locating: "Standort wird ermittelt…",
    locateSorted: "Nach Entfernung sortiert",
    locateFailed: "Standort nicht ermittelbar, erneut versuchen",
    locateUnsupported: "Standort nicht unterstützt",
    showGrouped: "Bezirke",
    nearestHeading: "Die nächsten Apotheken",
    nearestAnnounce: (n) => `${n} Apotheken nach Entfernung sortiert`,
    groupedAnnounce: "Apotheken wieder nach Bezirk gruppiert",
    distanceSuffix: "entfernt",
    call: "Anrufen",
    whatsapp: "WhatsApp",
    directionsGoogle: "Google Maps-Route",
    directionsYandex: "Yandex",
    directionsOsm: "OpenStreetMap",
    searchOnMap: "Auf Karte suchen",
    directionsShort: "Route",
    directionsChooser: "Karten-App wählen",
    close: "Schließen",
    listAriaLabel: "Apothekenliste",
    mapAriaLabel: "Kartenansicht",
    mapRegionLabel: "Karte der Notdienstapotheken",
    mapCardsLabel: "Apotheken auf der Karte",
    mapSelectedAnnounce: (name) => `${name} ausgewählt`,
    footer:
      "Daten der Antalya Apothekerkammer. Rufen Sie im Notfall die Apotheke zur Bestätigung an.",
    languageLabel: "Sprache",
    telemetryOptIn:
      "Ich möchte den Service unterstützen, indem ich anonyme Nutzungsstatistiken teile.",
    telemetryDetailsLabel: "Was wird geteilt?",
    telemetryDetails:
      "Welche Seiten angesehen und welche Schaltflächen benutzt werden, dazu Browser- und Gerätetyp. Keine Eingaben, keine Namen, Adressen oder Telefonnummern. Verarbeitung auf PostHog-Servern in der EU, ausschließlich für Nutzungsstatistik dieser Seite. Beim Ausschalten wird alles auf dem Gerät Gespeicherte sofort gelöscht.",
  },
};

/** Path to the Antalya city page for a given locale. */
export function cityPath(locale: Locale): string {
  return locale === defaultLocale ? "/antalya" : `/${locale}/antalya`;
}

/** Root path for a given locale. */
export function rootPath(locale: Locale): string {
  return locale === defaultLocale ? "/" : `/${locale}/`;
}

/** Format an ISO timestamp for display in Europe/Istanbul for the locale. */
export function formatUpdatedAt(iso: string, locale: Locale): string {
  return new Intl.DateTimeFormat(intlLocale[locale], {
    dateStyle: "long",
    timeStyle: "short",
    timeZone: "Europe/Istanbul",
  }).format(new Date(iso));
}

/** Intl tag for use in client-side number/date formatting. */
export function getIntlLocale(locale: Locale): string {
  return intlLocale[locale];
}
