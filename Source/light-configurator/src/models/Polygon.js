import { makeAutoObservable } from 'mobx';

const round = (value) => {
  return Math.round(value * 1000000) / 1000000;
}

export default class Polygon {
  vertexes = [];
 
  constructor(vertexes) {
    makeAutoObservable(this, {
    });
    if (vertexes) {
      this.setVertexes(vertexes);
    }
  }

  setVertexes = (value) => {
    this.vertexes = value.map(p => [round(p.lat), round(p.lng)]);
  }
}