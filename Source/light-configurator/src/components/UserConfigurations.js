import React from 'react';
import { observer } from 'mobx-react-lite'
import { makeAutoObservable } from 'mobx';
import Box from '@mui/material/Box';
import Fab from '@mui/material/Fab';
import SaveIcon from '@mui/icons-material/Save';
import Grid from '@mui/material/Grid';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import DeleteIcon from '@mui/icons-material/Delete';
import FirebaseService from '../services/FirebaseService';
import AppSelect from '../inputs/AppSelect';
import Configuration from '../models/Configuration';
import AppTextInput from '../inputs/AppTextInput';

class SaveDialogModel {
  saveMode = null;
  name = '';
  isNew = false;

  constructor(overrideExisting, name) {
    this.saveMode = overrideExisting ? 'override' : 'new';
    this.name = name || '';
    this.isNew = !overrideExisting;
    makeAutoObservable(this, {
      id: false
    });
  }

  setName = (value) => {
    this.name = value;
  }

  setSaveMode = (value) => {
    this.saveMode = value;
  }

  isValid() {
    return (this.saveMode === 'override' && this.name) || this.name;
  }
}

export default observer(({ configuration, setConfiguration, deviceList, currentUser }) => {

  const [state, setState] = React.useState({
    parseError: false,
    showDeleteDialog: false,
    showSaveDialog: false,
    saveDialogModel: new SaveDialogModel(false, null)
  });

  const parse = (value) => {
    let newConfiguration = null;
    try {
      newConfiguration = Configuration.parse(value, deviceList);
      if (!!newConfiguration) {
        setConfiguration(newConfiguration);
      }
    }
    catch {}
    finally {
      return newConfiguration;
    }
  };

  const setSelectedConfiguration = (configurationId) => {
    let parseError = false;
    if (configurationId) {
      const data = FirebaseService.userConfigurations.find(o => o.id === configurationId);
      parseError = !parse(data.value);
    } else {
      setConfiguration(new Configuration())
    }

    FirebaseService.setSelectedConfiguration(configurationId);
    setState((prevState) => {
      return {
        ...prevState,
        parseError: parseError
      };
    })
  };

  const openSaveDialog = () => {
    const configurationId = FirebaseService.selectedConfiguration;
    let configurationData;
    if (configurationId) {
      configurationData = FirebaseService.userConfigurations.find(o => o.id === configurationId);
    }

    setState((prevState) => {
      return {
        ...prevState,
        showSaveDialog: true,
        saveDialogModel: new SaveDialogModel(configurationId != null, configurationData?.name)
      };
    })
  };

  const closeSaveDialog = () => {
    setState((prevState) => {
      return {
        ...prevState,
        showSaveDialog: false
      };
    })
  };

  const saveConfiguration = async () => {
    let configurationId = FirebaseService.selectedConfiguration;
    if (state.saveDialogModel.saveMode === 'new') {
      configurationId = await FirebaseService.saveConfigurationAsync(state.saveDialogModel.name, configuration.getConfigurationValue(deviceList));
    } else {
      await FirebaseService.updateConfigurationAsync(configurationId, state.saveDialogModel.name, configuration.getConfigurationValue(deviceList));
    }

    FirebaseService.setSelectedConfiguration(configurationId);
    closeSaveDialog();
  };

  const openDeleteDialog = () => {
    setState((prevState) => {
      return {
        ...prevState,
        showDeleteDialog: true
      };
    })
  };

  const closeDeleteDialog = () => {
    setState((prevState) => {
      return {
        ...prevState,
        showDeleteDialog: false
      };
    })
  };

  const deleteSelectedConfiguration = async () => {
    await FirebaseService.deleteConfigurationAsync(FirebaseService.selectedConfiguration);
    setState((prevState) => {
      return {
        ...prevState,
      };
    });
    closeDeleteDialog();
  }

  const style = {
    margin: 0,
    top: 'auto',
    right: 20,
    bottom: 20,
    left: 'auto',
    position: 'fixed',
  };

  return (
    currentUser
        ?
        <Grid container spacing={2} sx={{ marginBottom: 4 }}  justifyContent="center">
          <Grid item xs={8} sm={10}>
            <AppSelect label="Saved configurations" items={FirebaseService.userConfigurations} setter={setSelectedConfiguration} value={FirebaseService.selectedConfiguration} />
          </Grid>
          <Grid item xs={4} sm={2} sx={{
            marginBottom: 'auto',
            marginTop: 'auto'
          }}>
            <Button variant="contained" disabled={!FirebaseService.selectedConfiguration || state.parseError} onClick={() => {navigator.clipboard.writeText(configuration.getConfigurationValue(deviceList))}}>Copy</Button>
            <IconButton
              color="error"
              disabled={!FirebaseService.selectedConfiguration}
              style={{ marginLeft: "0.5em", padding: '0' }}
              onClick={openDeleteDialog}
              size="large">
              <DeleteIcon />
            </IconButton>
            <Dialog
              open={state.showDeleteDialog}
              onClose={closeDeleteDialog}
              aria-labelledby="delete-dialog-title"
              aria-describedby="delete-dialog-description"
            >
              <DialogTitle sx={{ minWidth: 300 }} id="delete-dialog-title">Delete configuration</DialogTitle>
              <DialogContent>
                <DialogContentText id="delete-dialog-description">
                  Do you want to delete the selected configuration?
                </DialogContentText>
              </DialogContent>
              <DialogActions>
                <Button onClick={closeDeleteDialog}>No</Button>
                <Button onClick={deleteSelectedConfiguration} autoFocus>
                  Yes
                </Button>
              </DialogActions>
            </Dialog>

            <Dialog
              open={state.showSaveDialog}
              onClose={closeSaveDialog}
              aria-labelledby="save-dialog-title"
              aria-describedby="save-dialog-description"
            >
              <DialogTitle sx={{ minWidth: 300 }} id="save-dialog-title">Save configuration</DialogTitle>
              <DialogContent>
                {
                  state.saveDialogModel?.isNew
                  ? <AppTextInput required label="Configuration name" setter={state.saveDialogModel.setName} value={state.saveDialogModel.name} />
                  : <div>
                      <RadioGroup
                        defaultValue="override"
                        value={state.saveDialogModel.saveMode}
                        onChange={(e) => state.saveDialogModel.setSaveMode(e.target.value) }
                        name="radio-buttons-group"
                      >
                        <FormControlLabel value="override" control={<Radio />} label="Override existing configuration" />
                        <FormControlLabel value="new" control={<Radio />} label="Save as a new configuration" />
                      </RadioGroup>
                      <AppTextInput required label="Configuration name" setter={state.saveDialogModel.setName} value={state.saveDialogModel.name} />
                    </div>
                }
              </DialogContent>
              <DialogActions>
                <Button onClick={closeSaveDialog}>Cancel</Button>
                <Button disabled={!state.saveDialogModel.isValid()} onClick={saveConfiguration} autoFocus>
                  Confirm
                </Button>
              </DialogActions>
            </Dialog>
          </Grid>
          { state.parseError ?
            <Grid item xs={12} sm={12}>
              <Alert severity="error">Invalid configuration.</Alert>
            </Grid>
            : null
          }
          {
            configuration && configuration.isValid(deviceList)
            ?
              <Box style={style}>
                <Fab color="primary" title="Save" aria-label="add" onClick={openSaveDialog}>
                  <SaveIcon />
                </Fab>
              </Box>
            : null
          }
        </Grid>
      : null
    );
});
