import React, { useEffect } from 'react';
import { observer } from 'mobx-react-lite'
import LoginIcon from '@mui/icons-material/Login';
import LogoutIcon from '@mui/icons-material/Logout';
import IconButton from '@mui/material/IconButton';
import Dialog from '@mui/material/Dialog';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import FirebaseService from '../services/FirebaseService'
import FirebaseAuth from './FirebaseAuth'

export default observer(() => {
  const [open, setOpen] = React.useState(false);

  const openDialog = () => {
    setOpen(true);
  };

  const closeDialog = () => {
    setOpen(false);
  };

  useEffect(() => {
    if (FirebaseService.currentUser) {
      closeDialog();
    }
  });

  return (
      <div>
        { FirebaseService.isSignedIn()
        ?
        <IconButton title="Sign out" sx={{ ml: 1 }} onClick={() => FirebaseService.signOut()} color="inherit">
          <LogoutIcon />
        </IconButton>
        :
        <IconButton title="Sign in" sx={{ ml: 1 }} onClick={openDialog} color="inherit">
          <LoginIcon />
        </IconButton>
        }
        <Dialog
          open={open}
          onClose={closeDialog}
          aria-labelledby="login-dialog-title"
          aria-describedby="login-dialog-description"
      >
        <DialogTitle id="login-dialog-title">Sign in</DialogTitle>
        <DialogContent>
          <DialogContentText id="login-dialog-description">
            By signing in, it is possible to save the created configurations that can be used for future modifications.
          </DialogContentText>
          <FirebaseAuth />
        </DialogContent>
      </Dialog>
      </div>
    );
});
