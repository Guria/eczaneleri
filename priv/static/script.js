function getDistance(lat1, lon1, lat2, lon2, unit) {
  if (lat1 == lat2 && lon1 == lon2) {
    return 0;
  } else {
    var radlat1 = (Math.PI * lat1) / 180;
    var radlat2 = (Math.PI * lat2) / 180;
    var theta = lon1 - lon2;
    var radtheta = (Math.PI * theta) / 180;
    var dist =
      Math.sin(radlat1) * Math.sin(radlat2) +
      Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
    if (dist > 1) {
      dist = 1;
    }
    dist = Math.acos(dist);
    dist = (dist * 180) / Math.PI;
    dist = dist * 60 * 1.1515;
    if (unit == "K") {
      dist = dist * 1.609344;
    }
    if (unit == "N") {
      dist = dist * 0.8684;
    }
    return dist;
  }
}

function requestLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        [...document.querySelectorAll(".h-card")].forEach((card) => {
          const latitude = card.querySelector(".p-latitude").innerText;
          const longitude = card.querySelector(".p-longitude").innerText;

          if (!latitude || !longitude) {
            return;
          }

          const distance = getDistance(
            position.coords.latitude,
            position.coords.longitude,
            latitude,
            longitude,
            "K"
          );

          const distanceValue = Intl.NumberFormat("en-US", {
            style: "unit",
            unit: "kilometer",
            maximumFractionDigits: 2,
          }).format(distance);

          card.querySelector(".p-distance").innerText = distanceValue;
        });
        document.querySelector("#get-distance-to-me").style.display = "none";
      },
      (error) => {
        console.log(error);
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0,
      }
    );
  } else {
    console.log("Geolocation is not supported by this browser.");
  }
}

window.addEventListener("load", () => {
  navigator.permissions.query({ name: "geolocation" }).then((permission) => {
    if (permission.state === "granted") {
      requestLocation();
    }
  });
});
