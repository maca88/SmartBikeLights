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
import { filterList, deviceMap } from '../constants';

const filtersWoPosition = filterList.filter(o => o.id !== 'F');
const getFilterTypes = (device, hasLightModes) => {
  let list = !device || deviceMap[device].polygons ? filterList : filtersWoPosition;
  return hasLightModes ? list : list.filter(o => o.id !== 'B');
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
  const [filterTypes, setFilterTypes] = React.useState(getFilterTypes(device, lightModes));
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

  useEffect(
    () => {
      setFilterTypes(getFilterTypes(device, lightModes));
    },
    [device, lightModes]
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
          />
          <AccordionDetails>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <AppTextInput label="Group name" setter={filterGroup.setName} value={filterGroup.name} />
              </Grid>
              {
                lightModes ? (
                <Grid item xs={12} sm={6}>
                  <AppSelect required items={lightModes} label="Light mode" setter={filterGroup.setLightMode} value={filterGroup.lightMode} />
                </Grid>
                )
                : null
              }
              <Grid item xs={12} sm={12}>
                <Typography variant="h5" gutterBottom>Filters</Typography>
              </Grid>
            </Grid>
            <div>
              <Filters filters={filterGroup.filters} filterTypes={filterTypes} />
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