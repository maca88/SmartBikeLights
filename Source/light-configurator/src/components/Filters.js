import React, { useEffect } from 'react';
import Grid from '@mui/material/Grid';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import BatteryFilter from '../filters/BatteryFilter';
import NumberFilter from '../filters/NumberFilter';
import SpeedFilter from '../filters/SpeedFilter';
import GpsAccuracyFilter from '../filters/GpsAccuracyFilter';
import TimerStateFilter from '../filters/TimerStateFilter';
import TimespanFilter from '../filters/TimespanFilter';
import PositionFilter from '../filters/PositionFilter';
import BikeRadarFilter from '../filters/BikeRadarFilter';
import StartLocationFilter from '../filters/StartLocationFilter';
import ProfileNameFilter from '../filters/ProfileNameFilter';
import { AppContext } from '../AppContext';
import { action } from 'mobx';
import { arrayMoveUp, arrayMoveDown } from '../constants';
import { Typography } from '@mui/material';

export default observer(({ filters, filterTypes, device }) => {
  const removeFilter = action((filter) => {
    filters.remove(filter);
  });
  const handleChange = (filter) => {
    filter.setOpen(!filter.open);
  };
  const canMoveUpFilter = (filter) => {
    return filters.indexOf(filter) > 0;
  };
  const moveUpFilter = action((filter) => {
    arrayMoveUp(filters, filter);
  });
  const canMoveDownFilter = (filter) => {
    return filters.indexOf(filter) < (filters.length - 1);
  };
  const moveDownFilter = action((filter) => {
    arrayMoveDown(filters, filter);
  });

  return filters.map(filter => (
    <Accordion key={filter.id}
      TransitionProps={{ unmountOnExit: true }}
      expanded={filter.open}
      onChange={() => handleChange(filter)}>
      <AppContext.Consumer>
        {(context) => (
          <AccordionSummary
            item={filter}
            param1={context.configuration}
            removeLabel="Remove filter"
            removeCallback={removeFilter}
            validationParameter={device}
            canMoveUpCallback={canMoveUpFilter}
            moveUpCallback={moveUpFilter}
            canMoveDownCallback={canMoveDownFilter}
            moveDownCallback={moveDownFilter}
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
              : filter.type === 'A' ? <NumberFilter
                                        label="% per second"
                                        filter={filter}
                                        note={
                                          <Typography>
                                          NOTE: Acceleration is calculated once per second by calculating the difference between the current and previous (one second ago) speed
                                          in percentage (%). When decelerating, the calculated value will be negative, which means that this filter can be also used for braking
                                          by setting a negative value (e.g. Lower than -20%).
                                          </Typography>
                                        }
                                      />
              : filter.type === 'C' ? <SpeedFilter filter={filter} />
              : filter.type === 'G' ? <GpsAccuracyFilter filter={filter} />
              : filter.type === 'H' ? <TimerStateFilter filter={filter} />
              : filter.type === 'I' ? <BikeRadarFilter filter={filter} />
              : filter.type === 'J' ? <StartLocationFilter filter={filter} />
              : filter.type === 'K' ? <ProfileNameFilter filter={filter} />
              : filter.type === 'L' ? <NumberFilter
                                        label="Gradient %"
                                        filter={filter}
                                        note={
                                          <Typography>
                                          NOTE: Works only when an activity is running. The value will be negative when cycling downhill and positive when cycling uphill.
                                          </Typography>
                                        }
                                      />
              : filter.type === 'M' ? <NumberFilter
                                      label="Solar intensity"
                                      filter={filter}
                                      note={
                                        <Typography>
                                        NOTE: Works only for solar models. Value from 0-100 describes the solar sensor's charge efficiency. When the device is not charging by using solar sensor
                                        (e.g. device too hot/cold or full battery), the value will be negative.
                                        </Typography>
                                      }
                                    />
              : null
            }
          </Grid>
        </Grid>
      </AccordionDetails>
    </Accordion>
  ));
});
