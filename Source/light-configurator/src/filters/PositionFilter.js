import { useEffect } from 'react';
import { MapContainer, TileLayer, useMap } from 'react-leaflet'
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';
import { action } from 'mobx';
import {featureGroup, polygon} from 'leaflet';
import 'leaflet/dist/leaflet.css';
import '@geoman-io/leaflet-geoman-free';
import '@geoman-io/leaflet-geoman-free/dist/leaflet-geoman.css';
import Polygon from '../models/Polygon';

const Polygons = observer(({ polygons }) => {
  const mappings = {};
  const handleDrawStart = e => {
    e.workingLayer.on('pm:vertexadded', e => {
      if (e.sourceTarget.getLatLngs().length >= 4) {
        map.pm.Draw.Polygon._finishShape(e);
      }
    });
  };
  const handleEdit = e => {
    const polygon = mappings[e.layer._leaflet_id];
    polygon.setVertexes(e.layer.getLatLngs()[0]);
  };
  const handleCreate = action(e => {
    const polygon = new Polygon(e.layer.getLatLngs()[0]);
    mappings[e.layer._leaflet_id] = polygon;
    polygons.push(polygon);
    e.layer.on('pm:edit', handleEdit);
  });
  const handleRemove = action(e => {
    const polygon = mappings[e.layer._leaflet_id];
    delete mappings[e.layer._leaflet_id];
    polygons.remove(polygon);
    e.layer.off('pm:edit', handleEdit);
  });
  const map = useMap();
  useEffect(() => {
    map.pm.setGlobalOptions({
      snappable: false,
      allowSelfIntersection: false,
      hideMiddleMarkers: true
    });
    map.pm.addControls({
      position: 'topleft',
      drawCircle: false,
      drawMarker: false,
      drawCircleMarker: false,
      drawRectangle: false,
      drawPolyline: false,
      cutPolygon: false
    });
    map.pm.Toolbar.changeActionsOfControl('Polygon', ['removeLastVertex', 'cancel']);
    // Subscribe to event
    map.on('pm:drawstart', handleDrawStart);
    map.on('pm:create', handleCreate);
    map.on('pm:remove', handleRemove);

    // Draw polygons
    var group = featureGroup();
    polygons.forEach(p => {
      const layer = polygon(p.vertexes).addTo(map);
      layer.on('pm:edit', handleEdit);
      mappings[layer._leaflet_id] = p;
      group.addLayer(layer)
    });
    // Center the view
    if (polygons.length) {
      map.fitBounds(group.getBounds());
    } else {
      map.locate();
      map.once('locationfound', e => {
        map.zoomIn(8);
        map.panTo(e.latlng);
      });
    }

    return function cleanup() {
      map.off('pm:drawstart', handleDrawStart);
      map.off('pm:create', handleCreate);
      map.off('pm:remove', handleRemove);
    };
  });

  return null;
});

const useStyles = makeStyles((theme) => ({
  map: {
    height: '400px'
  }
}));

export default observer(({ filter }) => {
  const classes = useStyles();
  return (
  <MapContainer className={classes.map} center={[0, 0]} zoom={0} scrollWheelZoom={true}>
    <TileLayer
      attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    />
    <Polygons polygons={filter.polygons} />
  </MapContainer>
  );
});