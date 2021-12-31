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
const getFilterTypes = (hasLightModes, device) => {
  if (!device) {
    return emptyFilters;
  }

  const excludeList = [];
  if (!hasLightModes) {
    excludeList.push('B');
  }

  if (!device.highMemory){
    excludeList.push('F');
  }

  if (!device.bikeRadar){
    excludeList.push('I');
  }

  if (!device.profileName){
    excludeList.push('K');
  }

  return !excludeList.length
    ? filterList
    : filterList.filter(f => excludeList.indexOf(f.id) < 0);
};

export default observer(({ filterGroups, lightModes, device }) => {
  const [filterTypes, setFilterTypes] = React.useState(getFilterTypes(lightModes, device));

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
      setFilterTypes(getFilterTypes(lightModes, device));
    },
    [lightModes, device]
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
                        label="Minimum active time in seconds"
                        setter={filterGroup.setMinActiveTime}
                        value={filterGroup.minActiveTime}
                        help={
                          <Typography>
                          With this setting it is possible to set the minimum time the light mode of the filter group will be active once it is matched.
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