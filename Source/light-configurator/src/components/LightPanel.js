import React, { useEffect, useCallback } from 'react';
import AddIcon from '@material-ui/icons/Add';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import LightButtonGroup from '../models/LightButtonGroup';
import LightButton from '../models/LightButton';
import ButtonGroup from './ButtonGroup';
import { controlMode } from '../constants';
import AppTextInput from '../inputs/AppTextInput';

const getModes = (lightModes) => {
  return [controlMode].concat(lightModes);
};

const useStyles = makeStyles((theme) => ({
  button: {
    margin: theme.spacing(1)
  }
}));

export default observer(({ lightPanel, lightModes, }) => {
  const classes = useStyles();
  const [modes, setModes] = React.useState(getModes(lightModes));
  const addButtonGroup = action(() => {
    const group = new LightButtonGroup();
    group.buttons.push(new LightButton());
    lightPanel.buttonGroups.push(group);
  });
  const moveGroup = action(useCallback((dragIndex, hoverIndex) => {
      const dragGroup = lightPanel.buttonGroups[dragIndex]
      lightPanel.buttonGroups.splice(dragIndex, 1);
      lightPanel.buttonGroups.splice(hoverIndex, 0, dragGroup);
    },
    [lightPanel.buttonGroups],
  ));
  const addButton = action((group) => {
    group.buttons.push(new LightButton());
  });
  const removeButton = action((group) => {
    group.buttons.remove(group.buttons[group.buttons.length - 1]);
    if (!group.buttons.length) {
      lightPanel.buttonGroups.remove(group);
    }
  });

  useEffect(() => {
    setModes(getModes(lightModes));
  }, [lightModes]);

  return (
    <React.Fragment>
      <Grid container spacing={3}>
        <Grid item xs={6} sm={4}>
          <AppTextInput label="Short light name" setter={lightPanel.setLightName} value={lightPanel.lightName} />
        </Grid>
      </Grid>
      <div>
        {lightPanel.buttonGroups.map((group, index) => (
          <ButtonGroup
            key={group.id}
            buttonGroup={group}
            lightModes={modes}
            index={index}
            moveGroup={moveGroup}
            addButton={addButton}
            removeButton={removeButton}
          />
        ))}
      </div>
      <Button
        variant="contained"
        color="secondary"
        className={classes.button}
        startIcon={<AddIcon />}
        onClick={() => addButtonGroup()}
      >
        Add Button Group
      </Button>
    </React.Fragment>
    );
});
