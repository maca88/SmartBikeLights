import React from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import App from './App';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns'
import { LocalizationProvider } from '@mui/x-date-pickers';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';

const root = createRoot(document.getElementById("root"));

root.render(
  <React.StrictMode>
    <LocalizationProvider dateAdapter={AdapterDateFns}>
      <DndProvider backend={HTML5Backend}>
        <App />
      </DndProvider>
    </LocalizationProvider>
  </React.StrictMode>
);
