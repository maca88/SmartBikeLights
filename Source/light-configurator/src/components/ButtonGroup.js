import React, { useRef } from 'react';
import { styled } from '@mui/material/styles';
import { useDrag, useDrop } from 'react-dnd';
import { observer } from 'mobx-react-lite';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import IconButton from '@mui/material/IconButton';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import AppTextInput from '../inputs/AppTextInput';
import AppSelect from '../inputs/AppSelect';
import LightButtonGroup from '../models/LightButtonGroup';

const Root = styled('div')(({ theme }) => ({
  flexGrow: 1,
  cursor: 'move',
  marginTop: theme.spacing(1)
}));

export default observer(({ buttonGroup, lightModes, index, moveGroup, addButton, removeButton }) => {
  const ref = useRef(null);
  const [{ handlerId }, drop] = useDrop({
    accept: 'ButtonGroup',
    collect(monitor) {
      return {
        handlerId: monitor.getHandlerId(),
      }
    },
    hover(item, monitor) {
      if (!ref.current) {
        return
      }

      const dragIndex = item.index
      const hoverIndex = index

      // Don't replace items with themselves
      if (dragIndex === hoverIndex) {
        return
      }

      // Determine rectangle on screen
      const hoverBoundingRect = ref.current?.getBoundingClientRect()

      // Get vertical middle
      const hoverMiddleY = (hoverBoundingRect.bottom - hoverBoundingRect.top) / 2

      // Determine mouse position
      const clientOffset = monitor.getClientOffset()

      // Get pixels to the top
      const hoverClientY = clientOffset.y - hoverBoundingRect.top

      // Only perform the move when the mouse has crossed half of the items height
      // When dragging downwards, only move when the cursor is below 50%
      // When dragging upwards, only move when the cursor is above 50%

      // Dragging downwards
      if (dragIndex < hoverIndex && hoverClientY < hoverMiddleY) {
        return
      }

      // Dragging upwards
      if (dragIndex > hoverIndex && hoverClientY > hoverMiddleY) {
        return
      }

      // Time to actually perform the action
      moveGroup(dragIndex, hoverIndex)

      // Note: we're mutating the monitor item here!
      // Generally it's better to avoid mutations,
      // but it's good here for the sake of performance
      // to avoid expensive index searches.
      item.index = hoverIndex
    },
  });

  var isGroup = buttonGroup instanceof LightButtonGroup;
  const [{ isDragging }, drag] = useDrag({
    type: 'ButtonGroup',
    item: () => ({ id: buttonGroup.id, index }),
    collect: (monitor) => ({
      isDragging: monitor.isDragging(),
    }),
  });

  const getButtonTemplate = (button) => {
    return (
      <Grid item xs key={button.id}>
        <Paper sx={{ padding: 2 }}>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={12}>
              <AppSelect required items={lightModes} label="Light mode" setter={button.setMode} value={button.mode} />
            </Grid>
            <Grid item xs={12} sm={12}>
              { button.mode >= 0
              ? <AppTextInput required label="Button name" value={button.name} setter={button.setName} />
              : button.mode === -2 ? <AppTextInput label="Button name" value="Configuration name" />
              : button.mode === -3 ? <AppTextInput label="Button name" value="Battery" />
              : <AppTextInput label="Button name" value="Smart / Manual / Network" />
              }
            </Grid>
          </Grid>
        </Paper>
      </Grid>);
  };

  const opacity = isDragging ? 0 : 1;
  drag(drop(ref));
  return (
    <Root ref={ref} style={{ ...opacity }} data-handler-id={handlerId}>
      <Grid container spacing={1}>
        { isGroup
          ? buttonGroup.buttons.map((button, index) => getButtonTemplate(button))
          : getButtonTemplate(buttonGroup)
        }
        <Grid item xs={1}
          sx={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center'
          }}>
          {
            isGroup
            ? (
              <Grid container spacing={1}>
                <Grid item xs={12} sm={12}>
                  <IconButton
                    edge="end"
                    aria-label="add"
                    disabled={buttonGroup.buttons.length > 1}
                    onClick={() => addButton(buttonGroup)}
                    size="large">
                    <AddIcon />
                  </IconButton>
                </Grid>
                <Grid item xs={12} sm={12}>
                  <IconButton
                    edge="end"
                    aria-label="remove"
                    onClick={() => removeButton(buttonGroup)}
                    size="large">
                    <RemoveIcon />
                  </IconButton>
                </Grid>
              </Grid>
            )
            : (
              <Grid container spacing={1}>
                <Grid item xs={12} sm={12}>
                  <IconButton
                    aria-label="remove"
                    onClick={() => removeButton(buttonGroup)}
                    size="large">
                    <RemoveIcon />
                  </IconButton>
                </Grid>
              </Grid>
            )
          }
        </Grid>
      </Grid>
    </Root>
  );
});
