import React from 'react';
import { styled } from '@mui/material/styles';
import AccordionSummary from '@mui/material/AccordionSummary';
import IconButton from '@mui/material/IconButton';
import DeleteIcon from '@mui/icons-material/Delete';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import Typography from '@mui/material/Typography';
import FormControlLabel from '@mui/material/FormControlLabel';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';

const GridValid = styled(Grid)(() => ({
  display: 'flex',
  alignItems: 'center'
}));

const GridInvalid = styled(Grid)(() => ({
  color: '#f44336',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center'
}));

const StyledAccordionSummary = styled((props) => (
  <AccordionSummary
    style={{minHeight: 56}}
    expandIcon={<ExpandMoreIcon />}
    {...props}
  />
))(({ theme }) => ({
  backgroundColor: theme.palette.mode === 'dark'
    ? 'rgba(255, 255, 255, .05)'
    : 'rgba(0, 0, 0, .03)',
  borderBottom: `1px solid ${theme.palette.divider}`,
  marginBottom: -1,
  '& .MuiAccordionSummary-content.Mui-expanded': {
    margin: '0px 0',
    [theme.breakpoints.only('xs')]: {
      margin: '12px 0',
    }
  },
  '& .MuiAccordionSummary-content': {
    margin: '0px 0',
    [theme.breakpoints.only('xs')]: {
      margin: '12px 0',
    }
  }
}));

export default observer(({ item, param1, removeLabel, removeCallback, moveUpCallback, canMoveUpCallback,
  canMoveDownCallback, moveDownCallback, validationParameter, validationParameter2 }) => {

  const isValid = validationParameter2
    ? item.isValid(validationParameter, validationParameter2)
    : item.isValid(validationParameter);

  return (
    <StyledAccordionSummary
      aria-controls={item.id}
      id={item.id}
    >
      <div style={{ width: '100%' }}>
        <Grid container>
          <Grid item xs={9} sm={3}>
            <FormControlLabel
              label=""
              onClick={(event) => event.stopPropagation()}
              onFocus={(event) => event.stopPropagation()}
              control={
                <IconButton aria-label="delete" onClick={() => removeCallback(item)} size="large">
                  <DeleteIcon />
                </IconButton>
              }
            />
            {
              canMoveUpCallback(item)
              ? <FormControlLabel
                  label=""
                  onClick={(event) => event.stopPropagation()}
                  onFocus={(event) => event.stopPropagation()}
                  control={
                    <IconButton onClick={() => moveUpCallback(item)} size="large">
                      <ArrowUpwardIcon />
                    </IconButton>
                  } />
              : null
            }
            {
              canMoveDownCallback(item)
              ? <FormControlLabel
                  label=""
                  onClick={(event) => event.stopPropagation()}
                  onFocus={(event) => event.stopPropagation()}
                  control={
                    <IconButton edge="end" onClick={() => moveDownCallback(item)} size="large">
                      <ArrowDownwardIcon />
                    </IconButton>
                  } />
              : null
            }
          </Grid>
          {
            isValid
            ? <GridValid item xs={10} sm={8}>
                <Typography>{item.getDisplayName(param1)}</Typography>
              </GridValid>
            : <GridValid item xs={1} sm={8}>
              </GridValid>
          }
          <GridInvalid item xs={2} sm={1}>
          { isValid ? null : <ErrorOutlineIcon /> }
          </GridInvalid>
        </Grid>
      </div>
    </StyledAccordionSummary>
  );
});