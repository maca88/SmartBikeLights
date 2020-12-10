import React from 'react';
import Grid from '@material-ui/core/Grid';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import BatteryFilter from '../filters/BatteryFilter';
import NumberFilter from '../filters/NumberFilter';
import SpeedFilter from '../filters/SpeedFilter';
import GpsAccuracyFilter from '../filters/GpsAccuracyFilter';
import TimespanFilter from '../filters/TimespanFilter';
import PositionFilter from '../filters/PositionFilter';
import { AppContext } from '../AppContext';
import { action } from 'mobx';

export default observer(({ filters, filterTypes }) => {
  const removeFilter = action((filter) => {
    filters.remove(filter);
  });
  const handleChange = (filter) => {
    filter.setOpen(!filter.open);
  };

  return filters.map(filter => (
    <Accordion key={filter.id}
      TransitionProps={{ unmountOnExit: true }}
      expanded={filter.open}
      onChange={() => handleChange(filter)}>
      <AppContext.Consumer>
        {(context) => (
          <AccordionSummary
            item={filter}
            param1={context}
            removeLabel="Remove filter"
            removeCallback={removeFilter}
          />
        )}
      </AppContext.Consumer>
      <AccordionDetails>
        <Grid container spacing={3}>
          <Grid item xs={12} sm={12}>
            <AppSelect items={filterTypes} required label="Type" setter={filter.setType} value={filter.type} />
          </Grid>
          <Grid item xs={12} sm={12}>
            {
              filter.type === 'E' ? <TimespanFilter filter={filter} />
              : filter.type === 'F' ? <PositionFilter filter={filter} />
              : filter.type === 'B' ? <BatteryFilter filter={filter} />
              : filter.type === 'A' ? <NumberFilter label="% per second" filter={filter} />
              : filter.type === 'C' ? <SpeedFilter filter={filter} />
              : filter.type === 'G' ? <GpsAccuracyFilter filter={filter} />
              : null
            }
          </Grid>
        </Grid>
      </AccordionDetails>
    </Accordion>
  ));
});