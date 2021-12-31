import React from 'react';
import Button from '@mui/material/Button';
import { styled } from '@mui/material/styles';
import AddIcon from '@mui/icons-material/Add';

export default styled((props) => (
  <Button
    variant="contained"
    color="secondary"
    startIcon={<AddIcon />}
    {...props}
  />
))(({ theme }) => ({
  margin: theme.spacing(1)
}));