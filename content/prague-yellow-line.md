Title: Prague Yellow Line Walk
Date: 19.11.2023
Modified: 19.11.2023
Status: draft
Tags: sport, prague, yellow line
Keywords: sport, prague, yellow line
Slug: prague-yellow-line
Author: Andrey Albershtein
Summary: How I walked along Prague's Yellow Metro Line in a day
Lang: en

Quite often I like to walk from Zličín to Nové Butovice. This path has a really
nice part starting somewhere on Stodůlky up until Nové Butovice. This is A
bicycle path.

A few times I went to Anděl and even Národní třída. I though - well, can I go up
to Černý Most? Can I walk the whole yellow metro line?

So, on Saturday 18th November I decided to go. I took:

- bottle of water,
- headphones,
- fully charged phone,
- list of podcast episodes to listen,
- <img width="16px" src="../static/prague-yellow-line/mapycz-icon.png"> [mapy.cz][1] app,
  with downloaded Prague map, to track my walk
- a few medical patches in case of blister,
- and two apples to eat

I went without any stops (except traffic lights) for **5 hours 58 minutes** in
total covering **27.8 km**.

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
    crossorigin=""/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
    integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
    crossorigin=""></script>
<div id="map"></div>

Google Fit says that over this walk I spent `~1600 calories` which is
incredible. I calculated that I need about 2000 to 2300 calories to stay in the
current weight. So, 1600 is more than 2/3 of my daily needs.

Somewhere near Radlická I started feeling some muscles wanting to rest. Passing
Vysočanská my legs were really hurting and I was thinking about making a short
stop, but it wasn't thaaat bad. Of course, all of that was only muscle pain, no
joints or strange unpleasant feelings.

Overall, this was an interesting experience. Now I thinking about going along
Green and Red lines; both of them are shorter. In terms of joy, I think it's too
long. My mind was really enjoying first 2 hours of the walk but then I needed to
focus much more than is pleasant for a walk. I blame it on two things:

- the fact that in about 2 hours I got to the city center, where I had to be
  careful in the crowd.
- Second thing is that muscle pain become really noticeable which quite
  destructing.

<style>
#map {
    padding-top: 60%;
    max-width: 1150px;
    margin-bottom: 20px;
    max-height: 50vw;
}

.leaflet-control-attribution {
    display: none;
}

.leaflet-container {
    background-color:rgba(255,0,0,0.0);
}

.leaflet-layer {
    filter: brightness(0.6) invert(1) contrast(3) hue-rotate(200deg) saturate(0.3) brightness(0.7);
}

.leaflet-popup {
    margin-bottom: 10px;
}

.leaflet-popup-tip-container {
    display: none;
}

.leaflet-popup-content-wrapper {
    background: transparent;
    box-shadow: none;
}

.leaflet-popup-close-button {
    display: none;
}

.leaflet-popup-content {
    margin: 0;
}

#popup {
    --gap: 5px;
    --border-size: 1px;
    --width: 200px;
    --text-color: #ff6204;
    --background: #282c35;
    max-width: 100vw;
    border-radius: var(--gap);
    box-shadow: var(--gap) var(--text-color);
    display:nnone;
}

#popup a {
    text-decoration: none;
    color: var(--text-color);
}

#popup-figure {
    width: 100%;
    margin: 0;
}

#popup-image {
    border: var(--border-size) solid var(--background);
    border-top-left-radius: var(--gap);
    border-top-right-radius: var(--gap);
    box-sizing: border-box;
    max-width: var(--width);
    max-height: var(--width);
    width: 100%;
    height: auto;
}

#popup-figcaption {
    border: var(--border-size) solid var(--background);
    max-width: var(--width);
    box-sizing: border-box;
    padding: var(--gap);
    font-family: "Sans Serif";
    background-color: var(--background);
    border-bottom-left-radius: var(--gap);
    border-bottom-right-radius: var(--gap);
}

.leaflet-marker-icon {
  background: #ff6204;
  box-shadow: black 0px 0px 2px;
  padding: 0px 1px !important;
  border-radius: 5px;
}

</style>
<script>
  // Create Map instance
  var map = L.map('map', {
    zoomSnap: 0.1,
    zoomDelta: 0.1,
    zoomControl: false
  }).setView([50.080786, 14.428592], 12);

  // Add tile layer to the map
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '',
  }).addTo(map);

  // Load and add track to the map
  // TODO remove ../ when published!
  fetch("../static/prague-yellow-line/tracks.geojson")
  .then(response => response.json())
  .then(json => {
      route = L.geoJSON(json, {
        style: function (feature) {
            return {color: "#ff6204"};
        }
        })
      map.fitBounds(route.getBounds())
      route.addTo(map)
    }
  );

  // Add images to the map
  function addImage(image, msg) {
      var metadata = fetch(image + ".json")
        .then(response => response.json())
        .then(json => {
            json = json[0];
            var latlng = [parseFloat(json["GPSLatitude"]),
                        parseFloat(json["GPSLongitude"])];

    var photoIcon = L.icon({
        iconUrl: '../static/prague-yellow-line/photo_icon.png',
        iconSize:     [24, 24], // size of the icon
        iconAnchor:   [12, 12], // point of the icon which will correspond to marker's location
        popupAnchor:  [12, -12] // point from which the popup should open relative to the iconAnchor
    });

    var marker = L.marker(latlng, {icon: photoIcon})
        .addTo(map);

    var popupContent = `
    <div id="popup">
      <a href="#">
        <figure id="popup-figure">
          <img id="popup-image" src="${image}">
          <figcaption id="popup-figcaption">
            ${msg}
          </figcaption>
        </figure>
      </a>
    </div>
    `

    var popup = L.popup()
        .setLatLng(latlng)
        .setContent(popupContent);

    marker.bindPopup(popup);
        });


  }

    var arrowIcon = L.icon({
        iconUrl: '../static/prague-yellow-line/arrow.png',
        iconSize:     [24, 24], // size of the icon
        iconAnchor:   [12, 12], // point of the icon which will correspond to marker's location
        popupAnchor:  [12, -12] // point from which the popup should open relative to the iconAnchor
    });
  var coords = L.latLng(0, 0);
    L.marker(coords, {icon: arrowIcon}).addTo(map);
L.marker(coords, {
  icon: L.divIcon({
      html: "Null Island",
      className: 'text-below-marker',
    })
}).addTo(map);

  addImage('../static/prague-yellow-line/andel_river_repairs.jpg',
            'Repair works on the Vltava\'s weir')
  addImage('../static/prague-yellow-line/andel_river_repairs_2.jpg',
            'Repair works on the Vltava\'s weir from other spot')
  addImage('../static/prague-yellow-line/cerny_most_station.jpg',
            'Inside of Černý Most station')
  addImage('../static/prague-yellow-line/cerny_most_yellow_path.jpg',
            'Almost there!')
  addImage('../static/prague-yellow-line/invalidovna_hands.jpg',
            'The building with hands designed by David Černý')
  addImage('../static/prague-yellow-line/invalidovna_woman.jpg',
            'Woman by David Černý. So cool!')
  addImage('../static/prague-yellow-line/krizikova.jpg',
            'Just an entrance to the Křižíkova station')
  addImage('../static/prague-yellow-line/rajska_zahrada_yellow_path.jpg',
            'Really great walk/bike path on top of the metro (rather Soviet style)')

</script>

[1]: https://play.google.com/store/apps/details?id=cz.seznam.mapy
