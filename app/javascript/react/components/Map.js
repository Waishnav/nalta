import React, { useEffect, useState, useRef } from "react";
import { MapContainer, Marker, Popup, TileLayer, useMap } from "react-leaflet";
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

const customIcon = new L.Icon({
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

function ChangeMapView({ center }) {
  const map = useMap();
  map.setView(center, map.getZoom());
  return null;
}

const ItineraryMap = ({ lat, long, timelineActiveIndex, data, showDay }) => {
  function calculateMapCenter(itineraries, day) {
    let latSum = 0;
    let lngSum = 0;
    let count = 0;

    const dayData = itineraries[day] || [];
    dayData.forEach((item) => {
      if (item.place && item.place.latitude && item.place.longitude) {
        latSum += parseFloat(item.place.latitude);
        lngSum += parseFloat(item.place.longitude);
        count++;
      }
    });

    return count > 0 ? [latSum / count, lngSum / count] : [lat, long];
  }

  const [location, setLocation] = useState([lat, long]);
  const markerRefs = useRef({});

  useEffect(() => {
    setLocation(calculateMapCenter(data, showDay));
  }, [data, showDay, lat, long]);

  useEffect(() => {
    const dayData = data[showDay] || [];
    if (typeof dayData[timelineActiveIndex]?.place === 'object') {
      setLocation([
        parseFloat(dayData[timelineActiveIndex].place.latitude),
        parseFloat(dayData[timelineActiveIndex].place.longitude)
      ]);
      
      // Open the popup for the active timeline item
      const marker = markerRefs.current[timelineActiveIndex];
      if (marker) {
        marker.openPopup();
      }
    }
  }, [timelineActiveIndex, showDay, data]);

  const dayData = data[showDay] || [];

  return (
    <MapContainer
      center={location}
      zoom={12}
      style={{ height: "100%", width: "100%" }}
    >
      <TileLayer
        attribution="Google Maps"
        url="https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}"
        maxZoom={20}
        subdomains={["mt0", "mt1", "mt2", "mt3"]}
      />
      <ChangeMapView center={location} />
      {dayData.map((item, index) => {
        if (item.place && typeof item.place === 'object' && item.place.latitude && item.place.longitude) {
          return (
            <Marker
              key={index}
              position={[parseFloat(item.place.latitude), parseFloat(item.place.longitude)]}
              icon={customIcon}
              ref={(ref) => markerRefs.current[index] = ref}
            >
              <Popup>
                <h3 className="text-2xl font-sans font-semibold">{item.place.name}</h3>
              </Popup>
            </Marker>
          );
        }
        return null;
      })}
    </MapContainer>
  );
};

export default ItineraryMap;
