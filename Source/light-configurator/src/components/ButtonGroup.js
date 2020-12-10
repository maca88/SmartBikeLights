import React, { useRef } from 'react';
import { useDrag, useDrop } from 'react-dnd';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import IconButton from '@material-ui/core/IconButton';
import AddIcon from '@material-ui/icons/Add';
import RemoveIcon from '@material-ui/icons/Remove';
import AppTextInput from '../inputs/AppTextInput';
import AppSelect from '../inputs/AppSelect';

const useStyles = makeStyles((theme) => ({
  container: {
    flexGrow: 1,
    cursor: 'move'
  },
  paper: {
    padding: theme.spacing(2)
  },
  actions: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  }
}));

export default observer(({ buttonGroup, lightModes, index, moveGroup, addButton, removeButton }) => {
  const ref = useRef(null);
  const classes = useStyles();
  const [, drop] = useDrop({
    accept: 'ButtonGroup',
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

  const [{ isDragging }, drag] = useDrag({
    item: { type: 'ButtonGroup', id: buttonGroup.id, index },
    collect: (monitor) => ({
      isDragging: monitor.isDragging(),
    }),
  });

  const opacity = isDragging ? 0 : 1;
  drag(drop(ref));
  return (
    <div ref={ref} className={classes.container} style={{ ...opacity }}>
      <Grid container spacing={1}>
        {buttonGroup.buttons.map((button, index) => (
          <Grid item xs key={button.id}>
            <Paper className={classes.paper}>
              <Grid container spacing={3}>
                <Grid item xs={12} sm={12}>
                  <AppSelect required items={lightModes} label="Light mode" setter={button.setMode} value={button.mode} />
                </Grid>
                <Grid item xs={12} sm={12}>
                  { button.mode >= 0
                  ? <AppTextInput required label="Button name" value={button.name} setter={button.setName} />
                  : <AppTextInput label="Button name" value="Smart / Manual / Network" />
                  }
                </Grid>
              </Grid>
            </Paper>
          </Grid>
        ))}
        <Grid item xs={1} className={classes.actions}>
          <Grid container spacing={1}>
            <Grid item xs={12} sm={12}>
              <IconButton edge="end" aria-label="add" disabled={buttonGroup.buttons.length > 1} onClick={() => addButton(buttonGroup)}>
                <AddIcon />
              </IconButton>
            </Grid>
            <Grid item xs={12} sm={12}>
              <IconButton edge="end" aria-label="remove" onClick={() => removeButton(buttonGroup)}>
                <RemoveIcon />
              </IconButton>
            </Grid>
          </Grid>
        </Grid>
      </Grid>
    </div>
  );
});