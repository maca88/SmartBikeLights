import React from 'react';
import { styled } from '@mui/material/styles';
import { action } from 'mobx';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import DeleteIcon from '@mui/icons-material/Delete';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import Tone from '../models/Tone';
import ToneItem from '../models/ToneItem';
import AddButton from '../components/AddButton';
import { toneTypeList, toneList } from '../constants';

const Root = styled(Grid)(({ theme }) => ({
  flexGrow: 1,
  marginTop: theme.spacing(1)
}));

export default observer(({ buttonAction }) => {
  const [state, setState] = React.useState({ toneIndex: 0 });

  const createTone = action(() => {
    buttonAction.tones.push(new Tone(state.toneIndex));
    setState({ ...state, toneIndex: state.toneIndex + 1 });
  });
  const removeTone = action((tone) => {
    buttonAction.tone.remove(tone);
  });
  const addToneItem = action(() => {
    buttonAction.toneSequence.push(new ToneItem());
  });
  const removeToneItem = action((toneItem) => {
    buttonAction.toneSequence.remove(toneItem);
  });

  return (
    <Grid container spacing={3} sx={{ marginBottom: 2 }}>
      <Grid item xs={12} sm={6}>
        <AppSelect required items={toneTypeList} label="Tone type" setter={buttonAction.setToneTypeId} value={buttonAction.toneTypeId} />
      </Grid>
      {
        buttonAction.toneTypeId === 2 /* Custom */ ?
        <Grid item xs={12} sm={6}>
          <AppTextInput required label="Repeat count" type="number" value={buttonAction.repeatCount} setter={buttonAction.setRepeatCount} />
        </Grid>
        : null
      }
      {
        buttonAction.toneTypeId === 1 /* Built-in */ ?
        <Grid item xs={12} sm={6}>
          <AppSelect required items={toneList} label="Press tone" setter={buttonAction.setToneId} value={buttonAction.toneId} />
        </Grid>
        : buttonAction.toneTypeId === 2 /* Custom */ ?
        <Grid item container xs={12}>
          <Grid item xs={12}>
            <Typography variant="h5">Tones</Typography>
          </Grid>
          <Grid item container xs={12}>
            {buttonAction.tones.map((tone) => (
              <Root container key={tone.id}>
                  <Grid item xs>
                    <Paper sx={{ padding: 2, marginBottom: 1 }}>
                      <Grid container spacing={3}>
                        <Grid item xs={12} sm={4}>
                          <AppTextInput required label="Name" value={tone.name} setter={tone.setName} />
                        </Grid>
                        <Grid item xs={12} sm={4}>
                          <AppTextInput required label="Frequency" type="number" value={tone.frequency} setter={tone.setFrequency} />
                        </Grid>
                        <Grid item xs={12} sm={4}>
                          <AppTextInput required label="Duration [ms]" type="number" value={tone.duration} setter={tone.setDuration} />
                        </Grid>
                      </Grid>
                    </Paper>
                  </Grid>
                  <Grid item xs={1}
                    sx={{
                      display: 'flex',
                      justifyContent: 'center',
                      alignItems: 'center'
                    }}>
                    <Grid container sx={{ margin: 0 }}>
                      <Grid item xs={12} sm={12} sx={{ display: 'flex', justifyContent: 'center' }}>
                        <IconButton
                          aria-label="remove"
                          onClick={() => removeTone(tone)}
                          size="large">
                          <DeleteIcon />
                        </IconButton>
                      </Grid>
                    </Grid>
                  </Grid>
              </Root>
            ))}
          </Grid>
          <AddButton onClick={() => createTone()}>
            Create Tone
          </AddButton>

          <Grid item xs={12} sx={{ marginTop: 3 }}>
            <Typography variant="h5">Sequence</Typography>
          </Grid>

          {buttonAction.toneSequence.map((toneItem, index) => (
            <Root item container xs={12} key={toneItem.id}>
              <Grid container>
                <Grid item xs>
                  <Paper sx={{ padding: 2, marginBottom: 1 }}>
                    <Grid container spacing={3}>
                      <Grid item xs={12}>
                        <AppSelect items={buttonAction.tones} required label="Tone" setter={toneItem.setToneId} value={toneItem.toneId} />
                      </Grid>
                    </Grid>
                  </Paper>
                </Grid>
                <Grid item xs={1}
                  sx={{
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center'
                  }}>
                  <Grid container sx={{ margin: 0 }}>
                    <Grid item xs={12} sm={12} sx={{ display: 'flex', justifyContent: 'center' }}>
                      <IconButton
                        aria-label="remove"
                        onClick={() => removeToneItem(toneItem)}
                        size="large">
                        <DeleteIcon />
                      </IconButton>
                    </Grid>
                  </Grid>
                </Grid>
              </Grid>
            </Root>
          ))}

          <AddButton onClick={() => addToneItem()}>
            Add Tone
          </AddButton>
        </Grid>
        : null
      }
    </Grid>
  );
});
