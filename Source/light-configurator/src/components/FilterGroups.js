import React, { useEffect } from 'react';
import Grid from '@mui/material/Grid';
import List from '@mui/material/List';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import Typography from '@mui/material/Typography';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import AppTextInput from '../inputs/AppTextInput';
import AppSelect from '../inputs/AppSelect';
import FilterGroup from '../models/FilterGroup';
import Filter from '../models/Filter';
import Filters from './Filters';
import AddButton from './AddButton';
import { filterList, arrayMoveUp, arrayMoveDown } from '../constants';

const emptyFilters = [];
const getFilterTypes = (hasLightModes, device, totalLights) => {
  if (!device) {
    return emptyFilters;
  }

  const excludeList = [];
  if (!hasLightModes) {
    excludeList.push('B'); // Exclude light battery
  }

  if (!device.highMemory) {
    excludeList.push('F'); // Exclude position
  }

  if (!device.bikeRadar || (!device.highMemory && totalLights > 1)) {
    excludeList.push('I'); // Exclude bike radar
  }

  if (!device.profileName) {
    excludeList.push('K'); // Exclude profile name
  }

  if (!device.highMemory || !device.barometer) {
    excludeList.push('L'); // Exclude gradient
  }

  if (!device.highMemory || !device.solar) {
    excludeList.push('M'); // Exclude solar intensity
  }

  return !excludeList.length
    ? filterList
    : filterList.filter(f => excludeList.indexOf(f.id) < 0);
};

export default observer(({ filterGroups, lightModes, device, totalLights }) => {
  const [filterTypes, setFilterTypes] = React.useState(getFilterTypes(lightModes, device, totalLights));

  const createFilterGroup = action(() => {
    filterGroups.push(new FilterGroup(!!lightModes));
  });
  const removeFilterGroup = action((filterGroup) => {
    filterGroups.remove(filterGroup);
  });
  const createFilter = action((filterGroup) => {
    filterGroup.filters.push(new Filter());
  });
  const handleChange = (filterGroup) => {
    filterGroup.setOpen(!filterGroup.open);
  };
  const canMoveUpFilterGroup = (filterGroup) => {
    return filterGroups.indexOf(filterGroup) > 0;
  };
  const moveUpFilterGroup = action((filterGroup) => {
    arrayMoveUp(filterGroups, filterGroup);
  });
  const canMoveDownFilterGroup = (filterGroup) => {
    return filterGroups.indexOf(filterGroup) < (filterGroups.length - 1);
  };
  const moveDownFilterGroup = action((filterGroup) => {
    arrayMoveDown(filterGroups, filterGroup);
  });

  useEffect(
    () => {
      setFilterTypes(getFilterTypes(lightModes, device, totalLights));
    },
    [lightModes, device, totalLights]
  );

  useEffect(
    () => {
      filterGroups.forEach(filterGroup => {
        filterGroup.filters.forEach(filter => {
          if (!filterTypes.find(t => t.id === filter.type)) {
            filter.setType(null);
          }
        });
      })
    },
    [filterTypes, filterGroups]
  );

  return (
    <div>
      <List sx={{ padding: 0 }}>
        {filterGroups.map(filterGroup => (
        <Accordion key={filterGroup.id}
              TransitionProps={{ unmountOnExit: true }}
              expanded={filterGroup.open}
              onChange={() => handleChange(filterGroup)}>
          <AccordionSummary
            item={filterGroup}
            param1={lightModes}
            removeLabel="Remove group"
            removeCallback={removeFilterGroup}
            validationParameter={device}
            validationParameter2={lightModes}
            canMoveUpCallback={canMoveUpFilterGroup}
            moveUpCallback={moveUpFilterGroup}
            canMoveDownCallback={canMoveDownFilterGroup}
            moveDownCallback={moveDownFilterGroup}
          />
          <AccordionDetails>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <AppTextInput
                  label="Group name"
                  setter={filterGroup.setName}
                  value={filterGroup.name}
                  help={
                    <Typography>
                    The group name will be displayed above the light icon when the filter group is matched. Note that the name won't be displayed in case
                    there is not enough space above the light icon.
                  </Typography>
                  }
                />
              </Grid>
              {
                lightModes ? (
                  <React.Fragment>
                    <Grid item xs={12} sm={6}>
                      <AppSelect required items={lightModes} label="Light mode" setter={filterGroup.setLightMode} value={filterGroup.lightMode} />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <AppTextInput
                        type="number"
                        label="Activation delay in seconds"
                        setter={filterGroup.setActivationDelay}
                        value={filterGroup.activationDelay}
                        help={
                          <Typography>
                            It will postpone the light mode activation for the given delay. (e.g. change the light mode after the timer has been paused for five seconds)
                          </Typography>
                        }
                      />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <AppTextInput
                        type="number"
                        label="Deactivation delay in seconds"
                        setter={filterGroup.setDeactivationDelay}
                        value={filterGroup.deactivationDelay}
                        help={
                          <Typography>
                            It will postpone the light mode deactivation for the given delay. (e.g. keep the brake light mode for two more seconds after finishing braking)
                          </Typography>
                        }
                      />
                    </Grid>
                  </React.Fragment>
                )
                : null
              }
              <Grid item xs={12} sm={12}>
                <Typography variant="h5" gutterBottom>Filters</Typography>
              </Grid>
            </Grid>
            <div>
              <Filters filters={filterGroup.filters} filterTypes={filterTypes} device={device} />
            </div>
            <AddButton onClick={() => createFilter(filterGroup)}>
              Add Filter
            </AddButton>
          </AccordionDetails>
        </Accordion>
        ))}
      </List>
      <div>
        <AddButton onClick={createFilterGroup}>
          Add Filter Group
        </AddButton>
      </div>
    </div>
  );
});
