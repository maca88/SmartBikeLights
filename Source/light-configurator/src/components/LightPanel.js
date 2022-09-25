import React, { useEffect, useCallback } from 'react';
import Grid from '@mui/material/Grid';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import LightButtonGroup from '../models/LightButtonGroup';
import LightButton from '../models/LightButton';
import ButtonGroup from './ButtonGroup';
import AddButton from './AddButton';
import { createMenuItemColorTemplateFunc } from './Templates';
import { controlMode, getButtonColors, getButtonTextColors } from '../constants';
import AppTextInput from '../inputs/AppTextInput';
import AppSelect from '../inputs/AppSelect';

const getModes = (lightModes) => {
  return [controlMode].concat(lightModes);
};
const buttonColorTemplate = createMenuItemColorTemplateFunc();
const buttonTextColorTemplate = createMenuItemColorTemplateFunc(true);

export default observer(({ lightPanel, lightModes }) => {
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
    <div>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={4}>
          <AppTextInput label="Short light name" setter={lightPanel.setLightName} value={lightPanel.lightName} />
        </Grid>
        <Grid item xs={12} sm={4}>
          <AppSelect required items={getButtonColors()} label="Active button backgound color" setter={lightPanel.setButtonColor} value={lightPanel.buttonColor} itemTemplateFunc={buttonColorTemplate} />
        </Grid>
        <Grid item xs={12} sm={4}>
          <AppSelect required items={getButtonTextColors()} label="Active button text color" setter={lightPanel.setButtonTextColor} value={lightPanel.buttonTextColor} itemTemplateFunc={buttonTextColorTemplate} />
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
      <AddButton onClick={() => addButtonGroup()}>
        Add Button Group
      </AddButton>
    </div>
  );
});
