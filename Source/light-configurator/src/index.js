import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import DateFnsAdapter from '@mui/lab/AdapterDateFns';
import LocalizationProvider from '@mui/lab/LocalizationProvider';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';

ReactDOM.render(
  <React.StrictMode>
    <LocalizationProvider dateAdapter={DateFnsAdapter}>
      <DndProvider backend={HTML5Backend}>
        <App />
      </DndProvider>
    </LocalizationProvider>
  </React.StrictMode>,
  document.getElementById('root')
);
