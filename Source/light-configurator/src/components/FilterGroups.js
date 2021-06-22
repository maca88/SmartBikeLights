import React, { useEffect } from 'react';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import AddIcon from '@material-ui/icons/Add';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import AppTextInput from '../inputs/AppTextInput';
import AppSelect from '../inputs/AppSelect';
import FilterGroup from '../models/FilterGroup';
import Filter from '../models/Filter';
import Filters from '../components/Filters';
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
const useStyles = makeStyles((theme) => ({
  list: {
    padding: 0
  },
  button: {
    margin: theme.spacing(1)
  },
  heading: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  }
}));
export default observer(({ filterGroups, lightModes, device }) => {
  const [filterTypes, setFilterTypes] = React.useState(getFilterTypes(lightModes, device));
  const classes = useStyles();
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
    <React.Fragment>
      <List className={classes.list}>
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
                <AppTextInput label="Group name" setter={filterGroup.setName} value={filterGroup.name} />
              </Grid>
              {
                lightModes ? (
                  <React.Fragment>
                    <Grid item xs={12} sm={6}>
                      <AppSelect required items={lightModes} label="Light mode" setter={filterGroup.setLightMode} value={filterGroup.lightMode} />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <AppTextInput type="number" label="Minimum active time in seconds" setter={filterGroup.setMinActiveTime} value={filterGroup.minActiveTime} />
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
            <Button
              variant="contained"
              color="secondary"
              className={classes.button}
              startIcon={<AddIcon />}
              onClick={() => createFilter(filterGroup)}
            >
              Add Filter
            </Button>

          </AccordionDetails>
        </Accordion>
        ))}
      </List>
      <div>
        <Button
          variant="contained"
          color="secondary"
          className={classes.button}
          startIcon={<AddIcon />}
          onClick={createFilterGroup}
        >
          Add Filter Group
        </Button>
      </div>
    </React.Fragment>
  );
});